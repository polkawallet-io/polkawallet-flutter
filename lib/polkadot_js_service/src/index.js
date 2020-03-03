import "@babel/polyfill";
import { mnemonicGenerate, cryptoWaitReady } from "@polkadot/util-crypto";
import {
  isHex,
  hexToU8a,
  stringToU8a,
  u8aToHex,
  formatBalance
} from "@polkadot/util";
import { WsProvider, ApiPromise } from "@polkadot/api";
import staking from "./staking";
import gov from "./gov";
import registry from "./utils/registry";

import { Keyring } from "@polkadot/keyring";
let keyring = new Keyring({ ss58Format: -1, type: "sr25519" });

// send message to JSChannel: PolkaWallet
function send(path, data) {
  if (window.location.href === "about:blank") {
    PolkaWallet.postMessage(JSON.stringify({ path, data }));
  } else {
    console.log(path, data);
  }
}
send("log", "main js loaded");
window.send = send;

function connect(endpoint) {
  return ApiPromise.create({ provider: new WsProvider(endpoint), registry })
    .then(api => {
      window.api = api;
      // api.rpc.system.properties().then(res => {
      //   const prop = res.toJSON();
      //   send("log", `setSS58Format ${prop.ss58Format}`);
      //   resetSS58Format(prop.ss58Format);
      // });
      return "wss connect success";
    })
    .catch(err => {
      send("log", err.message);
      send("settings.connect", null);
    });
}

const test = async () => {
  // const props = await api.rpc.system.properties();
  // send("log", props);
};

function getNetworkConst() {
  return new Promise(resolve => {
    resolve({
      creationFee: api.consts.balances.creationFee.toNumber(),
      transferFee: api.consts.balances.transferFee.toNumber()
    });
  });
}

function changeEndpoint(endpoint) {
  try {
    send("log", "disconnect");
    window.api.disconnect();
  } catch (err) {
    send("log", err.message);
  }
  return connect(endpoint);
}

async function resetSS58Format(format) {
  const keys = keyring.getPairs();

  await keyring.setSS58Format(format);
  const res = keys.map(key => ({
    address: keyring.encodeAddress(key.publicKey),
    pubKey: u8aToHex(key.publicKey)
  }));

  return res;
}

window.settings = {
  test,
  connect,
  getNetworkConst,
  changeEndpoint,
  resetSS58Format
};

function gen() {
  return new Promise(resolve => {
    const key = mnemonicGenerate();
    resolve({
      mnemonic: key
    });
  });
}

function recover(keyType, cryptoType, key, password) {
  return new Promise((resolve, reject) => {
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
        const keystore = JSON.parse(key);
        keyPair = keyring.addFromJson(keystore);
        try {
          keyPair.decodePkcs8(password);
        } catch (err) {
          send("account.recover", null);
          reject(err);
        }
        resolve({
          pubKey: u8aToHex(keyPair.publicKey),
          ...keystore
        });
        break;
    }
    if (keyPair.address) {
      const json = keyPair.toJson(password);
      keyPair.lock();
      // try add to keyring again to avoid no encrypted data bug
      keyring.addFromJson(json);
      resolve({
        pubKey: u8aToHex(keyPair.publicKey),
        ...json
      });
    } else {
      send("account.recover", null);
    }
  });
}

async function initKeys(accounts, ss58Format) {
  await cryptoWaitReady();
  await keyring.setSS58Format(ss58Format);
  return accounts.map(i => {
    const keyPair = keyring.addFromJson(i);
    return {
      address: keyring.encodeAddress(keyPair.publicKey),
      pubKey: u8aToHex(keyPair.publicKey)
    };
  });
}

function getBalance(address) {
  return api.query.balances
    .freeBalance(address)
    .then(res => formatBalance(res, { forceUnit: "-", withSi: false }));
}

function getAccountIndex(addresses) {
  return api.derive.accounts.indexes().then(res => {
    return Promise.all(addresses.map(i => api.derive.accounts.info(i)));
  });
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

function sendTx(txInfo, paramList) {
  return new Promise((resolve, reject) => {
    const address = keyring.decodeAddress(hexToU8a(txInfo.pubKey));
    const keyPair = keyring.getPair(address);
    try {
      keyPair.decodePkcs8(txInfo.password);
    } catch (err) {
      send("account.sendTx", null);
      reject(err);
    }
    let unsub = () => {};
    const onStatusChange = result => {
      if (result.status.isInBlock) {
        resolve({ hash: result.status.asInBlock.toString() });
        unsub();
      }
    };
    const tx = api.tx[txInfo.module][txInfo.call](...paramList);
    tx.signAndSend(keyPair, onStatusChange)
      .then(res => {
        unsub = res;
      })
      .catch(err => {
        send("account.sendTx", null);
        reject(err.message);
      });
  });
}

function checkPassword(pubKey, pass) {
  const address = keyring.decodeAddress(hexToU8a(pubKey));
  return new Promise((resolve, reject) => {
    const keyPair = keyring.getPair(address);
    try {
      if (!keyPair.isLocked) {
        keyPair.lock();
      }
      keyPair.decodePkcs8(pass);
    } catch (err) {
      send("account.checkPassword", null);
      reject(err);
    }
    resolve({ success: true });
  });
}

function changePassword(pubKey, passOld, passNew) {
  const address = keyring.decodeAddress(hexToU8a(pubKey));
  return new Promise((resolve, reject) => {
    const keyPair = keyring.getPair(address);
    try {
      if (!keyPair.isLocked) {
        keyPair.lock();
      }
      keyPair.decodePkcs8(passOld);
    } catch (err) {
      send("account.changePassword", null);
      reject(err);
    }
    const json = keyPair.toJson(passNew);
    keyring.removePair(address);
    keyring.addFromJson(json);
    resolve({
      pubKey: u8aToHex(keyPair.publicKey),
      ...json
    });
  });
}

window.account = {
  initKeys,
  gen,
  recover,
  getBalance,
  getAccountIndex,
  getBlockTime,
  sendTx,
  checkPassword,
  changePassword
};

window.staking = staking;
window.gov = gov;
