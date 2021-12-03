/**
 * @jest-environment jsdom
 */

import '../../src';
import {
  _signClaimOfAttendance
} from '../../src/service/encointer';
import { localDockerNetwork } from '../testUtils/networks';
import { beforeAll, describe, it, jest } from '@jest/globals';
import { testSetup } from '../testUtils/testSetup';
import { Keyring } from '@polkadot/api';
import { decode, encode } from '../../src/service/scale-codec';

describe('scale-codec', () => {
  const network = localDockerNetwork();
  let keyring;

  const testClaim = {
    claimant_public: '5GrwvaEF5zXb26Fz9rcQpDWS57CtERHpNehXCPcNoHGKutQY',
    ceremony_index: 63,
    community_identifier: '0x22c51e6a656b19dd1e34c6126a75b8af02b38eedbeec51865063f142c83d40d3',
    meetup_index: 1,
    location: {
      lat: '0x00000000000000237bf1ac299e7e0000',
      lon: '0x00000000000000128b26000000000000'
    },
    timestamp: 1638441840000,
    number_of_participants_confirmed: 3,
    signature: null
  };

  beforeAll(async () => {
    jest.setTimeout(90000);

    await testSetup(network);
    keyring = new Keyring({ type: 'sr25519' });
  });

  describe('encode', () => {
    it('works correctly', async () => {
      const claimant = keyring.addFromUri('//Alice', { name: 'Alice default' });

      const claimSigned = await _signClaimOfAttendance(claimant, testClaim);

      expect(
        await encode('ClaimOfAttendance', claimSigned)
      ).toStrictEqual(claimSigned.toU8a());
    });
  });

  describe('decode', () => {
    it('works correctly', async () => {
      const claimant = keyring.addFromUri('//Alice', { name: 'Alice default' });

      const claimSigned = await _signClaimOfAttendance(claimant, testClaim);

      expect(
        await decode('ClaimOfAttendance', claimSigned.toU8a())
      ).toStrictEqual(claimSigned);
    });

    it('can parse data from wallet when scanning the qr code', async () => {
      // data which is encoded and displayed on cellphone 1.
      const walletClaim = {
        claimant_public: '5GrwvaEF5zXb26Fz9rcQpDWS57CtERHpNehXCPcNoHGKutQY',
        ceremony_index: 2,
        community_identifier: '0x2cbd65a5f087b3d60aec997e6369ef694f125582f5f7cffd7bbddc56a71858fc',
        meetup_index: 1,
        location: {
          lat: '0x00000000000000237bf1ac299e7e0000',
          lon: '0x00000000000000128b26000000000000'
        },
        timestamp: 1638441840000,
        number_of_participants_confirmed: 3,
        signature: {
          sr25519: '0xf03d063bfdf951438bf48ba74623c8c3689625c7ddcfc73e8600ed459b8d483e2d45d0b7e4dff69a05467251a45a48ac7e66f04803b1f8db5407a4f4fcf4968b'
        }
      };

      // Bytes scanned by cellphone when scanning above claim
      const walletData =
        [212, 53, 147, 199, 21, 253, 211, 28, 97, 20, 26, 189, 4, 169, 159, 214, 130, 44, 133, 88, 133, 76, 205, 227, 154, 86, 132, 231, 165, 109, 162, 125, 2, 0, 0, 0, 44, 189, 101, 165, 240, 135, 179, 214, 10, 236, 153, 126, 99, 105, 239, 105, 79, 18, 85, 130, 245, 247, 207, 253, 123, 189, 220, 86, 167, 24, 88, 252, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 126, 158, 41, 172, 241, 123, 35, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 38, 139, 18, 0, 0, 0, 0, 0, 0, 0, 128, 109, 190, 122, 125, 1, 0, 0, 3, 0, 0, 0, 1, 1, 240, 61, 6, 59, 253, 249, 81, 67, 139, 244, 139, 167, 70, 35, 200, 195, 104, 150, 37, 199, 221, 207, 199, 62, 134, 0, 237, 69, 155, 141, 72, 62, 45, 69, 208, 183, 228, 223, 246, 154, 5, 70, 114, 81, 164, 90, 72, 172, 126, 102, 240, 72, 3, 177, 248, 219, 84, 7, 164, 244, 252, 244, 150, 139];

      expect(
        await decode('ClaimOfAttendance', walletData)
      ).toStrictEqual(api.createType('ClaimOfAttendance', walletClaim));
    });
  });
});
