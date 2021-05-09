// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'encointer.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic

mixin _$EncointerStore on _EncointerStore, Store {
  Computed<String> _$communityNameComputed;

  @override
  String get communityName =>
      (_$communityNameComputed ??= Computed<String>(() => super.communityName,
              name: '_EncointerStore.communityName'))
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

  final _$currentCeremonyIndexAtom =
      Atom(name: '_EncointerStore.currentCeremonyIndex');

  @override
  int get currentCeremonyIndex {
    _$currentCeremonyIndexAtom.reportRead();
    return super.currentCeremonyIndex;
  }

  @override
  set currentCeremonyIndex(int value) {
    _$currentCeremonyIndexAtom.reportWrite(value, super.currentCeremonyIndex,
        () {
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

  final _$myMeetupRegistryIndexAtom =
      Atom(name: '_EncointerStore.myMeetupRegistryIndex');

  @override
  int get myMeetupRegistryIndex {
    _$myMeetupRegistryIndexAtom.reportRead();
    return super.myMeetupRegistryIndex;
  }

  @override
  set myMeetupRegistryIndex(int value) {
    _$myMeetupRegistryIndexAtom.reportWrite(value, super.myMeetupRegistryIndex,
        () {
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

  final _$participantCountAtom = Atom(name: '_EncointerStore.participantCount');

  @override
  int get participantCount {
    _$participantCountAtom.reportRead();
    return super.participantCount;
  }

  @override
  set participantCount(int value) {
    _$participantCountAtom.reportWrite(value, super.participantCount, () {
      super.participantCount = value;
    });
  }

  final _$myClaimAtom = Atom(name: '_EncointerStore.myClaim');

  @override
  ClaimOfAttendance get myClaim {
    _$myClaimAtom.reportRead();
    return super.myClaim;
  }

  @override
  set myClaim(ClaimOfAttendance value) {
    _$myClaimAtom.reportWrite(value, super.myClaim, () {
      super.myClaim = value;
    });
  }

  final _$balanceEntriesAtom = Atom(name: '_EncointerStore.balanceEntries');

  @override
  Map<String, BalanceEntry> get balanceEntries {
    _$balanceEntriesAtom.reportRead();
    return super.balanceEntries;
  }

  @override
  set balanceEntries(Map<String, BalanceEntry> value) {
    _$balanceEntriesAtom.reportWrite(value, super.balanceEntries, () {
      super.balanceEntries = value;
    });
  }

  final _$communityIdentifiersAtom =
      Atom(name: '_EncointerStore.communityIdentifiers');

  @override
  List<String> get communityIdentifiers {
    _$communityIdentifiersAtom.reportRead();
    return super.communityIdentifiers;
  }

  @override
  set communityIdentifiers(List<String> value) {
    _$communityIdentifiersAtom.reportWrite(value, super.communityIdentifiers,
        () {
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
  String get chosenCid {
    _$chosenCidAtom.reportRead();
    return super.chosenCid;
  }

  @override
  set chosenCid(String value) {
    _$chosenCidAtom.reportWrite(value, super.chosenCid, () {
      super.chosenCid = value;
    });
  }

  final _$communityMetadataAtom =
      Atom(name: '_EncointerStore.communityMetadata');

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

  final _$claimHexAtom = Atom(name: '_EncointerStore.claimHex');

  @override
  String get claimHex {
    _$claimHexAtom.reportRead();
    return super.claimHex;
  }

  @override
  set claimHex(String value) {
    _$claimHexAtom.reportWrite(value, super.claimHex, () {
      super.claimHex = value;
    });
  }

  final _$attestationsAtom = Atom(name: '_EncointerStore.attestations');

  @override
  Map<int, AttestationState> get attestations {
    _$attestationsAtom.reportRead();
    return super.attestations;
  }

  @override
  set attestations(Map<int, AttestationState> value) {
    _$attestationsAtom.reportWrite(value, super.attestations, () {
      super.attestations = value;
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

  final _$shopRegistryAtom = Atom(name: '_EncointerStore.shopRegistry');

  @override
  List<String> get shopRegistry {
    _$shopRegistryAtom.reportRead();
    return super.shopRegistry;
  }

  @override
  set shopRegistry(List<String> value) {
    _$shopRegistryAtom.reportWrite(value, super.shopRegistry, () {
      super.shopRegistry = value;
    });
  }

  final _$setTransferTxsAsyncAction =
      AsyncAction('_EncointerStore.setTransferTxs');

  @override
  Future<void> setTransferTxs(List<dynamic> list,
      {bool reset = false, dynamic needCache = true}) {
    return _$setTransferTxsAsyncAction.run(
        () => super.setTransferTxs(list, reset: reset, needCache: needCache));
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

  final _$_EncointerStoreActionController =
      ActionController(name: '_EncointerStore');

  @override
  void setCurrentPhase(CeremonyPhase phase) {
    final _$actionInfo = _$_EncointerStoreActionController.startAction(
        name: '_EncointerStore.setCurrentPhase');
    try {
      return super.setCurrentPhase(phase);
    } finally {
      _$_EncointerStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setCurrentCeremonyIndex(dynamic index) {
    final _$actionInfo = _$_EncointerStoreActionController.startAction(
        name: '_EncointerStore.setCurrentCeremonyIndex');
    try {
      return super.setCurrentCeremonyIndex(index);
    } finally {
      _$_EncointerStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void updateState() {
    final _$actionInfo = _$_EncointerStoreActionController.startAction(
        name: '_EncointerStore.updateState');
    try {
      return super.updateState();
    } finally {
      _$_EncointerStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setMeetupIndex([int index]) {
    final _$actionInfo = _$_EncointerStoreActionController.startAction(
        name: '_EncointerStore.setMeetupIndex');
    try {
      return super.setMeetupIndex(index);
    } finally {
      _$_EncointerStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setMeetupLocation([Location location]) {
    final _$actionInfo = _$_EncointerStoreActionController.startAction(
        name: '_EncointerStore.setMeetupLocation');
    try {
      return super.setMeetupLocation(location);
    } finally {
      _$_EncointerStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setMeetupTime([int time]) {
    final _$actionInfo = _$_EncointerStoreActionController.startAction(
        name: '_EncointerStore.setMeetupTime');
    try {
      return super.setMeetupTime(time);
    } finally {
      _$_EncointerStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setMeetupRegistry([List<String> reg]) {
    final _$actionInfo = _$_EncointerStoreActionController.startAction(
        name: '_EncointerStore.setMeetupRegistry');
    try {
      return super.setMeetupRegistry(reg);
    } finally {
      _$_EncointerStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setMyClaim([ClaimOfAttendance claim]) {
    final _$actionInfo = _$_EncointerStoreActionController.startAction(
        name: '_EncointerStore.setMyClaim');
    try {
      return super.setMyClaim(claim);
    } finally {
      _$_EncointerStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setClaimHex([String claimHex]) {
    final _$actionInfo = _$_EncointerStoreActionController.startAction(
        name: '_EncointerStore.setClaimHex');
    try {
      return super.setClaimHex(claimHex);
    } finally {
      _$_EncointerStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setMyMeetupRegistryIndex([int index]) {
    final _$actionInfo = _$_EncointerStoreActionController.startAction(
        name: '_EncointerStore.setMyMeetupRegistryIndex');
    try {
      return super.setMyMeetupRegistryIndex(index);
    } finally {
      _$_EncointerStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setCommunityIdentifiers(List<String> cids) {
    final _$actionInfo = _$_EncointerStoreActionController.startAction(
        name: '_EncointerStore.setCommunityIdentifiers');
    try {
      return super.setCommunityIdentifiers(cids);
    } finally {
      _$_EncointerStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setCommunityMetadata(CommunityMetadata meta) {
    final _$actionInfo = _$_EncointerStoreActionController.startAction(
        name: '_EncointerStore.setCommunityMetadata');
    try {
      return super.setCommunityMetadata(meta);
    } finally {
      _$_EncointerStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setCommunities(List<CidName> c) {
    final _$actionInfo = _$_EncointerStoreActionController.startAction(
        name: '_EncointerStore.setCommunities');
    try {
      return super.setCommunities(c);
    } finally {
      _$_EncointerStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setChosenCid(String cid) {
    final _$actionInfo = _$_EncointerStoreActionController.startAction(
        name: '_EncointerStore.setChosenCid');
    try {
      return super.setChosenCid(cid);
    } finally {
      _$_EncointerStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void addYourAttestation(int idx, String att) {
    final _$actionInfo = _$_EncointerStoreActionController.startAction(
        name: '_EncointerStore.addYourAttestation');
    try {
      return super.addYourAttestation(idx, att);
    } finally {
      _$_EncointerStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void addOtherAttestation(int idx, String att) {
    final _$actionInfo = _$_EncointerStoreActionController.startAction(
        name: '_EncointerStore.addOtherAttestation');
    try {
      return super.addOtherAttestation(idx, att);
    } finally {
      _$_EncointerStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void updateAttestationStep(int idx, CurrentAttestationStep step) {
    final _$actionInfo = _$_EncointerStoreActionController.startAction(
        name: '_EncointerStore.updateAttestationStep');
    try {
      return super.updateAttestationStep(idx, step);
    } finally {
      _$_EncointerStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void purgeAttestations() {
    final _$actionInfo = _$_EncointerStoreActionController.startAction(
        name: '_EncointerStore.purgeAttestations');
    try {
      return super.purgeAttestations();
    } finally {
      _$_EncointerStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void addBalanceEntry(String cid, BalanceEntry balanceEntry) {
    final _$actionInfo = _$_EncointerStoreActionController.startAction(
        name: '_EncointerStore.addBalanceEntry');
    try {
      return super.addBalanceEntry(cid, balanceEntry);
    } finally {
      _$_EncointerStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setParticipantIndex(int pIndex) {
    final _$actionInfo = _$_EncointerStoreActionController.startAction(
        name: '_EncointerStore.setParticipantIndex');
    try {
      return super.setParticipantIndex(pIndex);
    } finally {
      _$_EncointerStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setParticipantCount(int pCount) {
    final _$actionInfo = _$_EncointerStoreActionController.startAction(
        name: '_EncointerStore.setParticipantCount');
    try {
      return super.setParticipantCount(pCount);
    } finally {
      _$_EncointerStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setShopRegistry(List<String> shops) {
    final _$actionInfo = _$_EncointerStoreActionController.startAction(
        name: '_EncointerStore.setShopRegistry');
    try {
      return super.setShopRegistry(shops);
    } finally {
      _$_EncointerStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
currentPhase: ${currentPhase},
currentCeremonyIndex: ${currentCeremonyIndex},
meetupIndex: ${meetupIndex},
meetupLocation: ${meetupLocation},
meetupTime: ${meetupTime},
meetupRegistry: ${meetupRegistry},
myMeetupRegistryIndex: ${myMeetupRegistryIndex},
participantIndex: ${participantIndex},
participantCount: ${participantCount},
myClaim: ${myClaim},
balanceEntries: ${balanceEntries},
communityIdentifiers: ${communityIdentifiers},
communities: ${communities},
chosenCid: ${chosenCid},
communityMetadata: ${communityMetadata},
claimHex: ${claimHex},
attestations: ${attestations},
txsTransfer: ${txsTransfer},
shopRegistry: ${shopRegistry},
communityName: ${communityName}
    ''';
  }
}
