'use strict';

import { getCommunityIdentifiers } from '../src/service/encointer';
import account, { _sendTrustedTx } from '../src/service/account';
import { bufferToU8a, compactAddLength, hexToU8a, u8aToBuffer, u8aToHex } from '@polkadot/util';
import { ApiPromise, Keyring } from '@polkadot/api';
import { cryptoWaitReady } from '@polkadot/util-crypto';
import { EncointerWorker } from '@encointer/worker-api';
import * as bs58 from 'bs58';
import { createType } from '@polkadot/types';
import { getTrustedCall } from './testUtils/helpers';
import { beforeAll, describe, it, jest } from '@jest/globals';
import { cantillonNetwork, localDockerNetwork } from './testUtils/networks';
import WS from 'websocket';
import { WsProvider } from '@polkadot/rpc-provider';
import { options } from '@encointer/node-api';
import { pallets } from '../src/config/consts';

const { w3cwebsocket: WebSocket } = WS;

describe('cantillon', () => {
  const network = localDockerNetwork();
  let keyring;
  let registry;
  let worker;

  beforeAll(async () => {
    jest.setTimeout(9000);
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
      Object.assign(pallets, network.palletOverrides);
      send('log', `${network.chain} wss connected success`);
    } catch (err) {
      send('log', `connect ${network.chain} failed`);
      await provider.disconnect();
    }

    registry = window.api.registry;
    worker = new EncointerWorker(network.worker, {
      keyring: keyring,
      api: api,
      createWebSocket: (url) => new WebSocket(url)
    });
    window.workerShieldingKey = await worker.getShieldingKey();
    window.mrenclave = network.mrenclave;
  });

  describe('on-chain', () => {
    describe('init api', () => {
      it('should get cantillon genesis hash', async () => {
        console.log('genesis hash: ' + api.genesisHash);
        expect(u8aToHex(api.genesisHash)).toBe(network.genesisHash);
      });
    });

    describe('getCommunityIdentifiers method', () => {
      it('should return value', async () => {
        const result = await getCommunityIdentifiers();
        const cidsBase58 = result.cids.map((cid) => bs58.encode(hexToU8a(cid.toString())));
        console.log(cidsBase58);
        expect(cidsBase58).toBeDefined();
      });
    });

    describe('accountgetBalances method', () => {
      it('should return balances', async () => {
        const address = '5GrwvaEF5zXb26Fz9rcQpDWS57CtERHpNehXCPcNoHGKutQY';
        const balances = await account.getBalance(address);
        console.log('Available Balance: ' + balances.availableBalance.toBigInt());
        expect(balances.availableBalance.toBigInt()).toBeGreaterThan(1);
      });
    });

    describe('sendFaucetTx method', () => {
      it('should send balance', async () => {
        jest.setTimeout(90000);
        const address = '5DPgv6nn4R1Gi1MUiAnzFDPaKF56SYKD9Zq4Q6REUGLhUZk1';
        const Ert001 = 1000000000;
        const result = await account.sendFaucetTx([address, Ert001]);
        console.log(result);
        expect(result).toBeDefined();
      });
    });
  });

  describe('worker', () => {
    describe('getWorkerPubKey method', () => {
      it('should return value', async () => {
        const result = await worker.getShieldingKey();
        expect(result).toBeDefined();
      });
    });

    describe('substratee call_worker', () => {
      it('registerParticipant works', async () => {
        await cryptoWaitReady();

        const alice = keyring.addFromUri('//Alice', { name: 'Alice default' });
        const trustedCall = getTrustedCall(alice, registry, network);
        // console.log(trustedCall);
        const callEncoded = trustedCall.toU8a();

        const cypherTextBuffer = window.workerShieldingKey.encrypt(u8aToBuffer(callEncoded));
        const cypherArray = bufferToU8a(cypherTextBuffer);

        // Currently, all TrustedCallSigned should fit into one chunk, this is a sanity test for passing the correct data
        expect(cypherArray.length).toBe(window.workerShieldingKey.getKeySize() / 8);

        const c = createType(registry, 'Vec<u8>', compactAddLength(cypherArray));
        console.log('cyphertext:\n  ' + c);
        console.log('cypherU8a: (first two bytes belong to the type registry) \n  ' + c.toU8a());

        const txInfo = {
          module: 'encointerCeremonies',
          call: 'registerParticipant',
          cid: network.chosenCid
        };

        const txRes = await _sendTrustedTx(alice, txInfo, [c]);
        console.log(txRes);

        const participantIndex = await worker.getParticipantIndex(alice, network.chosenCid);
        expect(participantIndex.toNumber()).toBeGreaterThan(0);
      });

      describe('getParticipantCount method', () => {
        it('should return value', async () => {
          const result = await worker.getParticipantCount(network.chosenCid);
          expect(result).toBe(0);
        });
      });
    });
  });
});
