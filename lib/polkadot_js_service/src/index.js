import "@babel/polyfill";
import { mnemonicGenerate } from "@polkadot/util-crypto";
import { Keyring } from "@polkadot/keyring";
const keyring = new Keyring({ ss58Format: -1, type: "sr25519" });

import { isHex, hexToU8a, stringToU8a, formatBalance } from "@polkadot/util";

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
  const j =
    '{"address":"HmyonjFVFZyg1mRjRvohVGRw9ouFDRoQ5ea9nDfH2Yi44qQ","encoded":"0x0bf9018b962efbae62b443a8412d5268f1bdb4f4d81439617ce570761eaa95a9c75926c3ac9188bfb50784e15816df7e554e33d239162e3b5a9b9ca19bae65b0da81966a800f19a8357f79618b6dca9fd067efb9ba23f38c4034064245513963d36564ddb665b26b8a973d065578a33e8e801b4ff28a65f03dd7412b9f39eff8b04ad2e6ba1c4421b7bd2a5366204b4374347ad30af7bd54139e94f94a","encoding":{"content":["pkcs8","sr25519"],"type":"xsalsa20-poly1305","version":"2"},"meta":{}}';
  const key = keyring.addFromJson(JSON.parse(j));
  send("log", key.isLocked);
  try {
    key.decodePkcs8("a111111");
    send("log", "password ok");
  } catch (err) {
    send("log", err.message);
  }
  send("log", key.isLocked);

  const test2 = "GvrJix8vF8iKgsTAfuazEDrBibiM6jgG66C6sT2W56cEZr3";
  const tx = api.tx.balances.transfer(test2, 1);
  const hash = await tx.signAndSend(key);
  send("log", hash);

  // const m =
  //   "second throw patch mix leaf call scare surface enlist pet exhibit hammer";
  // const key = keyring.addFromMnemonic(m);
  // send("log", key.toJson());
  // key.setMeta({ name: "test" });
  // send("log", JSON.stringify(key.toJson("a111111")));
};

function gen() {
  return new Promise(resolve => {
    const key = mnemonicGenerate();
    resolve({
      mnemonic: key
    });
  });
}

function recover(keyType, cryptoType, key, name, password) {
  return new Promise(resolve => {
    let keyPair = {};
    switch (keyType) {
      case "Mnemonic":
        keyPair = keyring.addFromMnemonic(key, {}, cryptoType);
        break;
      case "Raw Seed":
        if (isHex(key) && key.length === 66) {
          const SEEDu8a = hexToU8a(key);
          keyPair = keyring.addFromSeed(SEEDu8a, {}, cryptoType);
        } else if (key.length <= 32) {
          const SEED = key.padEnd(32, " ");
          keyPair = keyring.addFromSeed(stringToU8a(SEED), {}, cryptoType);
        }
        break;
      case "Keystore":
        keyPair = keyring.addFromJson(JSON.parse(key));
        break;
    }
    if (keyPair.address) {
      keyPair.setMeta({ name });
      const json = keyPair.toJson(password);
      json.name = name;
      resolve(json);
    } else {
      resolve({ address: "xxxxxxxxxxxx" });
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
