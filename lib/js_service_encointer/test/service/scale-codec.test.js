/**
 * @jest-environment jsdom
 */

import '../../src';
import {
  _signClaimOfAttendance
} from '../../src/service/encointer';
import { localDockerNetwork } from '../testUtils/networks';
import { beforeAll, describe, expect, it, jest } from '@jest/globals';
import { testSetup } from '../testUtils/testSetup';
import { Keyring } from '@polkadot/api';
import { decode, encode } from '../../src/service/scale-codec';
import { signatureVerify } from '@polkadot/util-crypto';

describe('scale-codec', () => {
  const network = localDockerNetwork();
  let keyring;

  const testClaim = {
    claimant_public: '5GrwvaEF5zXb26Fz9rcQpDWS57CtERHpNehXCPcNoHGKutQY',
    ceremony_index: 63,
    community_identifier: '0x22c51e6a656b19dd1e34c6126a75b8af02b38eedbeec51865063f142c83d40d3',
    meetup_index: 1,
    location: {
      lon: '35.5037',
      lat: '18.12314'
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
        'claimantPublic': '5FLSigC9HGRKVhB9FiEo4Y3koPsNmBmLJbpXg2mp1hXcS59Y',
        'ceremonyIndex': 2,
        'communityIdentifier': {
          'geohash': '0x73716d3176',
          'digest': '0xf08c911c'
        },
        'meetupIndex': 6,
        'location': {
          'lat': '0x00007e9e29acf17b2300000000000000',
          'lon': '0x000000000000268b1200000000000000'
        },
        'timestamp': 1640083440000,
        'numberOfParticipantsConfirmed': 3,
        'claimantSignature': { 'sr25519': '0x726ba0a4952ea2fc42444e21176209c364f9de420c88bcc04a7196647d482c59d6865fbd14aff779720d0bf0e5a1b951d5d5267b877b29034523fff3994aef8a' }
      };

      // Bytes scanned by cellphone when scanning above claim
      const walletData =
        [144, 181, 171, 32, 92, 105, 116, 201, 234, 132, 27, 230, 136, 134, 70, 51, 220, 156, 168, 163, 87, 132, 62, 234, 207, 35, 20, 100, 153, 101, 254, 34, 2, 0, 0, 0, 115, 113, 109, 49, 118, 240, 140, 145, 28, 6, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 35, 123, 241, 172, 41, 158, 126, 0, 0, 0, 0, 0, 0, 0, 0, 0, 18, 139, 38, 0, 0, 0, 0, 0, 0, 128, 65, 151, 220, 125, 1, 0, 0, 3, 0, 0, 0, 1, 1, 114, 107, 160, 164, 149, 46, 162, 252, 66, 68, 78, 33, 23, 98, 9, 195, 100, 249, 222, 66, 12, 136, 188, 192, 74, 113, 150, 100, 125, 72, 44, 89, 214, 134, 95, 189, 20, 175, 247, 121, 114, 13, 11, 240, 229, 161, 185, 81, 213, 213, 38, 123, 135, 123, 41, 3, 69, 35, 255, 243, 153, 74, 239, 138];

      const scannedClaim = await decode('ClaimOfAttendance', walletData);
      const signingPayload = api.createType('ClaimOfAttendanceSigningPayload', { ...scannedClaim });

      expect(scannedClaim.toJSON()).toStrictEqual(walletClaim);
      expect(
        signatureVerify(
          signingPayload.toU8a(),
          scannedClaim.claimantSignature.unwrap().toU8a(),
          scannedClaim.claimantPublic
        ).isValid
      ).toBe(true);
    });
  });
})
;
