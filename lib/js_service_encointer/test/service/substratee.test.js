/**
 * @jest-environment jsdom
 */

'use strict';

import { beforeAll, describe, it, } from '@jest/globals';
import { cantillonNetwork, localDockerNetwork } from '../testUtils/networks';

import substratee from '../../src/service/substratee';
import { base58Decode } from '@polkadot/util-crypto/base58/bs58';

import { JSDOM } from 'jsdom';
import { testSetup } from '../testUtils/testSetup';
const { window } = new JSDOM();
global.window = window;

// we skip it as we don't have a node with the teerex pallet-currently.
//
// todo: rename all this stuff to teerex.
describe.skip('substratee', () => {
  const network = localDockerNetwork();
  beforeAll(async () => {
    await testSetup(network);
  }, 90000);

  it('getEnclave works', async () => {
    // remember: indexes start at one on-chain
    const enclave = await substratee.getEnclave(1);
    expect(enclave.timestamp.toNumber()).toBeGreaterThan(0);
  });

  it('getEnclaveCount works', async () => {
    const count = await substratee.getEnclaveCount();
    expect(count.toNumber()).toBeGreaterThan(0);
  });

  it('getEnclaveIndex works', async () => {
    const enclave = await substratee.getEnclave(1);
    const count = await substratee.getEnclaveIndex(enclave.pubkey);
    expect(count.toNumber()).toBe(1);
  });

  it('getLatestIpfsHash works', async () => {
    const hash = await substratee.getLatestIpfsHash(base58Decode.decode(network.chosenCid));
    console.log(hash);
    expect(hash.length).toBeGreaterThan(0);
  });

  it('getWorkerIndexForShard works', async () => {
    const wIndex = await substratee.getWorkerIndexForShard(base58Decode.decode(network.chosenCid));
    console.log(wIndex);
    expect(wIndex.toNumber()).toBeGreaterThan(0);
  });
});
