import { cryptoWaitReady, keyExtractSuri, mnemonicGenerate } from '@polkadot/util-crypto';
import { hexToU8a, u8aToHex, hexToString, assert, u8aToBuffer, bufferToU8a, compactAddLength } from '@polkadot/util';
import { ss58Decode } from 'oo7-substrate/src/ss58';
import { polkadotIcon } from '@polkadot/ui-shared';
import BN from 'bn.js';
import {
  parseQrCode,
  getSigner,
  makeTx,
  getSubmittable
} from '../utils/QrSigner';

import { Keyring } from '@polkadot/keyring';
import { createType, i128 } from '@polkadot/types';
import { encodeFloatToI64F64, parseI64F64, toI64F64 } from '@encointer/util';
import { TrustedCallMap } from '../config/trustedCall';
import { bs58 } from '@polkadot/util-crypto/base58/bs58';
import { callWorker, encointerBalances, substrateeRegistry, transfer } from '../config/consts';

export const keyring = new Keyring({ ss58Format: 0, type: 'sr25519' });

async function gen () {
  await cryptoWaitReady();
  return new Promise((resolve) => {
    const key = mnemonicGenerate();
    resolve({
      mnemonic: key
    });
  });
}

async function genIcons (addresses) {
  return addresses.map((i) => {
    const circles = polkadotIcon(i, { isAlternativeL: false })
      .map(
        ({ cx, cy, fill, r }) =>
          `<circle cx='${cx}' cy='${cy}' fill='${fill}' r='${r}' />`
      )
      .join('');
    return [
      i,
      `<svg viewBox='0 0 64 64' xmlns='http://www.w3.org/2000/svg'>${circles}</svg>`
    ];
  });
}

async function genPubKeyIcons (pubKeys) {
  const icons = await genIcons(
    pubKeys.map((key) => keyring.encodeAddress(hexToU8a(key), 2))
  );
  return icons.map((i, index) => {
    i[0] = pubKeys[index];
    return i;
  });
}

function recover (keyType, cryptoType, key, password) {
  return new Promise((resolve, reject) => {
    let keyPair = {};
    let mnemonic = '';
    let rawSeed = '';
    try {
      switch (keyType) {
        case 'mnemonic':
          keyPair = keyring.addFromMnemonic(key, {}, cryptoType);
          mnemonic = key;
          break;
        case 'rawSeed':
          keyPair = keyring.addFromUri(key, {}, cryptoType);
          rawSeed = key;
          break;
        case 'keystore':
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
    } catch (err) {
      resolve({ error: err.message });
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
async function initKeys (accounts, ss58Formats) {
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
 * Decode address to it's publicKey
 * @param {List<String>} addresses
 * @returns {Map<String, String>} pubKeyAddressMap
 */
async function decodeAddress (addresses) {
  await cryptoWaitReady();
  try {
    const res = {};
    addresses.forEach((i) => {
      const pubKey = u8aToHex(keyring.decodeAddress(i));
      res[pubKey] = i;
    });
    return res;
  } catch (err) {
    send('log', { error: err.message });
    return null;
  }
}

/**
 * encode pubKey to addresses with different prefixes
 * @param {List<String>} pubKeys
 * @returns {Map<String, String>} pubKeyAddressMap
 */
async function encodeAddress (pubKeys, ss58Formats) {
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

async function queryAddressWithAccountIndex (accIndex, ss58) {
  const num = ss58Decode(accIndex, ss58).toJSON();
  const res = await api.query.indices.accounts(num.data);
  return res;
}

async function queryAccountsBonded (pubKeys) {
  return Promise.all(
    pubKeys
      .map((key) => keyring.encodeAddress(hexToU8a(key), 2))
      .map((i) =>
        Promise.all([api.query.staking.bonded(i), api.query.staking.ledger(i)])
      )
  ).then((ls) =>
    ls.map((i, index) => [
      pubKeys[index],
      i[0],
      i[1].toHuman() ? i[1].toHuman().stash : null
    ])
  );
}

/**
 * get ERT balance of an address
 * @param {String} address
 * @returns {String} balance
 */
async function getBalance (address) {
  const all = await api.derive.balances.all(address);
  const lockedBreakdown = all.lockedBreakdown.map((i) => {
    return {
      ...i,
      use: hexToString(i.id.toHex())
    };
  });
  return {
    ...all,
    lockedBreakdown
  };
}

/**
 * subscribes to ERT balance of an address
 * @param msgChannel channel that the message handler uses on the dart side
 * @param {String} address
 * @returns {String} balance
 */
async function subscribeBalance (msgChannel, address) {
  return await api.derive.balances.all(address, (all) => {
    const lockedBreakdown = all.lockedBreakdown.map((i) => {
      return {
        ...i,
        use: hexToString(i.id.toHex())
      };
    });
    send(msgChannel, {
      ...all,
      lockedBreakdown
    });
  }).then((unsub) => unsubscribe(unsub, msgChannel));
}

function unsubscribe (unsub, msgChannel) {
  const unsubFuncName = `unsub${msgChannel}`;
  window[unsubFuncName] = unsub;
  return {};
}

function getAccountIndex (addresses) {
  return api.derive.accounts.indexes().then((res) => {
    return Promise.all(addresses.map((i) => api.derive.accounts.info(i)));
  });
}

function getBlockTime (blocks) {
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
            res[index].hash = i.toHex();
            return api.query.timestamp.now.at(i.toHex());
          })
        )
      )
      .then((times) => {
        times.forEach((i, index) => {
          res[index].timestamp = i.toNumber();
        });
        resolve(JSON.stringify(res));
      });
  });
}

export async function txFeeEstimate (txInfo, paramList) {
  if (txInfo.module === 'encointerBalances' && txInfo.call === 'transfer') {
    paramList[2] = encodeFloatToI64F64(parseFloat(paramList[2]));
  }

  let dispatchInfo;
  if (window.settings.connectedToTeeProxy() && TrustedCallMap[txInfo.module][txInfo.call] !== null) {
    if (isTcIsRegisterAttestations(txInfo)) {
      // todo: in a meetup with more than 3 people this is longer. calculate actual size based on message length.
      dispatchInfo = dispatchInfo = api.tx[substrateeRegistry][callWorker](new Array(768))
        .paymentInfo(txInfo.address);
    } else {
      dispatchInfo = api.tx[substrateeRegistry][callWorker](new Array(384))
        .paymentInfo(txInfo.address);
    }
  } else {
    dispatchInfo = await api.tx[txInfo.module][txInfo.call](...paramList)
      .paymentInfo(txInfo.address);
  }
  return dispatchInfo;
}

function isTcIsRegisterAttestations (txInfo) {
  return TrustedCallMap[txInfo.module][txInfo.call] === 'ceremonies_register_attestations';
}

function _extractEvents (api, result) {
  if (!result || !result.events) {
    return;
  }

  let success = false;
  let error;
  result.events
    .filter((event) => !!event.event)
    .map(({ event: { data, method, section } }) => {
      if (section === 'system' && method === 'ExtrinsicFailed') {
        const [dispatchError] = data;
        let message = dispatchError.type;

        if (dispatchError.isModule) {
          try {
            const mod = dispatchError.asModule;
            const error = api.registry.findMetaError(
              new Uint8Array([mod.index.toNumber(), mod.error.toNumber()])
            );

            message = `${error.section}.${error.name}`;
          } catch (error) {
            // swallow error
          }
        }
        window.send('txUpdateEvent', {
          title: `${section}.${method}`,
          message
        });
        error = message;
      } else {
        window.send('txUpdateEvent', {
          title: `${section}.${method}`,
          message: 'ok'
        });
        if (section == 'system' && method == 'ExtrinsicSuccess') {
          success = true;
        }
      }
    });
  return { success, error };
}

export function sendTx (txInfo, paramList) {
  const keyPair = keyring.getPair(hexToU8a(txInfo.pubKey));
  try {
    keyPair.decodePkcs8(txInfo.password);
  } catch (err) {
    return new Promise((resolve, reject) => {
      resolve({ error: 'password check failed' });
    });
  }

  if (window.settings.connectedToTeeProxy() && TrustedCallMap[txInfo.module][txInfo.call] !== null) {
    return _sendTrustedTx(keyPair, txInfo, paramList);
  }

  return _sendTx(keyPair, txInfo, paramList);
}

/**
 * Internal send txMethod. Simplifies testing as we can pass a ready to sign account from the keyring
 */
function _sendTx (keyPair, txInfo, paramList) {
  return new Promise((resolve) => {
    let unsub = () => {};

    if (txInfo.module === encointerBalances && txInfo.call === transfer) {
      paramList[2] = api.createType('i128', encodeFloatToI64F64(parseFloat(paramList[2])));
    }

    const tx = api.tx[txInfo.module][txInfo.call](...paramList);
    const onStatusChange = (result) => {
      if (result.status.isInBlock || result.status.isFinalized) {
        const { success, error } = _extractEvents(api, result);
        if (success) {
          if (txInfo.module === encointerBalances && txInfo.call === transfer) {
            paramList[2] = parseI64F64(paramList[2]);
          }

          resolve({
            hash: tx.hash.toString(),
            time: new Date().getTime(),
            params: paramList
          });
        }
        if (error) {
          resolve({ error });
        }
        unsub();
      } else {
        window.send('txStatusChange', result.status.type);
      }
    };
    if (txInfo.isUnsigned) {
      tx.send(onStatusChange)
        .then((res) => {
          unsub = res;
        })
        .catch((err) => {
          resolve({ error: err.message });
        });
      return;
    }

    tx.signAndSend(keyPair, { tip: new BN(txInfo.tip, 10) }, onStatusChange)
      .then((res) => {
        unsub = res;
      })
      .catch((err) => {
        resolve({ error: err.message });
      });
  });
}

export function _sendTrustedTx (keyPair, txInfo, paramList) {
  const cid = api.createType('CommunityIdentifier', txInfo.cid);
  window.send('js-trustedTx', 'sending trusted tx for cid: ' + cid);

  const mrenclave = api.createType('Hash', bs58.decode(window.mrenclave));

  const nonce = api.createType('u32', 0);
  const call = createTrustedCall(
    keyPair,
    cid,
    mrenclave,
    nonce,
    TrustedCallMap[txInfo.module][txInfo.call],
    [keyPair.publicKey, ...paramList]
  );

  const cypherTextBuffer = window.workerShieldingKey.encrypt(u8aToBuffer(call.toU8a()));
  const cypherArray = bufferToU8a(cypherTextBuffer);
  const c = api.createType('Vec<u8>', compactAddLength(cypherArray));
  console.log('Encrypted trusted call. Length: ' + cypherArray.length);

  const txParams = [api.createType('Request', {
    shard: api.createType('ShardIdentifier', txInfo.cid),
    cyphertext: c
  })];

  console.log('txParams: ' + txParams);
  const txInfoCallWorker = {
    module: substrateeRegistry,
    call: callWorker,
    tip: 0
  };
  return _sendTx(keyPair, txInfoCallWorker, txParams);
}

export function createTrustedCall (account, cid, mrenclave, nonce, trustedCall, params) {
  const tCallType = api.registry.knownTypes.types.TrustedCall._enum[trustedCall];
  assert(tCallType !== undefined, `Unknown trusted call: ${trustedCall}`);

  console.log(`TrustedCall: ${tCallType}`);

  const call = createType(api.registry, 'TrustedCall', {
    [trustedCall]: createType(api.registry, tCallType, params)
  });

  const payload = [...call.toU8a(), ...nonce.toU8a(), ...mrenclave.toU8a(), ...cid.toU8a()];

  return createType(api.registry, 'TrustedCallSigned', {
    call: call,
    nonce: nonce,
    signature: account.sign(payload)
  });
}

export function sendFaucetTx (address, amount) {
  const alice = keyring.addFromUri('//Alice', { name: 'Alice default' });
  const paramList = [address, amount];
  const txInfo = {
    module: 'balances',
    call: 'transfer',
    tip: 0
  };
  return _sendTx(alice, txInfo, paramList);
}

/**
 * Signs the claimHex with the provided key.
 *
 * Note: Even though this is an Encointer function, I put it here as the keys need to be initialized via the initKey()
 * method, whose scope is apparently restricted to this module.
 * @param claimHex
 * @param pubKey
 * @param password
 * @returns {Promise<{Attestation, String}>} Runtime attestation struct and its hex Value
 */
export async function attestClaimOfAttendance (claimHex, pubKey, password) {
  send('js-attestClaimOfAttendance', `attestingClaimOfAttendance with claim: ${claimHex} pubKey: ${pubKey}, pwd: ${password}`);
  const keyPair = keyring.getPair(hexToU8a(pubKey));
  try {
    keyPair.decodePkcs8(password);
  } catch (err) {
    return new Promise((resolve, reject) => {
      resolve({ error: 'password check failed' });
    });
  }
  return _attestClaimOfAttendance(claimHex, keyPair);
}

/**
 * unit-testable function that does not need key fetch
 * @param claimHex
 * @param account
 * @returns {Promise<unknown>}
 * @private
 */
export async function _attestClaimOfAttendance (claimHex, account) {
  const registry = api.registry;
  const sign = await account.sign(hexToU8a(claimHex), { withType: true });
  console.log(u8aToHex(sign));

  const attest = createType(registry, 'Attestation', {
    claim: claimHex,
    signature: sign,
    public: account.publicKey
  });
  return new Promise((resolve, reject) => {
    //     resolve({ attestation: { ...attest.toJSON(), signature: u8aToHex(sign) }, attestationHex: u8aToHex(attest.toU8a()) });
    resolve({ attestation: attest, attestation_hex: u8aToHex(attest.toU8a()) });
  });
}

function checkPassword (pubKey, pass) {
  return new Promise((resolve) => {
    const keyPair = keyring.getPair(hexToU8a(pubKey));
    try {
      if (!keyPair.isLocked) {
        keyPair.lock();
      }
      keyPair.decodePkcs8(pass);
    } catch (err) {
      resolve(null);
    }
    resolve({ success: true });
  });
}

function changePassword (pubKey, passOld, passNew) {
  const u8aKey = hexToU8a(pubKey);
  return new Promise((resolve) => {
    const keyPair = keyring.getPair(u8aKey);
    try {
      if (!keyPair.isLocked) {
        keyPair.lock();
      }
      keyPair.decodePkcs8(passOld);
    } catch (err) {
      resolve(null);
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

async function checkDerivePath (seed, derivePath, pairType) {
  try {
    const { path } = keyExtractSuri(`${seed}${derivePath}`);
    // we don't allow soft for ed25519
    if (pairType === 'ed25519' && path.some(({ isSoft }) => isSoft)) {
      return 'Soft derivation paths are not allowed on ed25519';
    }
  } catch (error) {
    return error.message;
  }
  return null;
}

async function signAsync (password) {
  return new Promise((resolve) => {
    const { unsignedData } = getSigner();
    const keyPair = keyring.getPair(unsignedData.data.account);
    try {
      if (!keyPair.isLocked) {
        keyPair.lock();
      }
      keyPair.decodePkcs8(password);
      const payload = api.registry.createType(
        'ExtrinsicPayload',
        unsignedData.data.data,
        { version: api.extrinsicVersion }
      );
      const signed = payload.sign(keyPair);
      resolve(signed);
    } catch (err) {
      resolve({ error: err.message });
    }
  });
}

function addSignatureAndSend (address, signed) {
  return new Promise((resolve) => {
    const { tx, payload } = getSubmittable();
    if (tx.addSignature) {
      tx.addSignature(address, `0x${signed}`, payload);

      let unsub = () => {};
      const onStatusChange = (result) => {
        if (result.status.isInBlock || result.status.isFinalized) {
          const { success, error } = _extractEvents(api, result);
          if (success) {
            resolve({
              hash: tx.hash.hash.toHuman(),
              time: new Date().getTime()
            });
          }
          if (error) {
            resolve({ error });
          }
          unsub();
        } else {
          window.send('txStatusChange', result.status.type);
        }
      };

      tx.send(onStatusChange)
        .then((res) => {
          unsub = res;
        })
        .catch((err) => {
          resolve({ error: err.message });
        });
    } else {
      resolve({ error: 'invalid tx' });
    }
  });
}

/**
 * sign tx from dapp as extension
 * @param {String} password
 * @param {Map} json
 */
async function signTxAsExtension (password, json) {
  return new Promise((resolve) => {
    const keyPair = keyring.getPair(json.address);
    try {
      if (!keyPair.isLocked) {
        keyPair.lock();
      }
      keyPair.decodePkcs8(password);
      api.registry.setSignedExtensions(json.signedExtensions);
      const payload = api.registry.createType('ExtrinsicPayload', json, {
        version: json.version
      });
      const signed = payload.sign(keyPair);
      resolve(signed);
    } catch (err) {
      resolve({ error: err.message });
    }
  });
}

/**
 * sign bytes from dapp as extension
 * @param {String} password
 * @param {Map} json
 */
async function signBytesAsExtension (password, json) {
  return new Promise((resolve) => {
    const keyPair = keyring.getPair(json.address);
    try {
      if (!keyPair.isLocked) {
        keyPair.lock();
      }
      keyPair.decodePkcs8(password);
      resolve({
        signature: u8aToHex(keyPair.sign(hexToU8a(json.data)))
      });
    } catch (err) {
      resolve({ error: err.message });
    }
  });
}

export default {
  initKeys,
  encodeAddress,
  decodeAddress,
  queryAddressWithAccountIndex,
  gen,
  genIcons,
  genPubKeyIcons,
  recover,
  queryAccountsBonded,
  getBalance,
  subscribeBalance,
  getAccountIndex,
  getBlockTime,
  txFeeEstimate,
  sendTx,
  sendFaucetTx,
  checkPassword,
  changePassword,
  checkDerivePath,
  attestClaimOfAttendance,
  parseQrCode,
  signAsync,
  makeTx,
  addSignatureAndSend,
  signTxAsExtension,
  signBytesAsExtension
};
