// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'staking.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic

mixin _$StakingStore on _StakingStore, Store {
  Computed<ObservableList<String>> _$nextUpsComputed;

  @override
  ObservableList<String> get nextUps => (_$nextUpsComputed ??=
          Computed<ObservableList<String>>(() => super.nextUps))
      .value;
  Computed<ObservableList<ValidatorData>> _$nominatingListComputed;

  @override
  ObservableList<ValidatorData> get nominatingList =>
      (_$nominatingListComputed ??= Computed<ObservableList<ValidatorData>>(
              () => super.nominatingList))
          .value;
  Computed<int> _$accountRewardTotalComputed;

  @override
  int get accountRewardTotal => (_$accountRewardTotalComputed ??=
          Computed<int>(() => super.accountRewardTotal))
      .value;

  final _$cacheTxsTimestampAtom = Atom(name: '_StakingStore.cacheTxsTimestamp');

  @override
  int get cacheTxsTimestamp {
    _$cacheTxsTimestampAtom.context.enforceReadPolicy(_$cacheTxsTimestampAtom);
    _$cacheTxsTimestampAtom.reportObserved();
    return super.cacheTxsTimestamp;
  }

  @override
  set cacheTxsTimestamp(int value) {
    _$cacheTxsTimestampAtom.context.conditionallyRunInAction(() {
      super.cacheTxsTimestamp = value;
      _$cacheTxsTimestampAtom.reportChanged();
    }, _$cacheTxsTimestampAtom, name: '${_$cacheTxsTimestampAtom.name}_set');
  }

  final _$overviewAtom = Atom(name: '_StakingStore.overview');

  @override
  ObservableMap<String, dynamic> get overview {
    _$overviewAtom.context.enforceReadPolicy(_$overviewAtom);
    _$overviewAtom.reportObserved();
    return super.overview;
  }

  @override
  set overview(ObservableMap<String, dynamic> value) {
    _$overviewAtom.context.conditionallyRunInAction(() {
      super.overview = value;
      _$overviewAtom.reportChanged();
    }, _$overviewAtom, name: '${_$overviewAtom.name}_set');
  }

  final _$doneAtom = Atom(name: '_StakingStore.done');

  @override
  bool get done {
    _$doneAtom.context.enforceReadPolicy(_$doneAtom);
    _$doneAtom.reportObserved();
    return super.done;
  }

  @override
  set done(bool value) {
    _$doneAtom.context.conditionallyRunInAction(() {
      super.done = value;
      _$doneAtom.reportChanged();
    }, _$doneAtom, name: '${_$doneAtom.name}_set');
  }

  final _$stakedAtom = Atom(name: '_StakingStore.staked');

  @override
  int get staked {
    _$stakedAtom.context.enforceReadPolicy(_$stakedAtom);
    _$stakedAtom.reportObserved();
    return super.staked;
  }

  @override
  set staked(int value) {
    _$stakedAtom.context.conditionallyRunInAction(() {
      super.staked = value;
      _$stakedAtom.reportChanged();
    }, _$stakedAtom, name: '${_$stakedAtom.name}_set');
  }

  final _$nominatorCountAtom = Atom(name: '_StakingStore.nominatorCount');

  @override
  int get nominatorCount {
    _$nominatorCountAtom.context.enforceReadPolicy(_$nominatorCountAtom);
    _$nominatorCountAtom.reportObserved();
    return super.nominatorCount;
  }

  @override
  set nominatorCount(int value) {
    _$nominatorCountAtom.context.conditionallyRunInAction(() {
      super.nominatorCount = value;
      _$nominatorCountAtom.reportChanged();
    }, _$nominatorCountAtom, name: '${_$nominatorCountAtom.name}_set');
  }

  final _$validatorsInfoAtom = Atom(name: '_StakingStore.validatorsInfo');

  @override
  ObservableList<ValidatorData> get validatorsInfo {
    _$validatorsInfoAtom.context.enforceReadPolicy(_$validatorsInfoAtom);
    _$validatorsInfoAtom.reportObserved();
    return super.validatorsInfo;
  }

  @override
  set validatorsInfo(ObservableList<ValidatorData> value) {
    _$validatorsInfoAtom.context.conditionallyRunInAction(() {
      super.validatorsInfo = value;
      _$validatorsInfoAtom.reportChanged();
    }, _$validatorsInfoAtom, name: '${_$validatorsInfoAtom.name}_set');
  }

  final _$nextUpsInfoAtom = Atom(name: '_StakingStore.nextUpsInfo');

  @override
  ObservableList<ValidatorData> get nextUpsInfo {
    _$nextUpsInfoAtom.context.enforceReadPolicy(_$nextUpsInfoAtom);
    _$nextUpsInfoAtom.reportObserved();
    return super.nextUpsInfo;
  }

  @override
  set nextUpsInfo(ObservableList<ValidatorData> value) {
    _$nextUpsInfoAtom.context.conditionallyRunInAction(() {
      super.nextUpsInfo = value;
      _$nextUpsInfoAtom.reportChanged();
    }, _$nextUpsInfoAtom, name: '${_$nextUpsInfoAtom.name}_set');
  }

  final _$ledgerAtom = Atom(name: '_StakingStore.ledger');

  @override
  ObservableMap<String, dynamic> get ledger {
    _$ledgerAtom.context.enforceReadPolicy(_$ledgerAtom);
    _$ledgerAtom.reportObserved();
    return super.ledger;
  }

  @override
  set ledger(ObservableMap<String, dynamic> value) {
    _$ledgerAtom.context.conditionallyRunInAction(() {
      super.ledger = value;
      _$ledgerAtom.reportChanged();
    }, _$ledgerAtom, name: '${_$ledgerAtom.name}_set');
  }

  final _$txsAtom = Atom(name: '_StakingStore.txs');

  @override
  ObservableList<Map> get txs {
    _$txsAtom.context.enforceReadPolicy(_$txsAtom);
    _$txsAtom.reportObserved();
    return super.txs;
  }

  @override
  set txs(ObservableList<Map> value) {
    _$txsAtom.context.conditionallyRunInAction(() {
      super.txs = value;
      _$txsAtom.reportChanged();
    }, _$txsAtom, name: '${_$txsAtom.name}_set');
  }

  final _$rewardsChartDataCacheAtom =
      Atom(name: '_StakingStore.rewardsChartDataCache');

  @override
  ObservableMap<String, dynamic> get rewardsChartDataCache {
    _$rewardsChartDataCacheAtom.context
        .enforceReadPolicy(_$rewardsChartDataCacheAtom);
    _$rewardsChartDataCacheAtom.reportObserved();
    return super.rewardsChartDataCache;
  }

  @override
  set rewardsChartDataCache(ObservableMap<String, dynamic> value) {
    _$rewardsChartDataCacheAtom.context.conditionallyRunInAction(() {
      super.rewardsChartDataCache = value;
      _$rewardsChartDataCacheAtom.reportChanged();
    }, _$rewardsChartDataCacheAtom,
        name: '${_$rewardsChartDataCacheAtom.name}_set');
  }

  final _$stakesChartDataCacheAtom =
      Atom(name: '_StakingStore.stakesChartDataCache');

  @override
  ObservableMap<String, dynamic> get stakesChartDataCache {
    _$stakesChartDataCacheAtom.context
        .enforceReadPolicy(_$stakesChartDataCacheAtom);
    _$stakesChartDataCacheAtom.reportObserved();
    return super.stakesChartDataCache;
  }

  @override
  set stakesChartDataCache(ObservableMap<String, dynamic> value) {
    _$stakesChartDataCacheAtom.context.conditionallyRunInAction(() {
      super.stakesChartDataCache = value;
      _$stakesChartDataCacheAtom.reportChanged();
    }, _$stakesChartDataCacheAtom,
        name: '${_$stakesChartDataCacheAtom.name}_set');
  }

  final _$clearTxsAsyncAction = AsyncAction('clearTxs');

  @override
  Future<void> clearTxs() {
    return _$clearTxsAsyncAction.run(() => super.clearTxs());
  }

  final _$addTxsAsyncAction = AsyncAction('addTxs');

  @override
  Future<void> addTxs(List<Map> ls, {bool shouldCache = false}) {
    return _$addTxsAsyncAction
        .run(() => super.addTxs(ls, shouldCache: shouldCache));
  }

  final _$loadCacheAsyncAction = AsyncAction('loadCache');

  @override
  Future<void> loadCache() {
    return _$loadCacheAsyncAction.run(() => super.loadCache());
  }

  final _$_StakingStoreActionController =
      ActionController(name: '_StakingStore');

  @override
  void setValidatorsInfo(Map<String, dynamic> data, {bool shouldCache = true}) {
    final _$actionInfo = _$_StakingStoreActionController.startAction();
    try {
      return super.setValidatorsInfo(data, shouldCache: shouldCache);
    } finally {
      _$_StakingStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setNextUpsInfo(dynamic list) {
    final _$actionInfo = _$_StakingStoreActionController.startAction();
    try {
      return super.setNextUpsInfo(list);
    } finally {
      _$_StakingStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setOverview(Map<String, dynamic> data) {
    final _$actionInfo = _$_StakingStoreActionController.startAction();
    try {
      return super.setOverview(data);
    } finally {
      _$_StakingStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setLedger(Map<String, dynamic> data, {bool shouldCache = true}) {
    final _$actionInfo = _$_StakingStoreActionController.startAction();
    try {
      return super.setLedger(data, shouldCache: shouldCache);
    } finally {
      _$_StakingStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void clearSate() {
    final _$actionInfo = _$_StakingStoreActionController.startAction();
    try {
      return super.clearSate();
    } finally {
      _$_StakingStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setRewardsChartData(String validatorId, Map data) {
    final _$actionInfo = _$_StakingStoreActionController.startAction();
    try {
      return super.setRewardsChartData(validatorId, data);
    } finally {
      _$_StakingStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setStakesChartData(String validatorId, Map data) {
    final _$actionInfo = _$_StakingStoreActionController.startAction();
    try {
      return super.setStakesChartData(validatorId, data);
    } finally {
      _$_StakingStoreActionController.endAction(_$actionInfo);
    }
  }
}

mixin _$ValidatorData on _ValidatorData, Store {
  final _$accountIdAtom = Atom(name: '_ValidatorData.accountId');

  @override
  String get accountId {
    _$accountIdAtom.context.enforceReadPolicy(_$accountIdAtom);
    _$accountIdAtom.reportObserved();
    return super.accountId;
  }

  @override
  set accountId(String value) {
    _$accountIdAtom.context.conditionallyRunInAction(() {
      super.accountId = value;
      _$accountIdAtom.reportChanged();
    }, _$accountIdAtom, name: '${_$accountIdAtom.name}_set');
  }

  final _$totalAtom = Atom(name: '_ValidatorData.total');

  @override
  int get total {
    _$totalAtom.context.enforceReadPolicy(_$totalAtom);
    _$totalAtom.reportObserved();
    return super.total;
  }

  @override
  set total(int value) {
    _$totalAtom.context.conditionallyRunInAction(() {
      super.total = value;
      _$totalAtom.reportChanged();
    }, _$totalAtom, name: '${_$totalAtom.name}_set');
  }

  final _$bondOwnAtom = Atom(name: '_ValidatorData.bondOwn');

  @override
  int get bondOwn {
    _$bondOwnAtom.context.enforceReadPolicy(_$bondOwnAtom);
    _$bondOwnAtom.reportObserved();
    return super.bondOwn;
  }

  @override
  set bondOwn(int value) {
    _$bondOwnAtom.context.conditionallyRunInAction(() {
      super.bondOwn = value;
      _$bondOwnAtom.reportChanged();
    }, _$bondOwnAtom, name: '${_$bondOwnAtom.name}_set');
  }

  final _$bondOtherAtom = Atom(name: '_ValidatorData.bondOther');

  @override
  int get bondOther {
    _$bondOtherAtom.context.enforceReadPolicy(_$bondOtherAtom);
    _$bondOtherAtom.reportObserved();
    return super.bondOther;
  }

  @override
  set bondOther(int value) {
    _$bondOtherAtom.context.conditionallyRunInAction(() {
      super.bondOther = value;
      _$bondOtherAtom.reportChanged();
    }, _$bondOtherAtom, name: '${_$bondOtherAtom.name}_set');
  }

  final _$pointsAtom = Atom(name: '_ValidatorData.points');

  @override
  int get points {
    _$pointsAtom.context.enforceReadPolicy(_$pointsAtom);
    _$pointsAtom.reportObserved();
    return super.points;
  }

  @override
  set points(int value) {
    _$pointsAtom.context.conditionallyRunInAction(() {
      super.points = value;
      _$pointsAtom.reportChanged();
    }, _$pointsAtom, name: '${_$pointsAtom.name}_set');
  }

  final _$commissionAtom = Atom(name: '_ValidatorData.commission');

  @override
  String get commission {
    _$commissionAtom.context.enforceReadPolicy(_$commissionAtom);
    _$commissionAtom.reportObserved();
    return super.commission;
  }

  @override
  set commission(String value) {
    _$commissionAtom.context.conditionallyRunInAction(() {
      super.commission = value;
      _$commissionAtom.reportChanged();
    }, _$commissionAtom, name: '${_$commissionAtom.name}_set');
  }

  final _$nominatorsAtom = Atom(name: '_ValidatorData.nominators');

  @override
  List<Map<String, dynamic>> get nominators {
    _$nominatorsAtom.context.enforceReadPolicy(_$nominatorsAtom);
    _$nominatorsAtom.reportObserved();
    return super.nominators;
  }

  @override
  set nominators(List<Map<String, dynamic>> value) {
    _$nominatorsAtom.context.conditionallyRunInAction(() {
      super.nominators = value;
      _$nominatorsAtom.reportChanged();
    }, _$nominatorsAtom, name: '${_$nominatorsAtom.name}_set');
  }
}
