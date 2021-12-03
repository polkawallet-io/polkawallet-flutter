/**
 * @jest-environment jsdom
 */

import '../../src';
import account from '../../src/service/account';
import { cryptoWaitReady } from '@polkadot/util-crypto';
import { gesellNetwork, localDockerNetwork } from '../testUtils/networks';
import { testSetup } from '../testUtils/testSetup';
import { Keyring } from '@polkadot/api';

describe('account', () => {
  const network = localDockerNetwork();
  let keyring;
  beforeAll(async () => {
    await testSetup(network);
    keyring = new Keyring({ type: 'sr25519' });
  });

  describe('faucet', () => {
    it('has enough funds', async () => {
      await cryptoWaitReady();
      const alice = keyring.addFromUri('//Alice', { name: 'Alice default' });
      const balance = await account.getBalance(alice.address);
      const faucetTransferValue = 0.0001 * Math.pow(10, 12);
      expect(parseInt(balance.freeBalance)).toBeGreaterThan(faucetTransferValue);
    });
  });
});
