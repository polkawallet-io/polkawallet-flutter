export const CustomTypes = {
  Address: 'AccountId',
  LookupSource: 'AccountId',
  CeremonyPhaseType: {
    _enum: [
      'Registering',
      'Assigning',
      'Attesting'
    ]
  },
  CeremonyIndexType: 'u32',
  ParticipantIndexType: 'u64',
  MeetupIndexType: 'u64',
  AttestationIndexType: 'u64',
  CurrencyIdentifier: 'Hash',
  BalanceType: 'i128',
  BalanceEntry: {
    principal: 'i128',
    last_update: 'BlockNumber'
  },
  CurrencyCeremony: '(CurrencyIdentifier,CeremonyIndexType)',
  CurrencyPropertiesType: {
    name_utf8: 'Vec<u8>',
    demurrage_per_block: 'Demurrage'
  },
  Demurrage: 'i128',
  Location: {
    lat: 'i64',
    lon: 'i64'
  },
  Reputation: {
    _enum: [
      'Unverified',
      'UnverifiedReputable',
      'VerifiedUnlinked',
      'VerifiedLinked'
    ]
  },
  ClaimOfAttendance: {
    claimant_public: 'AccountId',
    ceremony_index: 'CeremonyIndexType',
    currency_identifier: 'CurrencyIdentifier',
    meetup_index: 'MeetupIndexType',
    location: 'Location',
    timestamp: 'Moment',
    number_of_participants_confirmed: 'u32'
  },
  Attestation: {
    claim: 'ClaimOfAttendance',
    signature: 'MultiSignature',
    public: 'AccountId'
  },
  ProofOfAttendance: {
    prover_public: 'AccountId',
    ceremony_index: 'CeremonyIndexType',
    currency_identifier: 'CurrencyIdentifier',
    attendee_public: 'AccountId',
    attendee_signature: 'Signature'
  },
  ShardIdentifier: 'Hash',
  PublicGetter: {
    _enum: {
      total_issuance: 'CurrencyIdentifier',
      participant_count: 'CurrencyIdentifier',
      meetup_count: 'CurrencyIdentifier',
      ceremony_reward: 'CurrencyIdentifier',
      location_tolerance: 'CurrencyIdentifier',
      time_tolerance: 'CurrencyIdentifier'
    }
  },
  TrustedGetter: {
    _enum: {
      balance: '(AccountId, CurrencyIdentifier)',
      registration: '(AccountId, CurrencyIdentifier)',
      meetup_index_and_location: '(AccountId, CurrencyIdentifier)',
      attestations: '(AccountId, CurrencyIdentifier)'
    }
  },
  TrustedGetterSigned: {
    getter: 'TrustedGetter',
    signature: 'Signature'
  },
  Getter: {
    _enum: {
      public: 'PublicGetter',
      trusted: 'TrustedGetterSigned'
    }
  },
  ClientRequest: {
    _enum: {
      PubKeyWorker: null,
      MuRaPortWorker: null,
      StfState: '(Getter, ShardIdentifier)'
    }
  },
  Request: {
    shard: 'ShardIdentifier',
    cyphertext: 'Vec<u8>'
  },
  Enclave: {
    pubkey: 'AccountId',
    mrenclave: 'Hash',
    timestamp: 'u64',
    url: 'Text'
  },
  Weight: 'u64'
};
