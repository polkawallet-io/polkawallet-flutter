'use strict';

import { CustomTypes } from './config/types';
import encointer from './service/encointer';
import { hexToU8a, u8aToHex } from '@polkadot/util';
import { ApiPromise, Keyring } from '@polkadot/api';
import * as types from '@polkadot/types';
import { createType } from '@polkadot/types';
import * as bs58 from 'bs58';
import { WsProvider } from '@polkadot/rpc-provider';
import '@babel/polyfill';
import { txFeeEstimate } from './service/account';

describe('encointer', () => {
  let keyring;
  let registry;
  beforeAll(async () => {
    keyring = new Keyring({ type: 'sr25519' });
    await connect('wss://gesell.encointer.org');
    registry = window.api.registry;
  });

  describe('init api', () => {
    it('should get gesell genesis hash', async () => {
      console.log('genesis hash: ' + api.genesisHash);
      const gesellGenesisHash = '0x5accb06aae14470d4f0e8ecd7330350ed5d14262e54770bbd548b87ff90b8cef';
      expect(u8aToHex(api.genesisHash)).toBe(gesellGenesisHash);
      // assert(true);
    });
  });

  // Tests if the runtime is able to correctly interpret the extrinsic
  describe('get tx fee estimate', () => {
    it('should get fees for register_participant', async () => {
      // assert(true);
      const txInfo = { module: 'encointerCeremonies', call: 'registerParticipant', address: '5DPgv6nn4R1Gi1MUiAnzFDPaKF56SYKD9Zq4Q6REUGLhUZk1', pubKey: '0x3ab6baa11d0fcb81ae3e838e263de9524d7c64bb88d99629af68749d6a7ac023', password: '123qwe' };
      const param = ['0xf26bfaa0feee0968ec0637e1933e64cd1947294d3b667d43b76b3915fc330b53', null];

      const res = await txFeeEstimate(txInfo, param);
      expect(res.partialFee.toString()).toBe('10140');
    });
  });

  it('should get fees for register_attestation', async () => {
    const attestation = {
      claim:
          {
            claimant_public: '5GrwvaEF5zXb26Fz9rcQpDWS57CtERHpNehXCPcNoHGKutQY',
            ceremony_index: 63,
            currency_identifier: '0x22c51e6a656b19dd1e34c6126a75b8af02b38eedbeec51865063f142c83d40d3',
            meetup_index: 1,
            location: { lon: '79643934720', lat: '152403291178' },
            timestamp: 1592719549549,
            number_of_participants_confirmed: 3
          },
      // signature: { Sr25519: '0xa011d3be75a2448a72876967b859cba02226f41b1a9c179aac4733f5cb74c1096721c89eb4604100813dd99001fb888ded2fd1957dd4ee6891a6f2d30e9da98e' },
      signature: '0x01a011d3be75a2448a72876967b859cba02226f41b1a9c179aac4733f5cb74c1096721c89eb4604100813dd99001fb888ded2fd1957dd4ee6891a6f2d30e9da98e',
      public: '5DPgv6nn4R1Gi1MUiAnzFDPaKF56SYKD9Zq4Q6REUGLhUZk1'
    };

    const txInfo = { module: 'encointerCeremonies', call: 'registerAttestations', address: '5DPgv6nn4R1Gi1MUiAnzFDPaKF56SYKD9Zq4Q6REUGLhUZk1', pubKey: '0x3ab6baa11d0fcb81ae3e838e263de9524d7c64bb88d99629af68749d6a7ac023', password: '123qwe' };
    const param = [[attestation, attestation]];
    console.log(param.toString());
    const res = await txFeeEstimate(txInfo, param);
    expect(res.partialFee.toString()).toBe('10510');
  });

  describe('getBalances method', () => {
    it('should return balances', async () => {
      const address = '5GrwvaEF5zXb26Fz9rcQpDWS57CtERHpNehXCPcNoHGKutQY';
      const balances = await encointer.getBalances(address);
      console.log(balances);
      expect(balances.length).toBeGreaterThan(1);
    });
  });
});

/**
 * Same as index.js
 * @param endpoint
 * @returns {Promise<unknown>}
 */
async function connect (endpoint) {
  return new Promise(async (resolve, reject) => {
    const provider = new WsProvider(endpoint);
    try {
      window.api = await ApiPromise.create({
        provider,
        types: CustomTypes
      });
      console.log(`${endpoint} wss connected success`);
      resolve(endpoint);
    } catch (err) {
      console.error(`${endpoint} wss connected failed`);
      provider.disconnect();
      resolve(null);
    }
  });
}
