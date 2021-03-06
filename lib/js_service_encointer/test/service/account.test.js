import '../../src';
import account from '../../src/service/account';
import { ApiPromise, Keyring } from '@polkadot/api';
import { cryptoWaitReady } from '@polkadot/util-crypto';
import { WsProvider } from '@polkadot/rpc-provider';
import { gesellNetwork, localDockerNetwork } from '../testUtils/networks';
import { options } from '@encointer/node-api';

describe('account', () => {
  const network = localDockerNetwork();
  let keyring;
  beforeAll(async () => {
    jest.setTimeout(90000);
    window.send = (_, data) => console.log(data);
    keyring = new Keyring({ type: 'sr25519' });
    const provider = new WsProvider(network.chain);
    try {
      window.api = await ApiPromise.create({
        ...options({
          types: network.customTypes
        }),
        provider: provider
      });
      send('log', `${network.chain} wss connected success`);
    } catch (err) {
      send('log', `connect ${network.chain} failed`);
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
