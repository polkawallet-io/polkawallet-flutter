import "@babel/polyfill";
import { seedGenerate, seedToMnemonic } from "./utils/bip39Util";
const { Keyring } = require("@polkadot/keyring");
const { u8aToHex } = require("@polkadot/util");
const keyring = new Keyring({ ss58Format: 2, type: "ed25519" });

import { WsProvider, ApiPromise } from "@polkadot/api";

// send message to JSChannel: PolkaWallet
function send(path, data) {
  PolkaWallet.postMessage(JSON.stringify({ path, data }));
}

async function connect() {
  const KUSAMA_ENDPOINT = "wss://kusama-rpc.polkadot.io/";
  const provider = new WsProvider(KUSAMA_ENDPOINT);
  window.api = await ApiPromise.create({ provider });
  send("ready", "wss connect success");

  // const name = await api.rpc.system.chain();
  // send("system/chain", name);

  // const Alice = "FuwMHtb2G3spmvjQGjG732cHtrrHnAs8FK6uDSBjW3RxCud";
  // const balance = await api.query.balances.freeBalance(Alice);
  // send("balances/freeBalance", balance);
}
connect().catch(err => send("log", err.message));
send("log", "main js loaded");

function gen() {
  // keyPair.setMeta({ name: msg.req.name });
  // const json = keyPair.toJson(msg.req.password);
  // json.meta.name = keyPair.meta.name;
  // json.meta.seed = u8aToHex(seed);
  // json.meta.mnemonic = key;
  return new Promise(resolve => {
    const seed = seedGenerate();
    const key = seedToMnemonic(seed);
    const keyPair = keyring.addFromMnemonic(key);
    resolve({
      seed: u8aToHex(seed),
      address: keyPair.address,
      // meta: keyPair.meta,
      isLocked: keyPair.isLocked,
      // publicKey: keyPair.publicKey,
      // type: keyPair.type,
      mnemonic: key
    });
  });
}

window.account = {
  gen
};
