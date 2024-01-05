import "dotenv/config";
import { getKeypair } from "./crypto/keypair";
import { getFullnodeUrl, SuiClient } from "@mysten/sui.js/client";
import { getFaucetHost, requestSuiFromFaucetV0 } from "@mysten/sui.js/faucet";
import { MIST_PER_SUI } from "@mysten/sui.js/utils";
import {
  TransactionArgument,
  TransactionBlock,
  TransactionObjectArgument,
  TransactionResult,
} from "@mysten/sui.js/transactions";
import { fetchRoute } from "./api";
import Decimal from "decimal.js";
import zip from "just-zip-it";

const PRIVATE_KEY = process.env.PRIVATE_KEY;

if (!PRIVATE_KEY) {
  throw new Error("PRIVATE_KEY is not defined");
}

const KEYPAIR = getKeypair(PRIVATE_KEY);
const ADDRESS = KEYPAIR.toSuiAddress();
const suiClient = new SuiClient({ url: getFullnodeUrl("testnet") });
const ALLIGATOR_ADDRESS =
  "0x07ae5123d1c5e036aa5008df3ed1c11b46fac85374084891db52556bcd0bc090";
const SUI = "0x2::sui::SUI";
const target =
  "0x66e1331b3bd08f94dec255ad1b1c1111e84c0f114ea6f005bdca9a4d0a29f438::mycoin::MYCOIN";
const amount = (Number(MIST_PER_SUI) / 10).toString();

export const toWeight = (value: number) => {
  return new Decimal(value).mul(100).round().toNumber();
};

async function poc() {
  const balance = await suiClient.getBalance({
    owner: ADDRESS,
  });

  if (Number.parseInt(balance.totalBalance) < Number(MIST_PER_SUI) / 10)
    await requestSuiFromFaucetV0({
      host: getFaucetHost("devnet"),
      recipient: ADDRESS,
    });

  console.log(`Balance: ${balance.totalBalance} SUI`);

  const txb = new TransactionBlock();

  // Lets assume that we have a route api and it returns a quote object
  let route = await fetchRoute(SUI, amount, target);
  let owner = txb.pure(ADDRESS);
  let coins = txb.splitCoins(txb.gas, [txb.pure(route.sourceAmount)]);
  // START OF AGGREGATE_START
  let coin = txb.moveCall({
    target: `${ALLIGATOR_ADDRESS}::aggregator::aggregate_start`,
    typeArguments: [route.source],
    arguments: [
      txb.makeMoveVec({ objects: [coins] }),
      txb.pure(route.targetAmount),
      owner,
    ],
  });

  const sourceCoin = txb.moveCall({
    target: `${ALLIGATOR_ADDRESS}::utils::merge_coins`,
    typeArguments: [route.source],
    arguments: [txb.makeMoveVec({ objects: [coin] })],
  });

  const pathWeights = route.paths.map((p) => toWeight(p.weight));
  const result = txb.moveCall({
    target: `${ALLIGATOR_ADDRESS}::utils::split_coin_by_weights`,
    typeArguments: [route.source],
    arguments: [
      txb.makeMoveVec({ objects: [sourceCoin] }),
      txb.pure(pathWeights, "vector<u64>"),
    ],
  });
  const vectorType = `0x2::coin::Coin<${route.source}>`;
  const coinsForPaths = [...new Array(pathWeights.length)].map(() =>
    txb.moveCall({
      target: "0x1::vector::remove",
      typeArguments: [vectorType],
      arguments: [result, txb.pure(0)],
    })
  );

  txb.moveCall({
    target: "0x1::vector::destroy_empty",
    typeArguments: [vectorType],
    arguments: [result],
  });

  const swappedCoins: TransactionResult[] = [];
  for (const [{ path }, coinForPath] of zip(route.paths, coinsForPaths)) {
    let coinToSwap: TransactionArgument = coinForPath;
    const swap = txb.moveCall({
      target: path.swapperFunction,
      typeArguments: [path.source, path.target],
      arguments: [txb.pure(path.swapperPool), coinToSwap],
    });

    swappedCoins.push(swap);
  }

  const targetCoin = txb.moveCall({
    target: `${ALLIGATOR_ADDRESS}::utils::merge_coins`,
    typeArguments: [route.target],
    arguments: [txb.makeMoveVec({ objects: swappedCoins })],
  });

  // END OF AGGREGATE_START
  txb.moveCall({
    target: `${ALLIGATOR_ADDRESS}::aggregator::aggregate_end`,
    typeArguments: [route.target],
    arguments: [targetCoin, txb.pure(route.targetAmount)],
  });

  txb.transferObjects([targetCoin], ADDRESS);

  suiClient.signAndExecuteTransactionBlock({
    signer: KEYPAIR,
    transactionBlock: txb,
  });
}

poc();
