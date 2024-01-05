![Artboard 1 copy 2-cropped](https://github.com/Iamknownasfesal/alligator/assets/39006465/a9f5e064-8053-46f8-af9a-5f1df2c6b256)

# PoC Version of Alligator

## How to use it?

Firstly, you should get faucet via Sui Wallet on Testnet.
Then you can use by setting your private key in .env file and running `npm run start` or `yarn start` or `pnpm start` command.

## How does it work?

You can check out index.ts for the mockup of the Alligator. It uses Sui SDK to interact with Sui Blockchain.
We use PTBs to make 15~ transactions in one transaction. In this mockup we only swap X to Y with two swap providers. But in the real version, we will use pathfinding algorithm to find the best possible trading rates and reduce slippage.

## Addresses

- SUI 0x2::sui::SUI
- swapper1 0x061fb2da3c48899487106e5b4ade6da596e5af4c397f82758e334cd837c0af78
- swapper1pool 0x53035b168d96ae2765fed5e7dbf4ab3671132195b3945fabdca89841498afd0b
- swapper2 0x9c64f177d5d8dba24330c04feb4c5542510d11fe2fcff9da0ef6b31c331ad32d
- swapper2pool 0xe1f68ccb00eadf47682e585f7a874311085a598f835cd798608d50c19e0349a0
- mycoin 0x66e1331b3bd08f94dec255ad1b1c1111e84c0f114ea6f005bdca9a4d0a29f438::mycoin::MYCOIN
- mycointreasury 0x36b18c6debb3af169dfb96abd14f7f2a8b0138bb8619f57dd09565fd34cd18cc
- mycointreasuryadmin 0x2eb44d6fe52d6b336f1e4cc039da467b6d5cccb05084c6e5f5d8b9cce21c4b9f

If there is not enough liquidity, you can contract me via discord(Fesal) or twitter(@iamknownasfesal) to add more liquidity or mint more for liquidity.
