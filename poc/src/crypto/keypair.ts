import { Ed25519Keypair } from "@mysten/sui.js/keypairs/ed25519";
import { fromB64 } from "@mysten/bcs";

export function getKeypair(pk: string) {
  const privatekey = pk.replace(/^0x/, "");
  const privateKeyBase64 = Buffer.from(privatekey, "hex").toString("base64");
  return Ed25519Keypair.fromSecretKey(fromB64(privateKeyBase64));
}
