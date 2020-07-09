import '../';
import { CustomTypes } from '../config/types';
import encointer, {
  getProofOfAttendance,
  getClaimOfAttendance,
  parseClaimOfAttendance,
  parseAttestation
} from './encointer';
import { _attestClaimOfAttendance, attestClaimOfAttendance } from './account';
import { cryptoWaitReady, signatureVerify } from '@polkadot/util-crypto';
import { hexToU8a, u8aToHex } from '@polkadot/util';
import { Keyring } from '@polkadot/api';
import * as types from '@polkadot/types';
import { createType } from '@polkadot/types';
import * as bs58 from 'bs58';

describe('encointer', () => {
  let keyring;
  let registry;
  beforeAll(() => {
    keyring = new Keyring({ type: 'sr25519' });
    registry = new types.TypeRegistry();
    registry.register(CustomTypes);
    const query = {
      encointerScheduler: {
        currentPhase: jest.fn().mockImplementation(() => Promise.resolve(123))
      }
    };

    window.api = { registry, query };
  });

  describe('getCurrentPhase', () => {
    it('should return promise', async () => {
      const result = await encointer.getCurrentPhase();
      expect(result).toEqual({ phase: 123 });
    });
  });

  describe('getProofOfAttendance', () => {
    it('should be defined', () => {
      expect(encointer.getProofOfAttendance).toBeDefined();
      expect(getProofOfAttendance).toBeDefined();
    });

    it('should return Promise rejected without arguments', async () => {
      const promise = getProofOfAttendance();
      await expect(promise).rejects.toThrow('Invalid attendee');
    });

    it('should return Promise rejected with incorrect arguments', async () => {
      await expect(getProofOfAttendance({ address: '//Bob' })).rejects.toThrow('Attendee should have sign method');
      await expect(getProofOfAttendance({
        address: '//Bob',
        sign: jest.fn()
      })).rejects.toThrow('Invalid Currency Identifier');
      await expect(getProofOfAttendance({
        address: '//Bob',
        sign: jest.fn()
      }, 'test')).rejects.toThrow('Invalid Ceremony index');
      await expect(getProofOfAttendance({
        address: '//Bob',
        sign: jest.fn()
      }, 'test', 0)).rejects.toThrow('Invalid Ceremony index');
    });

    it('should return proof object', async () => {
      await cryptoWaitReady();
      const attendee = keyring.addFromUri('//Alice', { name: 'Alice default' });
      const cid = '3LjCHdiNbNLKEtwGtBf6qHGZnfKFyjLu9v3uxVgDL35C';
      const optionProof = await getProofOfAttendance(attendee, cid, 2);
      const proof = optionProof.unwrap();
      expect(proof).toBeDefined();
      expect(proof.ceremony_index.toNumber()).toBe(2);
      expect(bs58.encode(proof.currency_identifier)).toBe(cid);
      expect(proof.attendee_public.toString()).toBe(attendee.address.toString());
      expect(proof.prover_public.toString()).toBe(attendee.address.toString());
    });

    it('proof should be valid', async () => {
      await cryptoWaitReady();
      const attendee = keyring.addFromUri('//Bob', { name: 'Bob default' });
      const cid = '3LjCHdiNbNLKEtwGtBf6qHGZnfKFyjLu9v3uxVgDL35C';
      const cindex = 1;
      const optionProof = await getProofOfAttendance(attendee, cid, cindex);
      const proof = optionProof.unwrap();
      // Check message constructed from proof
      const msg = createType(registry, '(AccountId,CeremonyIndexType)', [proof.attendee_public, proof.ceremony_index]);
      expect(
        signatureVerify(
          msg.toU8a(),
          proof.attendee_signature,
          proof.attendee_public
        )
      ).toBeTruthy();
    });
  });

  describe('getClaimOfAttendance', () => {
    it('should be defined', () => {
      expect(encointer.getClaimOfAttendance).toBeDefined();
      expect(getClaimOfAttendance).toBeDefined();
    });

    it('should return claim', async () => {
      await cryptoWaitReady();
      const claimant = keyring.addFromUri('//Alice', { name: 'Alice default' });
      const cid = '0x22c51e6a656b19dd1e34c6126a75b8af02b38eedbeec51865063f142c83d40d3';

      const claim = `{
          "claimant_public" : "${claimant.address}",
          "ceremony_index"  : 63,
          "currency_identifier" : "${cid}",
          "meetup_index" : 1,
          "location": { "lat": 3548415638 , "lon": 18543548584 },
          "timestamp" : 1592719549549,
          "number_of_participants_confirmed" : 3
          }`;

      const claimJson = JSON.parse(claim);
      const claimHex = await getClaimOfAttendance(claimJson);
      expect(claimHex).toBeDefined();
      expect(claimHex).toBe('0xd43593c715fdd31c61141abd04a99fd6822c8558854ccde39a5684e7a56da27d3f00000022c51e6a656b19dd1e34c6126a75b8af02b38eedbeec51865063f142c83d40d30100000000000000968680d300000000a8184851040000006da47bd57201000003000000');
    });
  });

  describe('parseClaimOfAttendance', () => {
    it('should be defined', () => {
      expect(parseClaimOfAttendance).toBeDefined();
      expect(encointer.parseClaimOfAttendance).toBeDefined();
    });

    it('should return value', () => {
      const claim = parseClaimOfAttendance('0xd43593c715fdd31c61141abd04a99fd6822c8558854ccde39a5684e7a56da27d3f00000022c51e6a656b19dd1e34c6126a75b8af02b38eedbeec51865063f142c83d40d301000000000000002aacf17b230000000000268b120000006da47bd57201000003000000');
      expect(claim).toBeDefined();
      expect(claim).toEqual(
        {
          claimant_public: '5GrwvaEF5zXb26Fz9rcQpDWS57CtERHpNehXCPcNoHGKutQY',
          ceremony_index: 63,
          currency_identifier: '3LjCHdiNbNLKEtwGtBf6qHGZnfKFyjLu9v3uxVgDL35C',
          meetup_index: 1,
          location: { lat: 35.48415637994185, lon: 18.543548583984375 },
          timestamp: 1592719549549,
          number_of_participants_confirmed: 3
        }
      );
    });
  });

  describe('attestClaimOfAttendance', () => {
    it('should produce valid attestation', async () => {
      await cryptoWaitReady();
      const bob = keyring.addFromUri('//Bob', { name: 'Bob default' });
      // first byte is multisig enum index. Mock as signature is non-deterministic
      bob.sign = jest.fn().mockImplementation(() => '0x01864e24338bf1be2f9a304a67ca1b166f72e76919202109c4ef5b8b6f0e5c00238b7ecc8cc30de924443971dd001a79010ff34c16ca42413eb831e549775a858d');
      const claim = '0xd43593c715fdd31c61141abd04a99fd6822c8558854ccde39a5684e7a56da27d3f00000022c51e6a656b19dd1e34c6126a75b8af02b38eedbeec51865063f142c83d40d301000000000000002aacf17b230000000000268b120000006da47bd57201000003000000';
      const attest = await _attestClaimOfAttendance(claim, bob);
      expect(attest.attestationHex).toBe(
        '0xd43593c715fdd31c61141abd04a99fd6822c8558854ccde39a5684e7a56da27d3f00000022c51e6a656b19dd1e34c6126a75b8af02b38eedbeec51865063f142c83d40d301000000000000002aacf17b230000000000268b120000006da47bd5720100000300000001864e24338bf1be2f9a304a67ca1b166f72e76919202109c4ef5b8b6f0e5c00238b7ecc8cc30de924443971dd001a79010ff34c16ca42413eb831e549775a858d8eaf04151687736326c9fea17e25fc5287613693c912909cb226aa4794f26a48'
      );
    });
  });

  describe('parseAttestation', () => {
    it('should parse valid attestation', async () => {
      await cryptoWaitReady();
      const claim = parseClaimOfAttendance('0xd43593c715fdd31c61141abd04a99fd6822c8558854ccde39a5684e7a56da27d3f00000022c51e6a656b19dd1e34c6126a75b8af02b38eedbeec51865063f142c83d40d301000000000000002aacf17b230000000000268b120000006da47bd57201000003000000');
      const attestationHex = '0xd43593c715fdd31c61141abd04a99fd6822c8558854ccde39a5684e7a56da27d3f00000022c51e6a656b19dd1e34c6126a75b8af02b38eedbeec51865063f142c83d40d301000000000000002aacf17b230000000000268b120000006da47bd572010000030000000172733a8a053d1a66178950336bf2a7e1619583281eac6658c1032a65641c6e6d3facd877b53c2e1b5565a68c9f35778c74e53a511fc235526afc93a350f5ec848eaf04151687736326c9fea17e25fc5287613693c912909cb226aa4794f26a48';
      const attesterPublic = '5FHneW46xGXgs5mUiveU4sbTyGBzmstUspZC92UhjJM694ty';
      const attesterSignature = { Sr25519: '0x72733a8a053d1a66178950336bf2a7e1619583281eac6658c1032a65641c6e6d3facd877b53c2e1b5565a68c9f35778c74e53a511fc235526afc93a350f5ec84' };

      const attest = await parseAttestation(attestationHex);
      expect(attest).toEqual(
        {
          claim: claim,
          signature: attesterSignature,
          public: attesterPublic
        }
      );
    });
    it('should parse another valid attestation', async () => {
        const attestationHex = '0xcebe13cadd0372d354b606070cb624123779e4509741eba780b6e1f1c4456e6326110000cef98d744e978f3e33724cfb5677d2104e020909fbec6e97c2c594aa607d78cb0100000000000000363db7632f00000000095b840800000040272d33730100000300000001bacdef644b0beafc2230f9ef28aea0fb46a01374d9a66c725cc070f643bfe017a45fc08c997f13ae009d7ac06446d00841677c410e4fe1c9fb25e59126516d8bcebe13cadd0372d354b606070cb624123779e4509741eba780b6e1f1c4456e63';
        const attest = await parseAttestation(attestationHex);
    });
  });
});
