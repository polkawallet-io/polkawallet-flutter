import '../';
import { CustomTypes } from '../config/types';
import { getBalance, useWorker } from './worker';
import { TypeRegistry } from '@polkadot/types/create/registry';
import { Keyring } from '@polkadot/api';
import { cryptoWaitReady } from '@polkadot/util-crypto';
import { createType } from '@polkadot/types';
import { hexToU8a } from '@polkadot/util';
import { parseI64F64 } from '../utils/fixpointUtil';
import u8aToBn from '@polkadot/util/u8a/toBn';

describe('worker', () => {
  const WORKER_URL = 'wss://substratee03.scs.ch';
  let keyring;
  let registry;
  beforeAll(async () => {
    jest.setTimeout(90000);
    keyring = new Keyring({ type: 'sr25519' });
    registry = new TypeRegistry();
    registry.register(CustomTypes);
    window.api = { registry };
    window.workerEndpoint = WORKER_URL;
  });

  describe('getTotalIssuance method', () => {
    it('should return value', async () => {
      const cid = '3LjCHdiNbNLKEtwGtBf6qHGZnfKFyjLu9v3uxVgDL35C';
      const result = await useWorker(WORKER_URL).getTotalIssuance(cid);
      console.log('getTotalIssuance', result);
      expect(result).toBe(0);
    });
  });

  describe('getParticipantCount method', () => {
    it('should return value', async () => {
      const cid = '3LjCHdiNbNLKEtwGtBf6qHGZnfKFyjLu9v3uxVgDL35C';
      const result = await useWorker(WORKER_URL).getParticipantCount(cid);
      expect(result.toNumber()).toBe(0);
    });
  });

  describe('getMeetupCount method', () => {
    it('should return value', async () => {
      const cid = '3LjCHdiNbNLKEtwGtBf6qHGZnfKFyjLu9v3uxVgDL35C';
      const result = await useWorker(WORKER_URL).getMeetupCount(cid);
      console.log('getMeetupCount', result);
      expect(result.toNumber()).toBe(0);
    });
  });

  describe('getCeremonyReward method', () => {
    it('should return value', async () => {
      const cid = '3LjCHdiNbNLKEtwGtBf6qHGZnfKFyjLu9v3uxVgDL35C';
      const result = await useWorker(WORKER_URL).getCeremonyReward(cid);
      console.log('ceremonyReward', result);
      expect(result).toBe(1);
    });
  });

  describe('getLocationTolerance method', () => {
    it('should return value', async () => {
      const cid = '3LjCHdiNbNLKEtwGtBf6qHGZnfKFyjLu9v3uxVgDL35C';
      const result = await useWorker(WORKER_URL).getLocationTolerance(cid);
      expect(result.toNumber()).toBe(1000);
    });
  });

  describe('getTimeTolerance method', () => {
    it('should return value', async () => {
      const cid = '3LjCHdiNbNLKEtwGtBf6qHGZnfKFyjLu9v3uxVgDL35C';
      const result = await useWorker(WORKER_URL).getTimeTolerance(cid);
      expect(result.toNumber()).toBe(600000);
    });
  });

  describe('getBalance method', () => {
    it('should return value', async () => {
      await cryptoWaitReady();
      const cid = '3LjCHdiNbNLKEtwGtBf6qHGZnfKFyjLu9v3uxVgDL35C';
      const bob = keyring.addFromUri('//Bob', { name: 'Bob default' });
      const result = await useWorker(WORKER_URL).getBalance(bob, cid);
      console.log('getBalance', result);
      expect(result).toBeDefined();
    });
  });

  describe('getRegistration method', () => {
    it('should return value', async () => {
      await cryptoWaitReady();
      const cid = '3LjCHdiNbNLKEtwGtBf6qHGZnfKFyjLu9v3uxVgDL35C';
      const bob = keyring.addFromUri('//Bob', { name: 'Bob default' });
      const result = await useWorker(WORKER_URL).getRegistration(bob, cid);
      expect(result.toNumber()).toBe(0);
    });
  });

  describe('getMeetupIndexAndLocation method', () => {
    it('should return value', async () => {
      await cryptoWaitReady();
      const cid = '3LjCHdiNbNLKEtwGtBf6qHGZnfKFyjLu9v3uxVgDL35C';
      const bob = keyring.addFromUri('//Bob', { name: 'Bob default' });
      const result = await useWorker(WORKER_URL).getMeetupIndexAndLocation(bob, cid);
      expect(result.toJSON()).toStrictEqual([0, null]);
    });
  });

  describe('getAttestations method', () => {
    it('should return value', async () => {
      await cryptoWaitReady();
      const cid = '3LjCHdiNbNLKEtwGtBf6qHGZnfKFyjLu9v3uxVgDL35C';
      const bob = keyring.addFromUri('//Bob', { name: 'Bob default' });
      const result = await useWorker('wss://substratee03.scs.ch').getAttestations(bob, cid);
      expect(result.toJSON()).toStrictEqual([]);
    });
  });

  describe('parsesBalanceType', () => {
    it('should return value', async () => {
      await cryptoWaitReady();
      const balanceEnc = '0x014000000000000000000100000000000000';
      const balance = createType(registry, 'Option<Vec<u8>>', hexToU8a(balanceEnc)).unwrap();
      expect(parseI64F64(u8aToBn(balance))).toBe(1);
    });
  });
});
