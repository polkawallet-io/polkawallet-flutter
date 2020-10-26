import { assert, u8aToHex, hexToU8a } from '@polkadot/util';
import BN from 'bn.js';
import { cryptoWaitReady, encodeAddress } from '@polkadot/util-crypto';
import { createType } from '@polkadot/types';
import * as bs58 from 'bs58';

import { Keyring } from '@polkadot/keyring';
import { parseI32F32, parseI64F64, toI32F32 } from '../utils/fixpointUtil';

const keyring = new Keyring({ ss58Format: 0, type: 'sr25519' });

const divisor = new BN('1'.padEnd(18 + 1, '0'));

function balanceToNumber (amount) {
  return (
    amount
      .muln(1000)
      .div(divisor)
      .toNumber() / 1000
  );
}

export async function getCurrentPhase () {
  const phase = await api.query.encointerScheduler.currentPhase();
  return {
    phase
  };
}

/**
 * Mainly debug method introduced to test subscriptions. Subscribes to the timestamp of the last block
 * @param msgChannel channel that the message handler uses on the dart side
 * @returns {Promise<void>}
 */
export async function subscribeTimestamp (msgChannel) {
  await api.query.timestamp.now((moment) => {
    send(msgChannel, moment);
  }).then((unsub) => unsubscribe(unsub, msgChannel));
}

/**
 * Subscribes to the current ceremony phase
 * @param msgChannel channel that the message handler uses on the dart side
 * @returns {Promise<void>}
 */
export async function subscribeCurrentPhase (msgChannel) {
  return await api.query.encointerScheduler.currentPhase((phase) => {
    send(msgChannel, phase);
  }).then((unsub) => unsubscribe(unsub, msgChannel));
}

/**
 * Subscribes to the currencies registry
 * @param msgChannel channel that the message handler uses on the dart side
 * @returns {Promise<void>}
 */
export async function subscribeCurrencyIdentifiers (msgChannel) {
  return await api.query.encointerCurrencies.currencyIdentifiers((cids) => {
    send(msgChannel, cids);
  }).then((unsub) => unsubscribe(unsub, msgChannel));
}

/**
 * Subscribes to the current ceremony phase
 * @param msgChannel channel that the message handler uses on the dart side
 * @returns {Promise<void>}
 */
export async function subscribeParticipantIndex (msgChannel, cid, cIndex, address) {
  return await api.query.encointerCeremonies.participantIndex([cid, cIndex], address, (value) => {
    send(msgChannel, value);
  }).then((unsub) => unsubscribe(unsub, msgChannel));
}

/**
 * Subscribes to the balance of a given cid
 * @param msgChannel channel that the message handler uses on the dart side
 * @returns {Promise<void>}
 */
export async function subscribeBalance (msgChannel, cid, address) {
  return await api.query.encointerBalances.balance(cid, address, (b) => {
    const balance = parseI64F64(b.principal);
    send(msgChannel, {
      principal: balance,
      last_update: b.last_update.toNumber()
    });
  }).then((unsub) => unsubscribe(unsub, msgChannel));
}

export async function getParticipantIndex (cid, cIndex, address) {
  send('js-getParticipantIndex', `Getting participant index for Cid: ${cid}, cIndex: ${cIndex} and address: ${address}`);
  const pIndex = await api.query.encointerCeremonies.participantIndex([cid, cIndex], address);
  send('js-getParticipantIndex', `Participant index: ${pIndex}`);
  return pIndex;
}

export async function getParticipantCount (cid, cIndex) {
  send('js-getParticipantCount-', `Getting participant count for Cid: ${cid} and cIndex: ${cIndex}`);
  return await api.query.encointerCeremonies.participantCount([cid, cIndex]);
}

// returns a list of prefixed hex strings
export async function getCurrencyIdentifiers () {
  const cids = await api.query.encointerCurrencies.currencyIdentifiers();
  // send('js-getCurrencyIdentifiers', `Got Cids Raw: ${cids}`);
  // const cidsBase58 = cids.map((cid) => bs58.encode(hexToU8a(cid.toString())));
  return {
    cids
  };
}

export async function getCurrentCeremonyIndex () {
  return await api.query.encointerScheduler.currentCeremonyIndex();
}

export async function getMeetupIndex (cid, cIndex, address) {
  return await api.query.encointerCeremonies.meetupIndex([cid, cIndex], address);
}

export async function getMeetupRegistry (cid, cIndex, mIndex) {
  send('js-getMeetupRegistry', `Getting meetupRegistry for Cid: ${cid}, cIndex: ${cIndex} and mIndex: ${mIndex}`);
  return await api.query.encointerCeremonies.meetupRegistry([cid, cIndex], mIndex);
}

export async function getNextMeetupTime (cid, location) {
  // TODO: crappy js. how to properly ensure we're using numeric values?
  // send('js-getNextMeetupTime', `Getting next meetup time for Cid ${cid} and location: ${location.lat}, ${location.lon}`);
  const phase = await api.query.encointerScheduler.currentPhase();
  // send('js-getNextMeetupTime', `CurrentPhase: ${phase}`);
  const duration = 1 * await api.query.encointerScheduler.phaseDurations(phase);
  // send('js-getNextMeetupTime', `Duration: ${duration}`);
  const nextPhase = 1 * await api.query.encointerScheduler.nextPhaseTimestamp();
  // send('js-getNextMeetupTime', `next phase timestamp: ${nextPhase}`);

  // TODO: there is a helper function for this but it doesn't work
  const lon = Math.round(location.lon / (2 ** 32));
  // send('js-getNextMeetupTime', `meetup longitude: ${lon}`);

  const day = 1 * await api.consts.encointerScheduler.momentsPerDay;
  // send('js-getNextMeetupTime', `moments per day: ${day}`);

  var start = nextPhase * 1;

  // TODO use enum type?
  // TODO cover the invalid case of Registering (doesn't matter for Gesell, but for Cantillon)
  if (phase == 'Attesting') {
    start -= duration;
  }
  // send('js-getNextMeetupTime', `start: ${start}`);
  // the following is correct for pallets >=0.3.4
  var mtime = Math.round(start + day / 2 - (lon * day / 360));
  // send('js-getNextMeetupTime', `mtime: ${mtime}`);
  return mtime;
}

/**
 * 'api.query.encointerCurrencies.locations(cid)' returns an Array
 * EncointerLocations =  { lat: I32F32, long: I32F32 }
 * @param cid CurrencyIdentifier
 * @param mIndex MeetupIndex
 * @param address
 * @returns {Promise<{lon: number, lat: number}>}
 */
export async function getNextMeetupLocation (cid, mIndex, address) {
  // assert(m_index !== 0, "Meetup index is null, hence no meetup was found")
  send('js-getNextMeetupLocation', `Meetup Index: ${mIndex}`);
  const locations = await api.query.encointerCurrencies.locations(cid);
  send('js-getNextMeetupLocation', `Locations: ${locations}`);
  assert(mIndex <= locations.length);
  // assert(mIndex > 0);
  const _loc = locations[0]; // FIXME: locations[mIndex - 1];
  send('js-getNextMeetupLocation', `Latitude: ${_loc.lat}`);
  return _loc;
  // TODO: May have to fix this later. for now we treat location as i64 as defined in types
  // (we're not interpreting location in this app for now)
/*
  return createType(api.registry, 'Location', {
    lat: toI32F32(_loc.lat),
    lon: toI32F32(_loc.lon)
  });
*/
}

function unsubscribe (unsub, msgChannel) {
  const unsubFuncName = `unsub${msgChannel}`;
  window[unsubFuncName] = unsub;
  return {};
}

/**
 * Produce Proof of Attendance to register a participant.
 * In order to create properly formatted SCALE encoded proof following arguments
 * required: attendee account with address and sign method, currency identifier
 * as a string, past ceremony index.
 * Currently SINGLE account passed to this function in order derive:
 * a) ATTENDEE account that participated in past ceremony cindex, returned as
 *    attendee_public property, and to sign payload which should contain PROVER
 * b) PROVER address returned as prover_public property and in signature payload
 * in future release this function should receive two accounts.
 * @param {account} attendee
 * @param {CurrencyIdentifier} cid
 * @param {CeremonyIndexType} cindex
 * @returns {Option<ProofOfAttendance>} proofOfAttendance
 */
export async function getProofOfAttendance (attendee, cid, cindex) {
  await cryptoWaitReady();
  const registry = api.registry;
  assert((attendee && attendee.address), 'Invalid attendee');
  assert(attendee.sign, 'Attendee should have sign method');
  assert(cid, 'Invalid Currency Identifier');
  assert(cindex > 0, 'Invalid Ceremony index');
  const attendeePublic = createType(registry, 'AccountId', attendee.address).toU8a();
  // !Prover has same address as attendee, will be changed in future!
  const proverPublic = attendeePublic;
  const currencyIdentifier = createType(registry, 'CurrencyIdentifier', bs58.decode(cid));
  const msg = createType(registry, '(AccountId, CeremonyIndexType)', [proverPublic, cindex]);
  const signature = attendee.sign(msg.toU8a());
  const proof = createType(registry, 'ProofOfAttendance', {
    prover_public: proverPublic,
    ceremony_index: cindex,
    currency_identifier: currencyIdentifier,
    attendee_public: attendeePublic,
    attendee_signature: signature
  });
  return createType(registry, 'Option<ProofOfAttendance>', proof);
}

/**
 * Produce Claim Of Attendance type
 * @returns {ClaimOfAttendance} claim as prefixed hex string
 * @param claimJson
 */
export function getClaimOfAttendance (claimJson) {
  send('js-getClaimOfAttendance', `creating location from Json: ${claimJson}`);
  send('js-getClaimOfAttendance', `location: ${claimJson.location.lat}, ${claimJson.location.lon}`);

  // TODO: Fix location type
  /*
  claimJson.location = {
    lat: toI32F32(claimJson.location.lat),
    lon: toI32F32(claimJson.location.lon)
  };
*/
  const claimObj = createType(api.registry, 'ClaimOfAttendance', claimJson);
  send('js-getClaimOfAttendance', `claim: ${claimObj}`);
  // The Dart api needs to get a Promise back for some reason
  return new Promise((resolve, reject) => {
    resolve(u8aToHex(claimObj.toU8a()));
  });
}

/**
 * Parse Claim Of Attendance type
 * @param {String} claimHex hex string of claim of attendance
 * @return {Object} claim
 */
export function parseClaimOfAttendance (claimHex) {
  const claim = createType(api.registry, 'ClaimOfAttendance', claimHex);
  return new Promise((resolve, reject) => {
    resolve({
      ...claim.toJSON(),
      claimant_public: encodeAddress(claim.claimant_public)
      // currency_identifier: bs58.encode(claim.currency_identifier)
      /*
            location: {
              lat: parseI32F32(claim.location.lat),
              lon: parseI32F32(claim.location.lon)
            }
            */
    });
  });
}

/**
 * Parse Attestation type
 * @param {String} attestationHex hex string of attestation
 * @return {Object} claim
 */
export function parseAttestation (attestationHex) {
  const attestation = createType(api.registry, 'Attestation', attestationHex);
  const attJson = attestation.toJSON();
  /*
  attJson.claim.location = {
    lat: parseI32F32(attestation.claim.location.lat),
    lon: parseI32F32(attestation.claim.location.lon)
  };
  */
  attJson.claim.claimant_public = encodeAddress(attestation.claim.claimant_public);
  // attJson.claim.currency_identifier = bs58.encode(attestation.claim.currency_identifier);
  return new Promise((resolve, reject) => {
    resolve(attJson);
  });
}

export default {
  getCurrentPhase,
  getCurrencyIdentifiers,
  subscribeTimestamp,
  subscribeCurrentPhase,
  subscribeParticipantIndex,
  subscribeBalance,
  subscribeCurrencyIdentifiers,
  getProofOfAttendance,
  getClaimOfAttendance,
  parseAttestation,
  parseClaimOfAttendance,
  getCurrentCeremonyIndex,
  getNextMeetupLocation,
  getNextMeetupTime,
  getMeetupIndex,
  getParticipantIndex,
  getParticipantCount,
  getMeetupRegistry
};
