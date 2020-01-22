import "@babel/polyfill";
import { seedGenerate, seedToMnemonic } from "./utils/bip39Util";
import { mnemonicGenerate } from "@polkadot/util-crypto";
import { Keyring } from "@polkadot/keyring";
const {
  isHex,
  hexToU8a,
  stringToU8a,
  formatBalance
} = require("@polkadot/util");
const keyring = new Keyring({ ss58Format: -1, type: "sr25519" });

import { WsProvider, ApiPromise } from "@polkadot/api";

// send message to JSChannel: PolkaWallet
function send(path, data) {
  // console.log(path, data);
  PolkaWallet.postMessage(JSON.stringify({ path, data }));
}

async function connect() {
  const KUSAMA_ENDPOINT = "wss://kusama-rpc.polkadot.io/";
  const provider = new WsProvider(KUSAMA_ENDPOINT);
  window.api = await ApiPromise.create({ provider });
  send("ready", "wss connect success");

  // test();
}
connect().catch(err => send("log", err.message));
send("log", "main js loaded");

const test = async () => {
  const sys = await api.rpc.system.properties();
  send("log", sys);
};

function gen() {
  // keyPair.setMeta({ name: msg.req.name });
  // const json = keyPair.toJson(msg.req.password);
  // json.meta.name = keyPair.meta.name;
  // json.meta.seed = u8aToHex(seed);
  // json.meta.mnemonic = key;
  return new Promise(resolve => {
    const key = mnemonicGenerate();
    const keyPair = keyring.addFromMnemonic(key);
    resolve({
      // seed: u8aToHex(seed),
      address: keyPair.address,
      // meta: keyPair.meta,
      // isLocked: keyPair.isLocked,
      // publicKey: keyPair.publicKey,
      // type: keyPair.type,
      mnemonic: key
    });
  });
}

function recover(keyType, cryptoType, data) {
  return new Promise(resolve => {
    let keyPair = {};
    switch (keyType) {
      case "Mnemonic":
        keyPair = keyring.addFromMnemonic(data, {}, cryptoType);
        resolve({
          address: keyPair.address,
          mnemonic: data
        });
        return;
      case "Raw Seed":
        if (isHex(data) && data.length === 66) {
          const SEEDu8a = hexToU8a(data);
          keyPair = keyring.addFromSeed(SEEDu8a, {}, cryptoType);
          resolve({
            seed: data,
            address: keyPair.address
          });
        } else if (data.length <= 32) {
          const SEED = data.padEnd(32, " ");
          keyPair = keyring.addFromSeed(stringToU8a(SEED), {}, cryptoType);
          resolve({
            seed: data,
            address: keyPair.address
          });
        } else {
          resolve({
            seed: data,
            address: "xxxxxxxxxxxxxxxxxxxxxxxx"
          });
        }
        return;
      case "Keystore":
        keyPair = keyring.addFromJson(JSON.parse(data));
        resolve({
          address: keyPair.address
        });
        return;
      default:
        resolve({
          address: "xxxxxxxxxxxxxxxxxxxxxxxx"
        });
    }
  });
}

function getBalance(address) {
  return api.query.balances
    .freeBalance(address)
    .then(res => formatBalance(res));
}

window.account = {
  gen,
  recover,
  getBalance
};
