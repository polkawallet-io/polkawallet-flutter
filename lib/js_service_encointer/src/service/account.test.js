import '../';
import { CustomTypes } from '../config/types';
import account from './account';
import { TypeRegistry } from '@polkadot/types/create/registry';
import { ApiPromise, Keyring } from '@polkadot/api';
import { cryptoWaitReady } from '@polkadot/util-crypto';
import { WsProvider } from '@polkadot/rpc-provider';

describe('account', () => {
  const GESELL_URL = 'wss://gesell.encointer.org ';
  let keyring;
  let registry;
  beforeAll(async () => {
    jest.setTimeout(90000);
    keyring = new Keyring({ type: 'sr25519' });
    registry = new TypeRegistry();
    registry.register(CustomTypes);
    const provider = new WsProvider(GESELL_URL);
    try {
      window.api = await ApiPromise.create({
        provider,
        types: CustomTypes
      });
      send('log', `${GESELL_URL} wss connected success`);
    } catch (err) {
      send('log', `connect ${GESELL_URL} failed`);
      await provider.disconnect();
    }
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
