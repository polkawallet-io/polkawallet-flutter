/**
 * @jest-environment jsdom
 */

'use strict';

import account from '../src/service/account';
import { u8aToHex } from '@polkadot/util';
import { gesellNetwork } from './testUtils/networks';

import { testSetup } from './testUtils/testSetup';
import { locationFromJson } from '../src/service/encointer.js';

describe('encointer', () => {
  const network = gesellNetwork();
  let api;
  beforeAll(async () => {
    const setup = await testSetup(network);
    api = setup.api;
  }, 90000);

  describe('init api', () => {
    it('should get gesell genesis hash', async () => {
      console.log('genesis hash: ' + api.genesisHash);
      expect(u8aToHex(api.genesisHash)).toBe(network.genesisHash);
    });
  });

  // Tests if the runtime is able to correctly interpret the extrinsic
  describe('get tx fee estimate', () => {
    it('should get fees for register_participant', async () => {
      // assert(true);
      const txInfo = {
        module: 'encointerCeremonies',
        call: 'registerParticipant',
        address: '5DPgv6nn4R1Gi1MUiAnzFDPaKF56SYKD9Zq4Q6REUGLhUZk1',
        pubKey: '0x3ab6baa11d0fcb81ae3e838e263de9524d7c64bb88d99629af68749d6a7ac023',
        password: '123qwe'
      };
      const param = ['0xf26bfaa0feee0968ec0637e1933e64cd1947294d3b667d43b76b3915fc330b53', null];

      const res = await account.txFeeEstimate(txInfo, param);
      expect(res.partialFee.toString()).toBe('125000117');
    });
  });

  it('should get fees for attestClaims', async () => {
    const claim = {
      claimant_public: '5GrwvaEF5zXb26Fz9rcQpDWS57CtERHpNehXCPcNoHGKutQY',
      ceremony_index: 63,
      community_identifier: '0x22c51e6a656b19dd1e34c6126a75b8af02b38eedbeec51865063f142c83d40d3',
      meetup_index: 1,
      location: locationFromJson(api, {
        lon: '35.5037',
        lat: '18.12314'
      }),
      timestamp: 1592719549549,
      number_of_participants_confirmed: 3,
      // signature: { Sr25519: '0xa011d3be7Sr255195a2448a72876967b859cba02226f41b1a9c179aac4733f5cb74c1096721c89eb4604100813dd99001fb888ded2fd1957dd4ee6891a6f2d30e9da98e' },
      signature: '0x01a011d3be75a2448a72876967b859cba02226f41b1a9c179aac4733f5cb74c1096721c89eb4604100813dd99001fb888ded2fd1957dd4ee6891a6f2d30e9da98e',
    };

    const txInfo = {
      module: 'encointerCeremonies',
      call: 'attestClaims',
      address: '5DPgv6nn4R1Gi1MUiAnzFDPaKF56SYKD9Zq4Q6REUGLhUZk1',
      pubKey: '0x3ab6baa11d0fcb81ae3e838e263de9524d7c64bb88d99629af68749d6a7ac023',
      password: '123qwe'
    };
    const param = [[claim, claim]];
    console.log(param.toString());
    const res = await account.txFeeEstimate(txInfo, param);
    expect(res.partialFee.toString()).toBeDefined();
  });

  describe('accountgetBalances method', () => {
    it('should return balances', async () => {
      const address = '5GrwvaEF5zXb26Fz9rcQpDWS57CtERHpNehXCPcNoHGKutQY';
      const balances = await account.getBalance(address);
      console.log(balances);
      expect(balances.availableBalance.toNumber()).toBeGreaterThan(1);
    });
  });

  describe('sendFaucetTx method', () => {
    it('should send balance', async () => {
      const address = '5DPgv6nn4R1Gi1MUiAnzFDPaKF56SYKD9Zq4Q6REUGLhUZk1';
      const Ert001 = 1000000000;
      const result = await account.sendFaucetTx(address, Ert001);
      console.log(result);
      expect(result).toBeDefined();
    }, 90000);
  });

  describe('can transform problematic location', () => {
    it('should be defined', async () => {
      const loc_js = {
        lat: '0x000000000000001987d96638433d0000',
        lon: '0xffffffffffffffe72ff3493858360000'
      };

      const loc = await api.createType('Location', loc_js);

      console.log(`Loc Object ${loc}`);

      expect(loc).toBeDefined();
    });
  });
});
