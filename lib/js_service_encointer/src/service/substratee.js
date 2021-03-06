'use strict';

async function getEnclave (index) {
  const enclave = await api.query.substrateeRegistry.enclaveRegistry(index);
  return api.createType('Enclave', enclave);
}

async function getEnclaveCount () {
  return await api.query.substrateeRegistry.enclaveCount();
}

async function getEnclaveIndex (enclavePubKey) {
  return await api.query.substrateeRegistry.enclaveIndex(enclavePubKey);
}

async function getLatestIpfsHash (shard) {
  const hash = await api.query.substrateeRegistry.latestIpfsHash(shard);
  return api.createType('Hash', hash);
}

async function getWorkerIndexForShard (shard) {
  return await api.query.substrateeRegistry.workerForShard(shard);
}

async function getConfirmedCalls (callHash) {
  return await api.query.substrateeRegistry.confirmedCalls(callHash);
}

export default {
  getEnclave,
  getEnclaveCount,
  getEnclaveIndex,
  getLatestIpfsHash,
  getWorkerIndexForShard,
  getConfirmedCalls
};
