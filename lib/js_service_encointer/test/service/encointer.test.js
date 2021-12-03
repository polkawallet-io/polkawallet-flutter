/**
 * @jest-environment jsdom
 */

import '../../src';
import encointer, {
  getProofOfAttendance,
  _getProofOfAttendance,
  _signClaimOfAttendance
} from '../../src/service/encointer';
import { cryptoWaitReady, signatureVerify } from '@polkadot/util-crypto';
import { bs58 } from '@polkadot/util-crypto/base58/bs58';
import { localDockerNetwork } from '../testUtils/networks';
import { beforeAll, describe, it, jest } from '@jest/globals';
import { parseI64F64 } from '@encointer/util';
import { testSetup } from '../testUtils/testSetup';
import { Keyring } from '@polkadot/api';

describe('encointer', () => {
  const network = localDockerNetwork();
  let keyring;
  beforeAll(async () => {
    await testSetup(network);
    keyring = new Keyring({ type: 'sr25519' });
  }, 90000);

  describe('getCurrentPhase', () => {
    it('should return promise', async () => {
      const result = await encointer.getCurrentPhase();
      console.log(result);
      expect(result).toBeDefined();
    });
  });

  describe('subscribeParticipantIndex', () => {
    it('should return promise', async () => {
      await cryptoWaitReady();
      const cid = bs58.decode('3LjCHdiNbNLKEtwGtBf6qHGZnfKFyjLu9v3uxVgDL35C');
      const attendee = keyring.addFromUri('//Bob', { name: 'Bob default' }).address;
      const result = await encointer.subscribeParticipantIndex('log', cid, 1, attendee);
      expect(result).toStrictEqual({});
    });
  });

  describe('getParticipantReputation', () => {
    it('should return promise', async () => {
      await cryptoWaitReady();
      const cid = bs58.decode('3LjCHdiNbNLKEtwGtBf6qHGZnfKFyjLu9v3uxVgDL35C');
      const attendee = keyring.addFromUri('//Bob', { name: 'Bob default' }).address;
      const result = await encointer.getParticipantReputation(cid, 1, attendee);
      expect(result.isUnverified).toBeTruthy();
    });
  });

  describe('getParticipantCount', () => {
    it('should return promise', async () => {
      await cryptoWaitReady();
      const cid = bs58.decode('3LjCHdiNbNLKEtwGtBf6qHGZnfKFyjLu9v3uxVgDL35C');
      // const attendee = keyring.addFromUri('//Bob', { name: 'Bob default' }).address;
      const result = await encointer.getParticipantCount(cid, 3);
      console.log(result);
      expect(result.toNumber()).toBe(0);
    });
  });

  describe('getParticipantReputation2', () => {
    it('should return promise', async () => {
      await cryptoWaitReady();
      const cid = bs58.decode('3LjCHdiNbNLKEtwGtBf6qHGZnfKFyjLu9v3uxVgDL35C');
      // const attendee = keyring.addFromUri('//Bob', { name: 'Bob default' }).address;
      const result = await encointer.getParticipantReputation(cid, 3, '0xf4577adda8c5bda374fb86d42aed35eb171a949c7b52202806cd137795d5567a');
      expect(result.isUnverified).toBeTruthy();
    });
  });

  describe('getProofOfAttendance', () => {
    it('should be defined', () => {
      expect(encointer.getProofOfAttendance).toBeDefined();
      expect(getProofOfAttendance).toBeDefined();
    });

    it('should return Promise rejected without arguments', async () => {
      const promise = _getProofOfAttendance();
      await expect(promise).rejects.toThrow('Invalid attendee');
    });

    it('should return Promise rejected with incorrect arguments', async () => {
      await expect(_getProofOfAttendance({ address: '//Bob' })).rejects.toThrow('Attendee should have sign method');
      await expect(_getProofOfAttendance({
        address: '//Bob',
        sign: jest.fn()
      })).rejects.toThrow('Invalid Community Identifier');
      await expect(_getProofOfAttendance({
        address: '//Bob',
        sign: jest.fn()
      }, 'test')).rejects.toThrow('Invalid Ceremony index');
      await expect(_getProofOfAttendance({
        address: '//Bob',
        sign: jest.fn()
      }, 'test', 0)).rejects.toThrow('Invalid Ceremony index');
    });

    it('should return proof object', async () => {
      await cryptoWaitReady();
      const attendee = keyring.addFromUri('//Alice', { name: 'Alice default' });
      const cid = '3LjCHdiNbNLKEtwGtBf6qHGZnfKFyjLu9v3uxVgDL35C';
      const optionProof = await _getProofOfAttendance(attendee, bs58.decode(cid), 2);
      const proof = optionProof.unwrap();
      expect(proof).toBeDefined();
      expect(proof.ceremony_index.toNumber()).toBe(2);
      expect(bs58.encode(proof.community_identifier)).toBe(cid);
      expect(proof.attendee_public.toString()).toBe(attendee.address.toString());
      expect(proof.prover_public.toString()).toBe(attendee.address.toString());
    });

    it('proof should be valid', async () => {
      await cryptoWaitReady();
      const attendee = keyring.addFromUri('//Bob', { name: 'Bob default' });
      const cid = bs58.decode('3LjCHdiNbNLKEtwGtBf6qHGZnfKFyjLu9v3uxVgDL35C');
      const cindex = 1;
      const optionProof = await _getProofOfAttendance(attendee, cid, cindex);
      const proof = optionProof.unwrap();
      // Check message constructed from proof
      const msg = api.createType('(AccountId,CeremonyIndexType)', [proof.attendee_public, proof.ceremony_index]);
      expect(
        signatureVerify(
          msg.toU8a(),
          proof.attendee_signature,
          proof.attendee_public
        )
      ).toBeTruthy();
    });
  });

  describe('signClaimOfAttendance', () => {
    it('creates valid claim', async () => {
      await cryptoWaitReady();
      const claimant = keyring.addFromUri('//Alice', { name: 'Alice default' });
      // contains Alice's key as given by the app.
      const claim = `{
        "claimant_public":"0xd43593c715fdd31c61141abd04a99fd6822c8558854ccde39a5684e7a56da27d",
        "ceremony_index":2,
        "community_identifier":"0x2cbd65a5f087b3d60aec997e6369ef694f125582f5f7cffd7bbddc56a71858fc",
        "meetup_index":1,
        "location":{"lon":"342068094947158917120","lat":"654567151410639405056"},
        "timestamp":1621507440000
        ,"number_of_participants_confirmed":3,
        "claimant_signature":null
      }`;

      const claimJson = JSON.parse(claim);
      const payload = window.api.createType('ClaimOfAttendanceSigningPayload', claimJson);
      const signedClaim = await _signClaimOfAttendance(claimant, claimJson);

      expect(
        signatureVerify(
          payload.toU8a(),
          signedClaim.claimant_signature.unwrap().toU8a(),
          claimant.publicKey
        )
      ).toEqual({
        crypto: 'sr25519',
        isValid: true,
        isWrapped: false,
        publicKey: claimant.publicKey
      });
    });

    it('verifies json parsed claim', async () => {
      await cryptoWaitReady();
      const claimant = keyring.addFromUri('//Alice', { name: 'Alice default' });
      const claim = `{
        "claimant_public":"0xd43593c715fdd31c61141abd04a99fd6822c8558854ccde39a5684e7a56da27d",
        "ceremony_index":2,
        "community_identifier":"0x2cbd65a5f087b3d60aec997e6369ef694f125582f5f7cffd7bbddc56a71858fc",
        "meetup_index":1,
        "location":{"lon":"342068094947158917120","lat":"654567151410639405056"},
        "timestamp":1621507440000,
        "number_of_participants_confirmed":3,
        "claimant_signature": {
            "sr25519":"0x4a1565472d2071c815b9b83e7d9e7317155c3aeeea872ec693011185b435f5757672754275d37489f74d691be06a42f3d101ee7b4d2b2ad7e84085809142ba8a"
          }
        }`;

      const claimJson = JSON.parse(claim);
      const payload = window.api.createType('ClaimOfAttendanceSigningPayload', claimJson);
      const claimObj = window.api.createType('ClaimOfAttendance', claimJson);

      expect(
        signatureVerify(
          payload.toU8a(),
          claimObj.claimant_signature.unwrap().toU8a(),
          claimant.publicKey
        )
      ).toEqual({
        crypto: 'sr25519',
        isValid: true,
        isWrapped: false,
        publicKey: claimant.publicKey
      });
    });
  });

  describe('parse fixed point string', () => {
    it('matches runtime value', () => {
      const locJson = '{ "lon": "342068094947158917120","lat": "654567151410639405056" }';
      const locObj = JSON.parse(locJson);
      const loc = window.api.createType('Location', locObj);

      expect(
        parseI64F64(loc.lat)
      ).toBe(35.4841563798531680618);
      expect(
        parseI64F64(loc.lon)
      ).toBe(18.543548583984375);
    });
  });
});
