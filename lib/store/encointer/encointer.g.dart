// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'encointer.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic

mixin _$EncointerStore on _EncointerStore, Store {
  Computed<dynamic> _$currentPhaseDurationComputed;

  @override
  dynamic get currentPhaseDuration => (_$currentPhaseDurationComputed ??=
          Computed<dynamic>(() => super.currentPhaseDuration, name: '_EncointerStore.currentPhaseDuration'))
      .value;
  Computed<dynamic> _$scannedClaimsCountComputed;

  @override
  dynamic get scannedClaimsCount => (_$scannedClaimsCountComputed ??=
          Computed<dynamic>(() => super.scannedClaimsCount, name: '_EncointerStore.scannedClaimsCount'))
      .value;
  Computed<String> _$communityNameComputed;

  @override
  String get communityName =>
      (_$communityNameComputed ??= Computed<String>(() => super.communityName, name: '_EncointerStore.communityName'))
          .value;
  Computed<String> _$communitySymbolComputed;

  @override
  String get communitySymbol => (_$communitySymbolComputed ??=
          Computed<String>(() => super.communitySymbol, name: '_EncointerStore.communitySymbol'))
      .value;
  Computed<String> _$communityIconsCidComputed;

  @override
  String get communityIconsCid => (_$communityIconsCidComputed ??=
          Computed<String>(() => super.communityIconsCid, name: '_EncointerStore.communityIconsCid'))
      .value;
  Computed<BalanceEntry> _$communityBalanceEntryComputed;

  @override
  BalanceEntry get communityBalanceEntry => (_$communityBalanceEntryComputed ??=
          Computed<BalanceEntry>(() => super.communityBalanceEntry, name: '_EncointerStore.communityBalanceEntry'))
      .value;
  Computed<double> _$communityBalanceComputed;

  @override
  double get communityBalance => (_$communityBalanceComputed ??=
          Computed<double>(() => super.communityBalance, name: '_EncointerStore.communityBalance'))
      .value;

  final _$currentPhaseAtom = Atom(name: '_EncointerStore.currentPhase');

  @override
  CeremonyPhase get currentPhase {
    _$currentPhaseAtom.reportRead();
    return super.currentPhase;
  }

  @override
  set currentPhase(CeremonyPhase value) {
    _$currentPhaseAtom.reportWrite(value, super.currentPhase, () {
      super.currentPhase = value;
    });
  }

  final _$phaseDurationsAtom = Atom(name: '_EncointerStore.phaseDurations');

  @override
  Map<CeremonyPhase, int> get phaseDurations {
    _$phaseDurationsAtom.reportRead();
    return super.phaseDurations;
  }

  @override
  set phaseDurations(Map<CeremonyPhase, int> value) {
    _$phaseDurationsAtom.reportWrite(value, super.phaseDurations, () {
      super.phaseDurations = value;
    });
  }

  final _$currentCeremonyIndexAtom = Atom(name: '_EncointerStore.currentCeremonyIndex');

  @override
  int get currentCeremonyIndex {
    _$currentCeremonyIndexAtom.reportRead();
    return super.currentCeremonyIndex;
  }

  @override
  set currentCeremonyIndex(int value) {
    _$currentCeremonyIndexAtom.reportWrite(value, super.currentCeremonyIndex, () {
      super.currentCeremonyIndex = value;
    });
  }

  final _$meetupIndexAtom = Atom(name: '_EncointerStore.meetupIndex');

  @override
  int get meetupIndex {
    _$meetupIndexAtom.reportRead();
    return super.meetupIndex;
  }

  @override
  set meetupIndex(int value) {
    _$meetupIndexAtom.reportWrite(value, super.meetupIndex, () {
      super.meetupIndex = value;
    });
  }

  final _$meetupLocationAtom = Atom(name: '_EncointerStore.meetupLocation');

  @override
  Location get meetupLocation {
    _$meetupLocationAtom.reportRead();
    return super.meetupLocation;
  }

  @override
  set meetupLocation(Location value) {
    _$meetupLocationAtom.reportWrite(value, super.meetupLocation, () {
      super.meetupLocation = value;
    });
  }

  final _$meetupTimeAtom = Atom(name: '_EncointerStore.meetupTime');

  @override
  int get meetupTime {
    _$meetupTimeAtom.reportRead();
    return super.meetupTime;
  }

  @override
  set meetupTime(int value) {
    _$meetupTimeAtom.reportWrite(value, super.meetupTime, () {
      super.meetupTime = value;
    });
  }

  final _$meetupRegistryAtom = Atom(name: '_EncointerStore.meetupRegistry');

  @override
  List<String> get meetupRegistry {
    _$meetupRegistryAtom.reportRead();
    return super.meetupRegistry;
  }

  @override
  set meetupRegistry(List<String> value) {
    _$meetupRegistryAtom.reportWrite(value, super.meetupRegistry, () {
      super.meetupRegistry = value;
    });
  }

  final _$myMeetupRegistryIndexAtom = Atom(name: '_EncointerStore.myMeetupRegistryIndex');

  @override
  int get myMeetupRegistryIndex {
    _$myMeetupRegistryIndexAtom.reportRead();
    return super.myMeetupRegistryIndex;
  }

  @override
  set myMeetupRegistryIndex(int value) {
    _$myMeetupRegistryIndexAtom.reportWrite(value, super.myMeetupRegistryIndex, () {
      super.myMeetupRegistryIndex = value;
    });
  }

  final _$participantIndexAtom = Atom(name: '_EncointerStore.participantIndex');

  @override
  int get participantIndex {
    _$participantIndexAtom.reportRead();
    return super.participantIndex;
  }

  @override
  set participantIndex(int value) {
    _$participantIndexAtom.reportWrite(value, super.participantIndex, () {
      super.participantIndex = value;
    });
  }

  final _$balanceEntriesAtom = Atom(name: '_EncointerStore.balanceEntries');

  @override
  Map<CommunityIdentifier, BalanceEntry> get balanceEntries {
    _$balanceEntriesAtom.reportRead();
    return super.balanceEntries;
  }

  @override
  set balanceEntries(Map<CommunityIdentifier, BalanceEntry> value) {
    _$balanceEntriesAtom.reportWrite(value, super.balanceEntries, () {
      super.balanceEntries = value;
    });
  }

  final _$communityIdentifiersAtom = Atom(name: '_EncointerStore.communityIdentifiers');

  @override
  List<CommunityIdentifier> get communityIdentifiers {
    _$communityIdentifiersAtom.reportRead();
    return super.communityIdentifiers;
  }

  @override
  set communityIdentifiers(List<CommunityIdentifier> value) {
    _$communityIdentifiersAtom.reportWrite(value, super.communityIdentifiers, () {
      super.communityIdentifiers = value;
    });
  }

  final _$communitiesAtom = Atom(name: '_EncointerStore.communities');

  @override
  List<CidName> get communities {
    _$communitiesAtom.reportRead();
    return super.communities;
  }

  @override
  set communities(List<CidName> value) {
    _$communitiesAtom.reportWrite(value, super.communities, () {
      super.communities = value;
    });
  }

  final _$chosenCidAtom = Atom(name: '_EncointerStore.chosenCid');

  @override
  CommunityIdentifier get chosenCid {
    _$chosenCidAtom.reportRead();
    return super.chosenCid;
  }

  @override
  set chosenCid(CommunityIdentifier value) {
    _$chosenCidAtom.reportWrite(value, super.chosenCid, () {
      super.chosenCid = value;
    });
  }

  final _$communityMetadataAtom = Atom(name: '_EncointerStore.communityMetadata');

  @override
  CommunityMetadata get communityMetadata {
    _$communityMetadataAtom.reportRead();
    return super.communityMetadata;
  }

  @override
  set communityMetadata(CommunityMetadata value) {
    _$communityMetadataAtom.reportWrite(value, super.communityMetadata, () {
      super.communityMetadata = value;
    });
  }

  final _$demurrageAtom = Atom(name: '_EncointerStore.demurrage');

  @override
  double get demurrage {
    _$demurrageAtom.reportRead();
    return super.demurrage;
  }

  @override
  set demurrage(double value) {
    _$demurrageAtom.reportWrite(value, super.demurrage, () {
      super.demurrage = value;
    });
  }

  final _$participantsClaimsAtom = Atom(name: '_EncointerStore.participantsClaims');

  @override
  ObservableMap<String, ClaimOfAttendance> get participantsClaims {
    _$participantsClaimsAtom.reportRead();
    return super.participantsClaims;
  }

  @override
  set participantsClaims(ObservableMap<String, ClaimOfAttendance> value) {
    _$participantsClaimsAtom.reportWrite(value, super.participantsClaims, () {
      super.participantsClaims = value;
    });
  }

  final _$txsTransferAtom = Atom(name: '_EncointerStore.txsTransfer');

  @override
  ObservableList<TransferData> get txsTransfer {
    _$txsTransferAtom.reportRead();
    return super.txsTransfer;
  }

  @override
  set txsTransfer(ObservableList<TransferData> value) {
    _$txsTransferAtom.reportWrite(value, super.txsTransfer, () {
      super.txsTransfer = value;
    });
  }

  final _$businessRegistryAtom = Atom(name: '_EncointerStore.businessRegistry');

  @override
  ObservableList<AccountBusinessTuple> get businessRegistry {
    _$businessRegistryAtom.reportRead();
    return super.businessRegistry;
  }

  @override
  set businessRegistry(ObservableList<AccountBusinessTuple> value) {
    _$businessRegistryAtom.reportWrite(value, super.businessRegistry, () {
      super.businessRegistry = value;
    });
  }

  final _$setTransferTxsAsyncAction = AsyncAction('_EncointerStore.setTransferTxs');

  @override
  Future<void> setTransferTxs(List<dynamic> list, {bool reset = false, dynamic needCache = true}) {
    return _$setTransferTxsAsyncAction.run(() => super.setTransferTxs(list, reset: reset, needCache: needCache));
  }

  final _$_cacheTxsAsyncAction = AsyncAction('_EncointerStore._cacheTxs');

  @override
  Future<void> _cacheTxs(List<dynamic> list, String cacheKey) {
    return _$_cacheTxsAsyncAction.run(() => super._cacheTxs(list, cacheKey));
  }

  final _$loadCacheAsyncAction = AsyncAction('_EncointerStore.loadCache');

  @override
  Future<void> loadCache() {
    return _$loadCacheAsyncAction.run(() => super.loadCache());
  }

  final _$_EncointerStoreActionController = ActionController(name: '_EncointerStore');

  @override
  void setCurrentPhase(CeremonyPhase phase) {
    final _$actionInfo = _$_EncointerStoreActionController.startAction(name: '_EncointerStore.setCurrentPhase');
    try {
      return super.setCurrentPhase(phase);
    } finally {
      _$_EncointerStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setCurrentCeremonyIndex(dynamic index) {
    final _$actionInfo = _$_EncointerStoreActionController.startAction(name: '_EncointerStore.setCurrentCeremonyIndex');
    try {
      return super.setCurrentCeremonyIndex(index);
    } finally {
      _$_EncointerStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void updateState() {
    final _$actionInfo = _$_EncointerStoreActionController.startAction(name: '_EncointerStore.updateState');
    try {
      return super.updateState();
    } finally {
      _$_EncointerStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  dynamic resetState() {
    final _$actionInfo = _$_EncointerStoreActionController.startAction(name: '_EncointerStore.resetState');
    try {
      return super.resetState();
    } finally {
      _$_EncointerStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setMeetupIndex([int index]) {
    final _$actionInfo = _$_EncointerStoreActionController.startAction(name: '_EncointerStore.setMeetupIndex');
    try {
      return super.setMeetupIndex(index);
    } finally {
      _$_EncointerStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setMeetupLocation([Location location]) {
    final _$actionInfo = _$_EncointerStoreActionController.startAction(name: '_EncointerStore.setMeetupLocation');
    try {
      return super.setMeetupLocation(location);
    } finally {
      _$_EncointerStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setMeetupTime([int time]) {
    final _$actionInfo = _$_EncointerStoreActionController.startAction(name: '_EncointerStore.setMeetupTime');
    try {
      return super.setMeetupTime(time);
    } finally {
      _$_EncointerStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setMeetupRegistry([List<String> reg]) {
    final _$actionInfo = _$_EncointerStoreActionController.startAction(name: '_EncointerStore.setMeetupRegistry');
    try {
      return super.setMeetupRegistry(reg);
    } finally {
      _$_EncointerStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setMyMeetupRegistryIndex([int index]) {
    final _$actionInfo =
        _$_EncointerStoreActionController.startAction(name: '_EncointerStore.setMyMeetupRegistryIndex');
    try {
      return super.setMyMeetupRegistryIndex(index);
    } finally {
      _$_EncointerStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setCommunityIdentifiers(List<CommunityIdentifier> cids) {
    final _$actionInfo = _$_EncointerStoreActionController.startAction(name: '_EncointerStore.setCommunityIdentifiers');
    try {
      return super.setCommunityIdentifiers(cids);
    } finally {
      _$_EncointerStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setCommunityMetadata([CommunityMetadata meta]) {
    final _$actionInfo = _$_EncointerStoreActionController.startAction(name: '_EncointerStore.setCommunityMetadata');
    try {
      return super.setCommunityMetadata(meta);
    } finally {
      _$_EncointerStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setCommunities(List<CidName> c) {
    final _$actionInfo = _$_EncointerStoreActionController.startAction(name: '_EncointerStore.setCommunities');
    try {
      return super.setCommunities(c);
    } finally {
      _$_EncointerStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setDemurrage(double d) {
    final _$actionInfo = _$_EncointerStoreActionController.startAction(name: '_EncointerStore.setDemurrage');
    try {
      return super.setDemurrage(d);
    } finally {
      _$_EncointerStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setChosenCid([CommunityIdentifier cid]) {
    final _$actionInfo = _$_EncointerStoreActionController.startAction(name: '_EncointerStore.setChosenCid');
    try {
      return super.setChosenCid(cid);
    } finally {
      _$_EncointerStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void purgeParticipantsClaims() {
    final _$actionInfo = _$_EncointerStoreActionController.startAction(name: '_EncointerStore.purgeParticipantsClaims');
    try {
      return super.purgeParticipantsClaims();
    } finally {
      _$_EncointerStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void addParticipantClaim(ClaimOfAttendance claim) {
    final _$actionInfo = _$_EncointerStoreActionController.startAction(name: '_EncointerStore.addParticipantClaim');
    try {
      return super.addParticipantClaim(claim);
    } finally {
      _$_EncointerStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void addBalanceEntry(CommunityIdentifier cid, BalanceEntry balanceEntry) {
    final _$actionInfo = _$_EncointerStoreActionController.startAction(name: '_EncointerStore.addBalanceEntry');
    try {
      return super.addBalanceEntry(cid, balanceEntry);
    } finally {
      _$_EncointerStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setParticipantIndex([int pIndex]) {
    final _$actionInfo = _$_EncointerStoreActionController.startAction(name: '_EncointerStore.setParticipantIndex');
    try {
      return super.setParticipantIndex(pIndex);
    } finally {
      _$_EncointerStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setbusinessRegistry(List<AccountBusinessTuple> accBusinesses) {
    final _$actionInfo = _$_EncointerStoreActionController.startAction(name: '_EncointerStore.setbusinessRegistry');
    try {
      return super.setbusinessRegistry(accBusinesses);
    } finally {
      _$_EncointerStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
currentPhase: ${currentPhase},
phaseDurations: ${phaseDurations},
currentCeremonyIndex: ${currentCeremonyIndex},
meetupIndex: ${meetupIndex},
meetupLocation: ${meetupLocation},
meetupTime: ${meetupTime},
meetupRegistry: ${meetupRegistry},
myMeetupRegistryIndex: ${myMeetupRegistryIndex},
participantIndex: ${participantIndex},
balanceEntries: ${balanceEntries},
communityIdentifiers: ${communityIdentifiers},
communities: ${communities},
chosenCid: ${chosenCid},
communityMetadata: ${communityMetadata},
demurrage: ${demurrage},
participantsClaims: ${participantsClaims},
txsTransfer: ${txsTransfer},
businessRegistry: ${businessRegistry},
currentPhaseDuration: ${currentPhaseDuration},
scannedClaimsCount: ${scannedClaimsCount},
communityName: ${communityName},
communitySymbol: ${communitySymbol},
communityIconsCid: ${communityIconsCid},
communityBalanceEntry: ${communityBalanceEntry},
communityBalance: ${communityBalance}
    ''';
  }
}
