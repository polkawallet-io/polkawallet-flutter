import {
  keyExtractSuri,
  mnemonicGenerate,
  cryptoWaitReady,
} from "@polkadot/util-crypto";
import { hexToU8a, u8aToHex, hexToString } from "@polkadot/util";
import generateIcon from "@polkadot/ui-shared/polkadotIcon";

import { Keyring } from "@polkadot/keyring";
let keyring = new Keyring({ ss58Format: 7, type: "sr25519" });

function gen() {
  return new Promise((resolve) => {
    const key = mnemonicGenerate();
    resolve({
      mnemonic: key,
    });
  });
}

async function genIcons(addresses) {
  return addresses.map((i) => {
    const circles = generateIcon(i)
      .map(
        ({ cx, cy, fill, r }) =>
          `<circle cx='${cx}' cy='${cy}' fill='${fill}' r='${r}' />`
      )
      .join("");
    return [
      i,
      `<svg viewBox='0 0 64 64' xmlns='http://www.w3.org/2000/svg'>${circles}</svg>`,
    ];
  });
}

async function genPubKeyIcons(pubKeys) {
  const icons = await genIcons(
    pubKeys.map((key) => keyring.encodeAddress(hexToU8a(key), 2))
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
      case "mnemonic":
        keyPair = keyring.addFromMnemonic(key, {}, cryptoType);
        mnemonic = key;
        break;
      case "rawSeed":
        keyPair = keyring.addFromUri(key, {}, cryptoType);
        rawSeed = key;
        break;
      case "keystore":
        const keystore = JSON.parse(key);
        keyPair = keyring.addFromJson(keystore);
        try {
          keyPair.decodePkcs8(password);
        } catch (err) {
          resolve(null);
        }
        resolve({
          pubKey: u8aToHex(keyPair.publicKey),
          ...keyPair.toJson(password),
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
        ...json,
      });
    } else {
      resolve(null);
    }
  });
}

/**
 * Add user's accounts to keyring incedence,
 * so user can use them to sign txs with password.
 * We use a list of ss58Formats to encode the accounts
 * into different address formats for different networks.
 *
 * @param {List<Keystore>} accounts
 * @param {List<int>} ss58Formats
 * @returns {Map<String, String>} pubKeyAddressMap
 */
async function initKeys(accounts, ss58Formats) {
  await cryptoWaitReady();
  const res = {};
  ss58Formats.forEach((ss58) => {
    res[ss58] = {};
  });

  accounts.forEach((i) => {
    // import account to keyring
    const keyPair = keyring.addFromJson(i);
    // then encode address into different ss58 formats
    ss58Formats.forEach((ss58) => {
      const pubKey = u8aToHex(keyPair.publicKey);
      res[ss58][pubKey] = keyring.encodeAddress(keyPair.publicKey, ss58);
    });
  });
  return res;
}

/**
 * decode address to it's publicKey
 * @param {List<String>} addresses
 * @returns {Map<String, String>} pubKeyAddressMap
 */
async function decodeAddress(addresses) {
  await cryptoWaitReady();
  const res = {};
  addresses.forEach((i) => {
    const pubKey = u8aToHex(keyring.decodeAddress(i));
    res[pubKey] = i;
  });
  return res;
}

/**
 * encode pubKey to addresses with different prefixes
 * @param {List<String>} pubKeys
 * @returns {Map<String, String>} pubKeyAddressMap
 */
async function encodeAddress(pubKeys, ss58Formats) {
  await cryptoWaitReady();
  const res = {};
  ss58Formats.forEach((ss58) => {
    res[ss58] = {};
    pubKeys.forEach((i) => {
      res[ss58][i] = keyring.encodeAddress(hexToU8a(i), ss58);
    });
  });
  return res;
}

async function queryAccountsBonded(pubKeys) {
  return Promise.all(
    pubKeys
      .map((key) => keyring.encodeAddress(hexToU8a(key), 2))
      .map((i) =>
        Promise.all([api.query.staking.bonded(i), api.query.staking.ledger(i)])
      )
  ).then((ls) =>
    ls.map((i, index) => [pubKeys[index], i[0], i[1] ? i[1]._raw.stash : null])
  );
}

/**
 * get EDG balance of an address
 * @param {String} address
 * @returns {Map} balances
 */
async function getBalance(address) {
  const all = await api.derive.balances.all(address);
  const lockedBreakdown = all.lockedBreakdown.map((i) => {
    return {
      ...i,
      use: hexToString(i.id.toHex()),
    };
  });
  return {
    ...all,
    lockedBreakdown,
  };
}

function getAccountIndex(addresses) {
  return api.derive.accounts.indexes().then((res) => {
    return Promise.all(addresses.map((i) => api.derive.accounts.info(i)));
  });
}

function getBlockTime(blocks) {
  return new Promise((resolve) => {
    const res = [];
    Promise.all(
      blocks.map((i) => {
        res[res.length] = { id: i };
        return api.rpc.chain.getBlockHash(i);
      })
    )
      .then((hashs) =>
        Promise.all(
          hashs.map((i, index) => {
            res[index]["hash"] = i.toHex();
            return api.query.timestamp.now.at(i.toHex());
          })
        )
      )
      .then((times) => {
        times.forEach((i, index) => {
          res[index]["timestamp"] = i.toNumber();
        });
        resolve(JSON.stringify(res));
      });
  });
}

async function txFeeEstimate(txInfo, paramList) {
  const dispatchInfo = await api.tx[txInfo.module]
    [txInfo.call](...paramList)
    .paymentInfo(txInfo.address);
  return dispatchInfo;
}

function sendTx(txInfo, paramList) {
  return new Promise((resolve, reject) => {
    const keyPair = keyring.getPair(hexToU8a(txInfo.pubKey));
    try {
      keyPair.decodePkcs8(txInfo.password);
    } catch (err) {
      resolve({ error: "password check failed" });
    }
    let unsub = () => {};
    const tx = api.tx[txInfo.module][txInfo.call](...paramList);
    const onStatusChange = (result) => {
      if (result.status.isInBlock || result.status.isFinalized) {
        resolve({ hash: tx.hash.hash.toHuman() });
        unsub();
      } else {
        window.send("txStatusChange", result.status.type);
      }
    };
    tx.signAndSend(keyPair, onStatusChange)
      .then((res) => {
        unsub = res;
      })
      .catch((err) => {
        resolve({ error: err.message });
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
      ...json,
    });
  });
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
  encodeAddress,
  decodeAddress,
  gen,
  genIcons,
  genPubKeyIcons,
  recover,
  queryAccountsBonded,
  getBalance,
  getAccountIndex,
  getBlockTime,
  txFeeEstimate,
  sendTx,
  checkPassword,
  changePassword,
  checkDerivePath,
};
