class AccountBondedInfo {
  AccountBondedInfo(this.pubKey, this.controllerId, this.stashId);
  final String pubKey;
  // controllerId != null, means the account is a stash
  final String controllerId;
  // stashId != null, means the account is a controller
  final String stashId;
}
