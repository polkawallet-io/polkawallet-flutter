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
  // const props = await api.rpc.system.properties();
  // send("log", props);
  keyring.addFromJson({
    address: "HmyonjFVFZyg1mRjRvohVGRw9ouFDRoQ5ea9nDfH2Yi44qQ",
    encoded:
      "0x1eda9c1925ee1a00993684aead7b9be3372b41d4a67e18ff59a3d44cd1c389a923566559157e43183d0ffaca1ee933dc815a6a82a0b7d8872b96282a65b6999be88f791caa324cac86b4459a957e2600b388191ac86935e408bc2c1a33a70c9f528bb5fee8021b8def183fc1af806045849fffe2ef24c5d4a4690181f44ed5a41675a88ee813c7345c8230834515410e419c7e1a3716749b2930492072",
    encoding: {
      content: ["pkcs8", "sr25519"],
      type: "xsalsa20 - poly1305",
      version: 2
    },
    meta: { name: "test" },
    name: "test"
  });
  const res = await transfer(
    "HmyonjFVFZyg1mRjRvohVGRw9ouFDRoQ5ea9nDfH2Yi44qQ",
    "GvrJix8vF8iKgsTAfuazEDrBibiM6jgG66C6sT2W56cEZr3",
    20000000000,
    "a111111"
  );
  send("log", res);
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

function initKeys(accounts) {
  return new Promise(resolve => {
    accounts.forEach(i => keyring.addFromJson(i));
    resolve({
      success: true,
      accounts: accounts.map(i => i.address)
    });
  });
}

function getBalance(address) {
  return api.query.balances
    .freeBalance(address)
    .then(res => formatBalance(res));
}

function getBlockTime(blocks) {
  return new Promise(resolve => {
    const res = [];
    Promise.all(
      blocks.map(i => {
        res[res.length] = { id: i };
        return api.rpc.chain.getBlockHash(i);
      })
    )
      .then(hashs =>
        Promise.all(
          hashs.map((i, index) => {
            res[index]["hash"] = i.toHex();
            return api.query.timestamp.now.at(i.toHex());
          })
        )
      )
      .then(times => {
        times.forEach((i, index) => {
          res[index]["timestamp"] = i.toNumber();
        });
        resolve(JSON.stringify(res));
      });
  });
}

function transfer(from, to, amount, password) {
  return new Promise((resolve, reject) => {
    const keyPair = keyring.getPair(from);
    try {
      keyPair.decodePkcs8(password);
    } catch (err) {
      send("account.transfer.error", "invalid password");
      reject(err);
    }
    let unsub = () => {};
    const onStatusChange = result => {
      if (result.status.isFinalized) {
        resolve(result.status.asFinalized.toString());
        unsub();
      }
    };
    api.tx.balances
      .transfer(to, amount)
      .signAndSend(keyPair, onStatusChange)
      .then(res => {
        unsub = res;
      });
  });
}

window.account = {
  initKeys,
  gen,
  recover,
  getBalance,
  getBlockTime,
  transfer
};

function getNetworkConst() {
  return new Promise(resolve => {
    resolve({
      creationFee: api.consts.balances.creationFee.toNumber(),
      transferFee: api.consts.balances.transferFee.toNumber()
    });
  });
}

window.settings = {
  getNetworkConst
};
