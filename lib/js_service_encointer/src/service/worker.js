import { createType } from '@polkadot/types';
import WS from 'websocket';
import { assert, hexToU8a, u8aToBn, u8aToHex } from '@polkadot/util';
import * as bs58 from 'bs58';
import { CustomTypes } from '../config/types';
import * as fixPoint from '../utils/fixpointUtil';

import { Keyring } from '@polkadot/keyring';

const keyring = new Keyring({ ss58Format: 0, type: 'sr25519' });

const { w3cwebsocket: WebSocket } = WS;
const _workers = new Map();

const RQ_NAMES = Object.keys(CustomTypes.TrustedGetter._enum);

export const createTyped = (type, data) =>
  createType(api.registry, type, hexToU8a('0x'.concat(data)));

const parseBalance = data => {
  const balanceEntry = createType(api.registry, 'BalanceEntry<u32>', data);
  console.log('BalanceEntry: ' + balanceEntry);
  // Todo: apply demurrage
  return fixPoint.parseI64F64(balanceEntry.principal);
};

const parseU64 = data => {
  return createType(api.registry, 'u64', data);
};

const parseU32 = data => {
  return createType(api.registry, 'u32', data);
};

const parseBalanceType = data => {
  return fixPoint.parseI64F64(u8aToBn(data));
};

const parseParticipantIndex = data => {
  return createType(api.registry, 'ParticipantIndexType', data);
};

const parseMoment = data => {
  return createType(api.registry, 'Moment', data);
};

const parseAttestations = data => {
  return createType(api.registry, 'Vec<Attestation>', data);
};

const parseMeetupAssignment = data => {
  return createType(api.registry, '(MeetupIndexType, Option<Location>)', data);
};

/// Unpacks the value that is wrapped in all the Options and encoding from the worker.
/// Defaults to return `[]`, which is fine as `createType(api.registry, <type>, [])`
/// instantiates the <type> with its default value.
function unpack (packedValue) {
  const dataTyped = createTyped('Option<Vec<u8>>', packedValue)
    .unwrapOrDefault(); // (Option<Value.enc>.enc+whitespacePad)
  const trimmed = trimWhiteSpace(u8aToHex(dataTyped));
  return createType(api.registry, 'Option<Vec<u8>>', hexToU8a(trimmed))
    .unwrapOrDefault();
}
function trimWhiteSpace (data) {
  return data.replace(/(20)+$/, '');
}

function requestParams (address, shard) {
  return createType(api.registry, '(AccountId, CurrencyIdentifier)', [address, shard]);
}

function clientRequestGetter (cid, request) {
  const cidBin = u8aToHex(bs58.decode(cid));
  const getter = createType(api.registry, 'PublicGetter', {
    [request]: cidBin
  });
  const clientRq = createType(api.registry, 'ClientRequest', {
    StfState: [{ public: getter }, cidBin]
  });
  return clientRq.toU8a();
}

function clientRequestTrustedGetter (account, cid, request) {
  assert(RQ_NAMES.indexOf(request) !== -1, `Unknown request: ${request}`);
  const address = account.address;
  const cidBin = u8aToHex(bs58.decode(cid));
  const getter = createType(api.registry, 'TrustedGetter', {
    [request]: requestParams(address, cidBin)
  });
  const signature = account.sign(getter.toU8a());
  const clientRq = createType(api.registry, 'ClientRequest', {
    StfState: [
      {
        trusted: { getter, signature }
      },
      cidBin
    ]
  });
  return clientRq.toU8a();
}

export class Worker {
  constructor (url) {
    this.wsPromise = new Promise((resolve, reject) => {
      this.ws = new WebSocket(url);
      this.ws.onopen = () => resolve(this.ws);
      this.ws.onerror = () => reject(this.ws);
      this.ws.onclose = () => {
        this.ws.onclose = null;
        this.ws.onerror = null;
        this.ws.onopen = null;
        this.ws.onmessage = null;
      };
    });
  }

  isClosed () {
    return this.ws.readyState === this.ws.CLOSED || this.ws.readyState === this.ws.CLOSING;
  }

  isReady () {
    return new Promise((resolve, reject) => {
      if (this.ws.readyState === this.ws.CONNECTING) {
        this.wsPromise
          .then(ws => resolve(ws.readyState === ws.OPEN))
          .catch(ws => {
            const reason = ws.CLOSING ? 'ws closing' : 'ws closed';
            reject(reason);
          });
      } else {
        resolve(this.ws.readyState === this.ws.OPEN);
      }
    });
  }

  sendRequest (requestData, parse) {
    if (this.ws.onmessage) {
      return Promise.reject(new Error('worker can\'t handle parallel requests. please call getters sequentially'));
    } else {
      return new Promise((resolve, reject) => {
        const handleSuccess = resp => {
          if (resp.data === 'Could not decode request') {
            reject(resp.data);
          } else {
            resolve(parse(unpack(resp.data)));
          }
          this.ws.onmessage = null;
          this.ws.onerror = null;
        };
        const handleError = err => {
          this.ws.onmessage = null;
          this.ws.onerror = null;
          reject(err);
        };
        this.ws.onmessage = handleSuccess;
        this.ws.onerror = handleError;

        this.wsPromise
          .then(ws => {
            ws.send(requestData);
          })
          .catch(reject);
      });
    }
  }

  getTotalIssuance (cid) {
    return this.sendRequest(clientRequestGetter(cid, 'total_issuance'), parseBalance);
  }

  getParticipantCount (cid) {
    return this.sendRequest(clientRequestGetter(cid, 'participant_count'), parseU64);
  }

  getMeetupCount (cid) {
    return this.sendRequest(clientRequestGetter(cid, 'meetup_count'), parseU64);
  }

  getCeremonyReward (cid) {
    return this.sendRequest(clientRequestGetter(cid, 'ceremony_reward'), parseBalanceType);
  }

  getLocationTolerance (cid) {
    return this.sendRequest(clientRequestGetter(cid, 'location_tolerance'), parseU32);
  }

  getTimeTolerance (cid) {
    return this.sendRequest(clientRequestGetter(cid, 'time_tolerance'), parseMoment);
  }

  getBalance (account, cid) {
    return this.sendRequest(clientRequestTrustedGetter(account, cid, 'balance'), parseBalance);
  }

  getRegistration (account, cid) {
    return this.sendRequest(clientRequestTrustedGetter(account, cid, 'registration'), parseParticipantIndex);
  }

  getMeetupIndexAndLocation (account, cid) {
    return this.sendRequest(clientRequestTrustedGetter(account, cid, 'meetup_index_and_location'), parseMeetupAssignment);
  }

  getAttestations (account, cid) {
    return this.sendRequest(clientRequestTrustedGetter(account, cid, 'attestations'), parseAttestations);
  }
}

export function useWorker (node) {
  let worker = _workers.get(node);
  if (!worker || worker.isClosed()) {
    worker = new Worker(node);
    _workers.set(node, worker);
  }
  return worker;
}

// wrappers to fetch account from keyring
export function getBalance (pubKey, cid, password) {
  const keyPair = keyring.getPair(hexToU8a(pubKey));
  try {
    keyPair.decodePkcs8(password);
  } catch (err) {
    return new Promise((resolve, reject) => {
      resolve({ error: 'password check failed' });
    });
  }
  return useWorker(window.workerEndpoint).getBalance(keyPair, cid);
}

export default {
  useWorker,
  getBalance,
  createTyped
};
