// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'governance.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic

mixin _$GovernanceStore on _GovernanceStore, Store {
  final _$cacheCouncilTimestampAtom =
      Atom(name: '_GovernanceStore.cacheCouncilTimestamp');

  @override
  int get cacheCouncilTimestamp {
    _$cacheCouncilTimestampAtom.context
        .enforceReadPolicy(_$cacheCouncilTimestampAtom);
    _$cacheCouncilTimestampAtom.reportObserved();
    return super.cacheCouncilTimestamp;
  }

  @override
  set cacheCouncilTimestamp(int value) {
    _$cacheCouncilTimestampAtom.context.conditionallyRunInAction(() {
      super.cacheCouncilTimestamp = value;
      _$cacheCouncilTimestampAtom.reportChanged();
    }, _$cacheCouncilTimestampAtom,
        name: '${_$cacheCouncilTimestampAtom.name}_set');
  }

  final _$bestNumberAtom = Atom(name: '_GovernanceStore.bestNumber');

  @override
  int get bestNumber {
    _$bestNumberAtom.context.enforceReadPolicy(_$bestNumberAtom);
    _$bestNumberAtom.reportObserved();
    return super.bestNumber;
  }

  @override
  set bestNumber(int value) {
    _$bestNumberAtom.context.conditionallyRunInAction(() {
      super.bestNumber = value;
      _$bestNumberAtom.reportChanged();
    }, _$bestNumberAtom, name: '${_$bestNumberAtom.name}_set');
  }

  final _$councilAtom = Atom(name: '_GovernanceStore.council');

  @override
  CouncilInfoData get council {
    _$councilAtom.context.enforceReadPolicy(_$councilAtom);
    _$councilAtom.reportObserved();
    return super.council;
  }

  @override
  set council(CouncilInfoData value) {
    _$councilAtom.context.conditionallyRunInAction(() {
      super.council = value;
      _$councilAtom.reportChanged();
    }, _$councilAtom, name: '${_$councilAtom.name}_set');
  }

  final _$councilVotesAtom = Atom(name: '_GovernanceStore.councilVotes');

  @override
  Map<String, Map<String, dynamic>> get councilVotes {
    _$councilVotesAtom.context.enforceReadPolicy(_$councilVotesAtom);
    _$councilVotesAtom.reportObserved();
    return super.councilVotes;
  }

  @override
  set councilVotes(Map<String, Map<String, dynamic>> value) {
    _$councilVotesAtom.context.conditionallyRunInAction(() {
      super.councilVotes = value;
      _$councilVotesAtom.reportChanged();
    }, _$councilVotesAtom, name: '${_$councilVotesAtom.name}_set');
  }

  final _$userCouncilVotesAtom =
      Atom(name: '_GovernanceStore.userCouncilVotes');

  @override
  Map<String, dynamic> get userCouncilVotes {
    _$userCouncilVotesAtom.context.enforceReadPolicy(_$userCouncilVotesAtom);
    _$userCouncilVotesAtom.reportObserved();
    return super.userCouncilVotes;
  }

  @override
  set userCouncilVotes(Map<String, dynamic> value) {
    _$userCouncilVotesAtom.context.conditionallyRunInAction(() {
      super.userCouncilVotes = value;
      _$userCouncilVotesAtom.reportChanged();
    }, _$userCouncilVotesAtom, name: '${_$userCouncilVotesAtom.name}_set');
  }

  final _$referendumsAtom = Atom(name: '_GovernanceStore.referendums');

  @override
  ObservableList<ReferendumInfo> get referendums {
    _$referendumsAtom.context.enforceReadPolicy(_$referendumsAtom);
    _$referendumsAtom.reportObserved();
    return super.referendums;
  }

  @override
  set referendums(ObservableList<ReferendumInfo> value) {
    _$referendumsAtom.context.conditionallyRunInAction(() {
      super.referendums = value;
      _$referendumsAtom.reportChanged();
    }, _$referendumsAtom, name: '${_$referendumsAtom.name}_set');
  }

  final _$loadCacheAsyncAction = AsyncAction('loadCache');

  @override
  Future<void> loadCache() {
    return _$loadCacheAsyncAction.run(() => super.loadCache());
  }

  final _$_GovernanceStoreActionController =
      ActionController(name: '_GovernanceStore');

  @override
  void setCouncilInfo(Map info, {bool shouldCache = true}) {
    final _$actionInfo = _$_GovernanceStoreActionController.startAction();
    try {
      return super.setCouncilInfo(info, shouldCache: shouldCache);
    } finally {
      _$_GovernanceStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setCouncilVotes(Map votes) {
    final _$actionInfo = _$_GovernanceStoreActionController.startAction();
    try {
      return super.setCouncilVotes(votes);
    } finally {
      _$_GovernanceStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setUserCouncilVotes(Map votes) {
    final _$actionInfo = _$_GovernanceStoreActionController.startAction();
    try {
      return super.setUserCouncilVotes(votes);
    } finally {
      _$_GovernanceStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setBestNumber(int number) {
    final _$actionInfo = _$_GovernanceStoreActionController.startAction();
    try {
      return super.setBestNumber(number);
    } finally {
      _$_GovernanceStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setReferendums(List ls) {
    final _$actionInfo = _$_GovernanceStoreActionController.startAction();
    try {
      return super.setReferendums(ls);
    } finally {
      _$_GovernanceStoreActionController.endAction(_$actionInfo);
    }
  }
}
