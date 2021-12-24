import { assert, bnToU8a, hexToU8a } from '@polkadot/util';
import { cryptoWaitReady } from '@polkadot/util-crypto';
import { createType } from '@polkadot/types';

import { parseEncointerBalance, stringToDegree } from '@encointer/types';
import { keyring } from './account.js';
import { pallets } from '../config/consts.js';
import { unsubscribe } from '../utils/unsubscribe.js';
import { communityIdentifierToString } from '@encointer/util';

export async function getCurrentPhase () {
  return api.query.encointerScheduler.currentPhase();
}

/**
 * Gets all phase durations to cache them on the dart side to speedup `getNextMeetupTime` request.
 */
export async function getPhaseDurations () {
  const [registering, assigning, attesting] = await Promise.all([
    api.query.encointerScheduler.phaseDurations('Registering'),
    api.query.encointerScheduler.phaseDurations('Attesting'),
    api.query.encointerScheduler.phaseDurations('Assigning')
  ]);
  return {
    Registering: registering,
    Attesting: assigning,
    Assigning: attesting
  };
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
export async function subscribeCommunityIdentifiers (msgChannel) {
  return await api.query[pallets.encointerCommunities.name][pallets.encointerCommunities.calls.communityIdentifiers]((cids) => {
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

export async function getBalance (cid, address) {
  const balanceEntry = await api.query.encointerBalances.balance(cid, address);
  return {
    principal: parseEncointerBalance(balanceEntry.principal.bits),
    lastUpdate: balanceEntry.lastUpdate.toNumber()
  };
}

/**
 * Subscribes to the balance of a given cid
 * @param msgChannel channel that the message handler uses on the dart side
 * @returns {Promise<void>}
 */
export async function subscribeBalance (msgChannel, cid, address) {
  return await api.query.encointerBalances.balance(cid, address, (b) => {
    const balance = parseEncointerBalance(b.principal.bits);
    send(msgChannel, {
      principal: balance,
      lastUpdate: b.lastUpdate.toNumber()
    });
  }).then((unsub) => unsubscribe(unsub, msgChannel));
}

/**
 * Subscribes to the business registry of a given cid
 * @param msgChannel channel that the message handler uses on the dart side
 * @returns {Promise<void>}
 */
export async function subscribeBusinessRegistry (msgChannel, cid) {
  return await api.query.encointerBazaar.businessRegistry(cid, (businesses) => {
    send(msgChannel, businesses);
  }).then((unsub) => unsubscribe(unsub, msgChannel));
}

export async function getParticipantIndex (cid, cIndex, address) {
  const cidT = api.createType('CommunityIdentifier', cid)
  send('js-getParticipantIndex', `Getting participant index for Cid: ${communityIdentifierToString(cidT)}, cIndex: ${cIndex} and address: ${address}`);
  const pIndex = await api.query.encointerCeremonies.participantIndex([cid, cIndex], address);
  send('js-getParticipantIndex', `Participant index: ${pIndex}`);
  return pIndex;
}

export async function getParticipantCount (cid, cIndex) {
  const cidT = api.createType('CommunityIdentifier', cid)
  send('js-getParticipantCount-', `Getting participant count for Cid: ${communityIdentifierToString(cidT)} and cIndex: ${cIndex}`);
  return await api.query.encointerCeremonies.participantCount([cid, cIndex]);
}

export async function getParticipantReputation (cid, cIndex, address) {
  const cidT = api.createType('CommunityIdentifier', cid)
  send('js-getParticipantReputation', `Getting participant reputation for Cid: ${communityIdentifierToString(cidT)}, cIndex: ${cIndex} and address: ${address}`);
  const reputation = await api.query.encointerCeremonies.participantReputation([cid, cIndex], address);
  send('js-getParticipantReputation', `Participant reputation: ${reputation}`);
  return reputation;
}

// returns a list of prefixed hex strings
export async function getCommunityIdentifiers () {
  const pallet = pallets.encointerCommunities;
  const cids = await api.query[pallet.name][pallet.calls.communityIdentifiers]();
  return {
    cids
  };
}

export async function getCommunityMetadata (cid) {
  const pallet = pallets.encointerCommunities;
  return await api.query[pallet.name][pallet.calls.communityMetadata](cid);
}

export async function getDemurrage (cid) {
  const [demCustom, demDefault] = await Promise.all([
    api.query.encointerCommunities.demurragePerBlock(cid),
    api.query.encointerBalances.demurragePerBlockDefault()
  ]);

  if (demCustom.bits != 0) {
    send('js-getDemurrage', `Returning custom demurrage: ${demCustom}`);
    return parseEncointerBalance(demCustom.bits);
  } else {
    send('js-getDemurrage', `Returning default demurrage: ${demDefault}`);
    return parseEncointerBalance(demDefault.bits);
  }
}

export async function communitiesGetAll () {
  return await api.rpc.communities.getAll();
}

export async function getCurrentCeremonyIndex () {
  return await api.query.encointerScheduler.currentCeremonyIndex();
}

export async function getMeetupIndex (cid, cIndex, address) {
  return await api.query.encointerCeremonies.meetupLocationIndex([cid, cIndex], address);
}

export async function getMeetupRegistry (cid, cIndex, mIndex) {
  const cidT = api.createType('CommunityIdentifier', cid)
  send('js-getMeetupRegistry', `Getting meetupRegistry for Cid: ${communityIdentifierToString(cidT)}, cIndex: ${cIndex} and mIndex: ${mIndex}`);
  return await api.query.encointerCeremonies.meetupRegistry([cid, cIndex], mIndex);
}

/**
 * Gets the meetup time for a location.
 *
 * @param location Meetup location with fields as numbers, e.g. 35.153215322
 * @param phase Current CeremonyPhase
 * @param duration Phase duration of the current CeremonyPhase
 * @returns {Promise<number>}
 */
export async function getNextMeetupTime (location, phase, duration) {
  assert(phase != 'Registering', 'Can\'t get next meetup time in registering phase');

  const nextPhase = await api.query.encointerScheduler.nextPhaseTimestamp()
    .then((p) => p.toNumber());

  const lon = Math.round(location.lon);
  const day = api.consts.encointerScheduler.momentsPerDay.toNumber();

  let start = nextPhase;

  // TODO use enum type?
  if (phase == 'Attesting') {
    start -= duration;
  }

  // the following is correct for pallets >=0.3.4
  return Math.round(start + day / 2 - (lon * day / 360));
}

/**
 *
 * @param cid CommunityIdentifier
 * @param mIndex MeetupIndex
 * @param address
 * @returns {Promise<{lon: number, lat: number}>} with number format '35.123412341234'
 */
export async function getNextMeetupLocation (cid, mIndex, address) {
  // assert(m_index !== 0, "Meetup index is null, hence no meetup was found")
  send('js-getNextMeetupLocation', `Meetup Index: ${mIndex}`);
  const locations = await api.rpc.communities.getLocations(cid);
  send('js-getNextMeetupLocation', `Locations: ${locations}`);
  assert(mIndex <= locations.length, 'invalid meetup index');
  // assert(mIndex > 0);

  return locations[mIndex - 1];
}

/**
 * Produce Proof of Attendance to register a participant.
 * In order to create properly formatted SCALE encoded proof following arguments
 * required: attendee account with address and sign method, community identifier
 * as a string, past ceremony index.
 * Currently SINGLE account passed to this function in order derive:
 * a) ATTENDEE account that participated in past ceremony cIndex, returned as
 *    attendee_public property, and to sign payload which should contain PROVER
 * b) PROVER address returned as prover_public property and in signature payload
 * in future release this function should receive two accounts.
 * @param {String} attendeePubKey
 * @param {CommunityIdentifier} cid
 * @param {CeremonyIndexType} cIndex
 * @param password to unlock privKey
 * @returns {Option<ProofOfAttendance>} proofOfAttendance
 */
export async function getProofOfAttendance (attendeePubKey, cid, cIndex, password) {
  const cidT = api.createType('CommunityIdentifier', cid)
  window.send('js-getProofOfAttendance', `getting PoA for  Cid: ${communityIdentifierToString(cidT)}, cIndex: ${cIndex} and address: ${attendeePubKey}`);
  const attendee = keyring.getPair(hexToU8a(attendeePubKey));
  try {
    attendee.decodePkcs8(password);
  } catch (err) {
    return new Promise((resolve, reject) => {
      resolve({ error: 'password check failed' });
    });
  }
  return _getProofOfAttendance(attendee, cid, cIndex);
}

export async function _getProofOfAttendance (attendee, cid, cindex) {
  await cryptoWaitReady();
  const registry = api.registry;
  assert((attendee && attendee.address), 'Invalid attendee');
  assert(attendee.sign, 'Attendee should have sign method');
  assert(cid, 'Invalid Community Identifier');
  assert(cindex > 0, 'Invalid Ceremony index');
  const attendeePublic = createType(registry, 'AccountId', attendee.address).toU8a();
  // !Prover has same address as attendee, will be changed in future!
  const proverPublic = attendeePublic;
  const communityIdentifier = createType(registry, 'CommunityIdentifier', cid);
  const msg = createType(registry, '(AccountId, CeremonyIndexType)', [proverPublic, cindex]);
  const signature = attendee.sign(msg.toU8a(), { withType: true });
  const proof = createType(registry, 'ProofOfAttendance', {
    prover_public: proverPublic,
    ceremony_index: cindex,
    community_identifier: communityIdentifier,
    attendee_public: attendeePublic,
    attendee_signature: signature
  });
  return createType(registry, 'Option<ProofOfAttendance>', proof);
}

/**
 * @param {json} claimJson
 * @param {string} password
 */
export async function signClaimOfAttendance (claimJson, password) {
  await cryptoWaitReady();
  const claimant = keyring.getPair(hexToU8a(claimJson.claimant_public));
  try {
    claimant.decodePkcs8(password);
  } catch (err) {
    return new Promise((resolve, reject) => {
      resolve({ error: 'password check failed' });
    });
  }
  return _signClaimOfAttendance(claimant, claimJson);
}

export async function _signClaimOfAttendance (claimant, claimJson) {
  await cryptoWaitReady();

  send('js-signClaimOfAttendance', `claimJson: ${JSON.stringify(claimJson)}`);

  // claimJson.location contains degree as string, e.g. 35.23432
  const location = api.createType('Location', {
    // defaults to BE but we want to be explicit
    lat: bnToU8a(stringToDegree(claimJson.location.lat), 128, false),
    lon: bnToU8a(stringToDegree(claimJson.location.lon), 128, false),
  });

  let claim = {
    ...claimJson,
    location: location,
  };

  const payload = api.createType('ClaimOfAttendanceSigningPayload', {
    ...claim,
    location: {
      // scale-codec is LE, hence we need to sign the LE encoded payload, which is not the default for `i128`, otherwise
      // we get a signature error in the runtime. See: https://github.com/polkadot-js/api/issues/4313
      lat: claim.location.lat.toHex(true),
      lon: claim.location.lon.toHex(true),
    }
  });

  const signature = claimant.sign(payload.toU8a(), { withType: true });

  return api.createType('ClaimOfAttendance', {
    ...claim,
    claimant_signature: api.createType('MultiSignature', signature) // js can implicitly create `Option<Type> iff `Type` is already a registry object.
  });
}

export async function getBusinessRegistry (cid) {
  return await api.query.encointerBazaar.businessRegistry(cid);
}

export default {
  getCurrentPhase,
  getPhaseDurations,
  getCommunityIdentifiers,
  getParticipantReputation,
  subscribeCurrentPhase,
  subscribeParticipantIndex,
  subscribeBalance,
  subscribeCommunityIdentifiers,
  subscribeBusinessRegistry,
  getProofOfAttendance,
  signClaimOfAttendance,
  getCurrentCeremonyIndex,
  getNextMeetupLocation,
  getNextMeetupTime,
  getDemurrage,
  getCommunityMetadata,
  communitiesGetAll,
  getMeetupIndex,
  getParticipantIndex,
  getParticipantCount,
  getMeetupRegistry,
  getBalance,
  getBusinessRegistry
};
