import "@babel/polyfill";
import { mnemonicGenerate, cryptoWaitReady } from "@polkadot/util-crypto";
import { isHex, hexToU8a, stringToU8a, formatBalance } from "@polkadot/util";
import { WsProvider, ApiPromise } from "@polkadot/api";

import { Keyring } from "@polkadot/keyring";
let keyring = {};
cryptoWaitReady().then(() => {
  keyring = new Keyring({ ss58Format: -1, type: "sr25519" });
  send("log", "wasm-crypto initialized");
});

// send message to JSChannel: PolkaWallet
function send(path, data) {
  // console.log(path, data);
  PolkaWallet.postMessage(JSON.stringify({ path, data }));
}
send("log", "main js loaded");

function connect(endpoint) {
  return ApiPromise.create({ provider: new WsProvider(endpoint) })
    .then(api => {
      window.api = api;
      keyring = new Keyring({ ss58Format: -1, type: "sr25519" });
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
  if (window.api._isConnected.value) {
    send("log", "disconnect");
    window.api.disconnect();
  }
  return connect(endpoint);
}

window.settings = {
  test,
  connect,
  getNetworkConst,
  changeEndpoint
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
        keyPair = keyring.addFromJson(JSON.parse(key));
        try {
          keyPair.decodePkcs8(password);
        } catch (err) {
          send("account.recover.error", "invalid password");
          reject(err);
        }
        break;
    }
    if (keyPair.address) {
      const json = keyPair.toJson(password);
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
    .then(res => formatBalance(res, { forceUnit: "-", withSi: false }));
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

function sendTx(params) {
  var txHandlers = {
    balances: {
      transfer: params => api.tx.balances.transfer(params.to, params.amount)
    },
    staking: {
      bond: params =>
        api.tx.staking.bond(params.from, params.amount, params.to),
      bondExtra: params => api.tx.staking.bondExtra(params.amount),
      unbond: params => api.tx.staking.unbond(params.amount),
      nominate: params => api.tx.staking.nominate(params.targets),
      setPayee: params => api.tx.staking.setPayee(params.to),
      chill: () => api.tx.staking.chill()
    }
  };
  return new Promise((resolve, reject) => {
    const keyPair = keyring.getPair(params.from);
    try {
      keyPair.decodePkcs8(params.password);
    } catch (err) {
      send("account.sendTx", null);
      reject(err);
    }
    let unsub = () => {};
    const onStatusChange = result => {
      if (result.status.isFinalized) {
        resolve({ hash: result.status.asFinalized.toString() });
        unsub();
      }
    };
    const tx = txHandlers[params.module][params.call](params);
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

function transfer(from, to, amount, password) {
  return new Promise((resolve, reject) => {
    const keyPair = keyring.getPair(from);
    try {
      keyPair.decodePkcs8(password);
    } catch (err) {
      send("account.transfer", null);
      reject(err);
    }
    let unsub = () => {};
    const onStatusChange = result => {
      if (result.status.isFinalized) {
        resolve({ hash: result.status.asFinalized.toString() });
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

function checkPassword(address, pass) {
  return new Promise((resolve, reject) => {
    const keyPair = keyring.getPair(address);
    try {
      keyPair.decodePkcs8(pass);
    } catch (err) {
      send("account.checkPassword", null);
      reject(err);
    }
    resolve({ success: true });
  });
}

function changePassword(address, passOld, passNew) {
  return new Promise((resolve, reject) => {
    const keyPair = keyring.getPair(address);
    try {
      keyPair.decodePkcs8(passOld);
    } catch (err) {
      send("account.changePassword", null);
      reject(err);
    }
    const json = keyPair.toJson(passNew);
    keyring.removePair(address);
    keyring.addFromJson(json);
    resolve(json);
  });
}

window.account = {
  initKeys,
  gen,
  recover,
  getBalance,
  getBlockTime,
  transfer,
  sendTx,
  checkPassword,
  changePassword
};
