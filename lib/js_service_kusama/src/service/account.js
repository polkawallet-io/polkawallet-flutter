import {
  keyExtractSuri,
  mnemonicGenerate,
  cryptoWaitReady
} from "@polkadot/util-crypto";
import { hexToU8a, u8aToHex, formatBalance } from "@polkadot/util";
import generateIcon from "@polkadot/ui-shared/polkadotIcon";

import { Keyring } from "@polkadot/keyring";
let keyring = new Keyring({ ss58Format: -1, type: "sr25519" });
let currentSS58Format = -1;

function gen() {
  return new Promise(resolve => {
    const key = mnemonicGenerate();
    resolve({
      mnemonic: key
    });
  });
}

async function genIcons(addresses) {
  return addresses.map(i => {
    const circles = generateIcon(i)
      .map(
        ({ cx, cy, fill, r }) =>
          `<circle cx='${cx}' cy='${cy}' fill='${fill}' r='${r}' />`
      )
      .join("");
    return [
      i,
      `<svg viewBox='0 0 64 64' xmlns='http://www.w3.org/2000/svg'>${circles}</svg>`
    ];
  });
}

async function genPubKeyIcons(pubKeys) {
  const icons = await genIcons(
    pubKeys.map(key => keyring.encodeAddress(hexToU8a(key), currentSS58Format))
  );
  return icons.map((i, index) => {
    i[0] = pubKeys[index];
    return i;
  });
}

function recover(keyType, cryptoType, key, password) {
  return new Promise((resolve, reject) => {
    let keyPair = {};
    let mnemonic = "";
    let rawSeed = "";
    switch (keyType) {
      case "Mnemonic":
        keyPair = keyring.addFromMnemonic(key, {}, cryptoType);
        mnemonic = key;
        break;
      case "Raw Seed":
        keyPair = keyring.addFromUri(key, {}, cryptoType);
        rawSeed = key;
        break;
      case "Keystore":
        const keystore = JSON.parse(key);
        keyPair = keyring.addFromJson(keystore);
        try {
          keyPair.decodePkcs8(password);
        } catch (err) {
          resolve(null);
        }
        resolve({
          pubKey: u8aToHex(keyPair.publicKey),
          ...keyPair.toJson(password)
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
        mnemonic,
        rawSeed,
        ...json
      });
    } else {
      resolve(null);
    }
  });
}

async function initKeys(accounts, ss58Format) {
  await cryptoWaitReady();
  currentSS58Format = ss58Format;
  await keyring.setSS58Format(ss58Format);
  return accounts.map(i => {
    const keyPair = keyring.addFromJson(i);
    return {
      address: keyring.encodeAddress(keyPair.publicKey, ss58Format),
      pubKey: u8aToHex(keyPair.publicKey)
    };
  });
}

async function decodeAddress(addresses) {
  await cryptoWaitReady();
  return addresses.map(i => {
    return {
      address: i,
      pubKey: u8aToHex(keyring.decodeAddress(i))
    };
  });
}

async function queryAccountsBonded(pubKeys) {
  return Promise.all(
    pubKeys
      .map(key => keyring.encodeAddress(hexToU8a(key), currentSS58Format))
      .map(i =>
        Promise.all([api.query.staking.bonded(i), api.query.staking.ledger(i)])
      )
  ).then(ls =>
    ls.map((i, index) => [pubKeys[index], i[0], i[1] ? i[1].raw.stash : null])
  );
}

function getBalance(address) {
  return api.query.system
    .account(address)
    .then(res =>
      formatBalance(res.data.free, { forceUnit: "-", withSi: false })
    );
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
    const keyPair = keyring.getPair(hexToU8a(txInfo.pubKey));
    try {
      keyPair.decodePkcs8(txInfo.password);
    } catch (err) {
      resolve(null);
    }
    let unsub = () => {};
    const onStatusChange = result => {
      if (result.status.isInBlock) {
        resolve({ hash: result.status.asInBlock.toHex() });
        unsub();
      } else {
        window.send("txStatusChange", result.status.type);
      }
    };
    const tx = api.tx[txInfo.module][txInfo.call](...paramList);
    tx.signAndSend(keyPair, onStatusChange)
      .then(res => {
        unsub = res;
      })
      .catch(err => {
        resolve(null);
        // reject(err.message);
      });
  });
}

function checkPassword(pubKey, pass) {
  return new Promise((resolve, reject) => {
    const keyPair = keyring.getPair(hexToU8a(pubKey));
    try {
      if (!keyPair.isLocked) {
        keyPair.lock();
      }
      keyPair.decodePkcs8(pass);
    } catch (err) {
      resolve(null);
      // reject(err);
    }
    resolve({ success: true });
  });
}

function changePassword(pubKey, passOld, passNew) {
  const u8aKey = hexToU8a(pubKey);
  return new Promise((resolve, reject) => {
    const keyPair = keyring.getPair(u8aKey);
    try {
      if (!keyPair.isLocked) {
        keyPair.lock();
      }
      keyPair.decodePkcs8(passOld);
    } catch (err) {
      resolve(null);
      // reject(err);
    }
    const json = keyPair.toJson(passNew);
    keyring.removePair(u8aKey);
    keyring.addFromJson(json);
    resolve({
      pubKey: u8aToHex(keyPair.publicKey),
      ...json
    });
  });
}

async function resetSS58Format(format) {
  const keys = keyring.getPairs();

  currentSS58Format = format;
  await keyring.setSS58Format(format);
  const res = keys.map(key => ({
    address: keyring.encodeAddress(key.publicKey, format),
    pubKey: u8aToHex(key.publicKey)
  }));

  return res;
}

async function checkDerivePath(seed, derivePath, pairType) {
  try {
    const { path } = keyExtractSuri(`${seed}${derivePath}`);
    // we don't allow soft for ed25519
    if (pairType === "ed25519" && path.some(({ isSoft }) => isSoft)) {
      return "Soft derivation paths are not allowed on ed25519";
    }
  } catch (error) {
    return error.message;
  }
  return null;
}

export default {
  initKeys,
  decodeAddress,
  gen,
  genIcons,
  genPubKeyIcons,
  recover,
  queryAccountsBonded,
  getBalance,
  getAccountIndex,
  getBlockTime,
  sendTx,
  checkPassword,
  changePassword,
  resetSS58Format,
  checkDerivePath
};
