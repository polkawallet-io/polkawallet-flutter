/// Maps pallet calls to TrustedCalls in case we are connected to
/// a tee proxy.
export const TrustedCallMap = {
  encointerCeremonies: {
    registerParticipant: 'ceremonies_register_participant',
    registerAttestations: 'ceremonies_register_attestations',
    grantReputation: 'ceremonies_grant_reputation'
  },
  encointerBalances: {
    transfer: 'balance_transfer'
  }
};
