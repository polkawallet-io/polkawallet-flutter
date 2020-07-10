// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'staking.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic

mixin _$StakingStore on _StakingStore, Store {
  Computed<ObservableList<ValidatorData>> _$activeNominatingListComputed;

  @override
  ObservableList<ValidatorData> get activeNominatingList =>
      (_$activeNominatingListComputed ??=
              Computed<ObservableList<ValidatorData>>(
                  () => super.activeNominatingList,
                  name: '_StakingStore.activeNominatingList'))
          .value;
  Computed<ObservableList<ValidatorData>> _$nominatingListComputed;

  @override
  ObservableList<ValidatorData> get nominatingList =>
      (_$nominatingListComputed ??= Computed<ObservableList<ValidatorData>>(
              () => super.nominatingList,
              name: '_StakingStore.nominatingList'))
          .value;
  Computed<BigInt> _$accountUnlockingTotalComputed;

  @override
  BigInt get accountUnlockingTotal => (_$accountUnlockingTotalComputed ??=
          Computed<BigInt>(() => super.accountUnlockingTotal,
              name: '_StakingStore.accountUnlockingTotal'))
      .value;
  Computed<BigInt> _$accountRewardTotalComputed;

  @override
  BigInt get accountRewardTotal => (_$accountRewardTotalComputed ??=
          Computed<BigInt>(() => super.accountRewardTotal,
              name: '_StakingStore.accountRewardTotal'))
      .value;

  final _$cacheTxsTimestampAtom = Atom(name: '_StakingStore.cacheTxsTimestamp');

  @override
  int get cacheTxsTimestamp {
    _$cacheTxsTimestampAtom.reportRead();
    return super.cacheTxsTimestamp;
  }

  @override
  set cacheTxsTimestamp(int value) {
    _$cacheTxsTimestampAtom.reportWrite(value, super.cacheTxsTimestamp, () {
      super.cacheTxsTimestamp = value;
    });
  }

  final _$overviewAtom = Atom(name: '_StakingStore.overview');

  @override
  ObservableMap<String, dynamic> get overview {
    _$overviewAtom.reportRead();
    return super.overview;
  }

  @override
  set overview(ObservableMap<String, dynamic> value) {
    _$overviewAtom.reportWrite(value, super.overview, () {
      super.overview = value;
    });
  }

  final _$stakedAtom = Atom(name: '_StakingStore.staked');

  @override
  BigInt get staked {
    _$stakedAtom.reportRead();
    return super.staked;
  }

  @override
  set staked(BigInt value) {
    _$stakedAtom.reportWrite(value, super.staked, () {
      super.staked = value;
    });
  }

  final _$nominatorCountAtom = Atom(name: '_StakingStore.nominatorCount');

  @override
  int get nominatorCount {
    _$nominatorCountAtom.reportRead();
    return super.nominatorCount;
  }

  @override
  set nominatorCount(int value) {
    _$nominatorCountAtom.reportWrite(value, super.nominatorCount, () {
      super.nominatorCount = value;
    });
  }

  final _$validatorsInfoAtom = Atom(name: '_StakingStore.validatorsInfo');

  @override
  ObservableList<ValidatorData> get validatorsInfo {
    _$validatorsInfoAtom.reportRead();
    return super.validatorsInfo;
  }

  @override
  set validatorsInfo(ObservableList<ValidatorData> value) {
    _$validatorsInfoAtom.reportWrite(value, super.validatorsInfo, () {
      super.validatorsInfo = value;
    });
  }

  final _$nextUpsInfoAtom = Atom(name: '_StakingStore.nextUpsInfo');

  @override
  ObservableList<ValidatorData> get nextUpsInfo {
    _$nextUpsInfoAtom.reportRead();
    return super.nextUpsInfo;
  }

  @override
  set nextUpsInfo(ObservableList<ValidatorData> value) {
    _$nextUpsInfoAtom.reportWrite(value, super.nextUpsInfo, () {
      super.nextUpsInfo = value;
    });
  }

  final _$ledgerAtom = Atom(name: '_StakingStore.ledger');

  @override
  ObservableMap<String, dynamic> get ledger {
    _$ledgerAtom.reportRead();
    return super.ledger;
  }

  @override
  set ledger(ObservableMap<String, dynamic> value) {
    _$ledgerAtom.reportWrite(value, super.ledger, () {
      super.ledger = value;
    });
  }

  final _$txsLoadingAtom = Atom(name: '_StakingStore.txsLoading');

  @override
  bool get txsLoading {
    _$txsLoadingAtom.reportRead();
    return super.txsLoading;
  }

  @override
  set txsLoading(bool value) {
    _$txsLoadingAtom.reportWrite(value, super.txsLoading, () {
      super.txsLoading = value;
    });
  }

  final _$txsCountAtom = Atom(name: '_StakingStore.txsCount');

  @override
  int get txsCount {
    _$txsCountAtom.reportRead();
    return super.txsCount;
  }

  @override
  set txsCount(int value) {
    _$txsCountAtom.reportWrite(value, super.txsCount, () {
      super.txsCount = value;
    });
  }

  final _$txsAtom = Atom(name: '_StakingStore.txs');

  @override
  ObservableList<TxData> get txs {
    _$txsAtom.reportRead();
    return super.txs;
  }

  @override
  set txs(ObservableList<TxData> value) {
    _$txsAtom.reportWrite(value, super.txs, () {
      super.txs = value;
    });
  }

  final _$rewardsChartDataCacheAtom =
      Atom(name: '_StakingStore.rewardsChartDataCache');

  @override
  ObservableMap<String, dynamic> get rewardsChartDataCache {
    _$rewardsChartDataCacheAtom.reportRead();
    return super.rewardsChartDataCache;
  }

  @override
  set rewardsChartDataCache(ObservableMap<String, dynamic> value) {
    _$rewardsChartDataCacheAtom.reportWrite(value, super.rewardsChartDataCache,
        () {
      super.rewardsChartDataCache = value;
    });
  }

  final _$stakesChartDataCacheAtom =
      Atom(name: '_StakingStore.stakesChartDataCache');

  @override
  ObservableMap<String, dynamic> get stakesChartDataCache {
    _$stakesChartDataCacheAtom.reportRead();
    return super.stakesChartDataCache;
  }

  @override
  set stakesChartDataCache(ObservableMap<String, dynamic> value) {
    _$stakesChartDataCacheAtom.reportWrite(value, super.stakesChartDataCache,
        () {
      super.stakesChartDataCache = value;
    });
  }

  final _$phalaAirdropWhiteListAtom =
      Atom(name: '_StakingStore.phalaAirdropWhiteList');

  @override
  Map<dynamic, dynamic> get phalaAirdropWhiteList {
    _$phalaAirdropWhiteListAtom.reportRead();
    return super.phalaAirdropWhiteList;
  }

  @override
  set phalaAirdropWhiteList(Map<dynamic, dynamic> value) {
    _$phalaAirdropWhiteListAtom.reportWrite(value, super.phalaAirdropWhiteList,
        () {
      super.phalaAirdropWhiteList = value;
    });
  }

  final _$clearTxsAsyncAction = AsyncAction('_StakingStore.clearTxs');

  @override
  Future<void> clearTxs() {
    return _$clearTxsAsyncAction.run(() => super.clearTxs());
  }

  final _$setTxsLoadingAsyncAction = AsyncAction('_StakingStore.setTxsLoading');

  @override
  Future<void> setTxsLoading(bool loading) {
    return _$setTxsLoadingAsyncAction.run(() => super.setTxsLoading(loading));
  }

  final _$addTxsAsyncAction = AsyncAction('_StakingStore.addTxs');

  @override
  Future<void> addTxs(Map<dynamic, dynamic> res, {bool shouldCache = false}) {
    return _$addTxsAsyncAction
        .run(() => super.addTxs(res, shouldCache: shouldCache));
  }

  final _$loadAccountCacheAsyncAction =
      AsyncAction('_StakingStore.loadAccountCache');

  @override
  Future<void> loadAccountCache() {
    return _$loadAccountCacheAsyncAction.run(() => super.loadAccountCache());
  }

  final _$loadCacheAsyncAction = AsyncAction('_StakingStore.loadCache');

  @override
  Future<void> loadCache() {
    return _$loadCacheAsyncAction.run(() => super.loadCache());
  }

  final _$setPhalaAirdropWhiteListAsyncAction =
      AsyncAction('_StakingStore.setPhalaAirdropWhiteList');

  @override
  Future<void> setPhalaAirdropWhiteList(List<dynamic> ls) {
    return _$setPhalaAirdropWhiteListAsyncAction
        .run(() => super.setPhalaAirdropWhiteList(ls));
  }

  final _$_StakingStoreActionController =
      ActionController(name: '_StakingStore');

  @override
  void setValidatorsInfo(Map<String, dynamic> data, {bool shouldCache = true}) {
    final _$actionInfo = _$_StakingStoreActionController.startAction(
        name: '_StakingStore.setValidatorsInfo');
    try {
      return super.setValidatorsInfo(data, shouldCache: shouldCache);
    } finally {
      _$_StakingStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setNextUpsInfo(dynamic list) {
    final _$actionInfo = _$_StakingStoreActionController.startAction(
        name: '_StakingStore.setNextUpsInfo');
    try {
      return super.setNextUpsInfo(list);
    } finally {
      _$_StakingStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setOverview(Map<String, dynamic> data, {bool shouldCache = true}) {
    final _$actionInfo = _$_StakingStoreActionController.startAction(
        name: '_StakingStore.setOverview');
    try {
      return super.setOverview(data, shouldCache: shouldCache);
    } finally {
      _$_StakingStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setLedger(String pubKey, Map<String, dynamic> data,
      {bool shouldCache = true, bool reset = false}) {
    final _$actionInfo = _$_StakingStoreActionController.startAction(
        name: '_StakingStore.setLedger');
    try {
      return super
          .setLedger(pubKey, data, shouldCache: shouldCache, reset: reset);
    } finally {
      _$_StakingStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void clearState() {
    final _$actionInfo = _$_StakingStoreActionController.startAction(
        name: '_StakingStore.clearState');
    try {
      return super.clearState();
    } finally {
      _$_StakingStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setRewardsChartData(String validatorId, Map<dynamic, dynamic> data) {
    final _$actionInfo = _$_StakingStoreActionController.startAction(
        name: '_StakingStore.setRewardsChartData');
    try {
      return super.setRewardsChartData(validatorId, data);
    } finally {
      _$_StakingStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setStakesChartData(String validatorId, Map<dynamic, dynamic> data) {
    final _$actionInfo = _$_StakingStoreActionController.startAction(
        name: '_StakingStore.setStakesChartData');
    try {
      return super.setStakesChartData(validatorId, data);
    } finally {
      _$_StakingStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
cacheTxsTimestamp: ${cacheTxsTimestamp},
overview: ${overview},
staked: ${staked},
nominatorCount: ${nominatorCount},
validatorsInfo: ${validatorsInfo},
nextUpsInfo: ${nextUpsInfo},
ledger: ${ledger},
txsLoading: ${txsLoading},
txsCount: ${txsCount},
txs: ${txs},
rewardsChartDataCache: ${rewardsChartDataCache},
stakesChartDataCache: ${stakesChartDataCache},
phalaAirdropWhiteList: ${phalaAirdropWhiteList},
activeNominatingList: ${activeNominatingList},
nominatingList: ${nominatingList},
accountUnlockingTotal: ${accountUnlockingTotal},
accountRewardTotal: ${accountRewardTotal}
    ''';
  }
}
