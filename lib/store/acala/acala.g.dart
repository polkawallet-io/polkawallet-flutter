// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'acala.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic

mixin _$AcalaStore on _AcalaStore, Store {
  Computed<List<String>> _$swapTokensComputed;

  @override
  List<String> get swapTokens =>
      (_$swapTokensComputed ??= Computed<List<String>>(() => super.swapTokens))
          .value;
  Computed<double> _$swapFeeComputed;

  @override
  double get swapFee =>
      (_$swapFeeComputed ??= Computed<double>(() => super.swapFee)).value;
  Computed<double> _$dexLiquidityRewardsComputed;

  @override
  double get dexLiquidityRewards => (_$dexLiquidityRewardsComputed ??=
          Computed<double>(() => super.dexLiquidityRewards))
      .value;

  final _$loanTypesAtom = Atom(name: '_AcalaStore.loanTypes');

  @override
  List<LoanType> get loanTypes {
    _$loanTypesAtom.context.enforceReadPolicy(_$loanTypesAtom);
    _$loanTypesAtom.reportObserved();
    return super.loanTypes;
  }

  @override
  set loanTypes(List<LoanType> value) {
    _$loanTypesAtom.context.conditionallyRunInAction(() {
      super.loanTypes = value;
      _$loanTypesAtom.reportChanged();
    }, _$loanTypesAtom, name: '${_$loanTypesAtom.name}_set');
  }

  final _$loansAtom = Atom(name: '_AcalaStore.loans');

  @override
  Map<String, LoanData> get loans {
    _$loansAtom.context.enforceReadPolicy(_$loansAtom);
    _$loansAtom.reportObserved();
    return super.loans;
  }

  @override
  set loans(Map<String, LoanData> value) {
    _$loansAtom.context.conditionallyRunInAction(() {
      super.loans = value;
      _$loansAtom.reportChanged();
    }, _$loansAtom, name: '${_$loansAtom.name}_set');
  }

  final _$pricesAtom = Atom(name: '_AcalaStore.prices');

  @override
  Map<String, BigInt> get prices {
    _$pricesAtom.context.enforceReadPolicy(_$pricesAtom);
    _$pricesAtom.reportObserved();
    return super.prices;
  }

  @override
  set prices(Map<String, BigInt> value) {
    _$pricesAtom.context.conditionallyRunInAction(() {
      super.prices = value;
      _$pricesAtom.reportChanged();
    }, _$pricesAtom, name: '${_$pricesAtom.name}_set');
  }

  final _$txsLoanAtom = Atom(name: '_AcalaStore.txsLoan');

  @override
  ObservableList<TxLoanData> get txsLoan {
    _$txsLoanAtom.context.enforceReadPolicy(_$txsLoanAtom);
    _$txsLoanAtom.reportObserved();
    return super.txsLoan;
  }

  @override
  set txsLoan(ObservableList<TxLoanData> value) {
    _$txsLoanAtom.context.conditionallyRunInAction(() {
      super.txsLoan = value;
      _$txsLoanAtom.reportChanged();
    }, _$txsLoanAtom, name: '${_$txsLoanAtom.name}_set');
  }

  final _$txsSwapAtom = Atom(name: '_AcalaStore.txsSwap');

  @override
  ObservableList<TxSwapData> get txsSwap {
    _$txsSwapAtom.context.enforceReadPolicy(_$txsSwapAtom);
    _$txsSwapAtom.reportObserved();
    return super.txsSwap;
  }

  @override
  set txsSwap(ObservableList<TxSwapData> value) {
    _$txsSwapAtom.context.conditionallyRunInAction(() {
      super.txsSwap = value;
      _$txsSwapAtom.reportChanged();
    }, _$txsSwapAtom, name: '${_$txsSwapAtom.name}_set');
  }

  final _$txsDexLiquidityAtom = Atom(name: '_AcalaStore.txsDexLiquidity');

  @override
  ObservableList<TxDexLiquidityData> get txsDexLiquidity {
    _$txsDexLiquidityAtom.context.enforceReadPolicy(_$txsDexLiquidityAtom);
    _$txsDexLiquidityAtom.reportObserved();
    return super.txsDexLiquidity;
  }

  @override
  set txsDexLiquidity(ObservableList<TxDexLiquidityData> value) {
    _$txsDexLiquidityAtom.context.conditionallyRunInAction(() {
      super.txsDexLiquidity = value;
      _$txsDexLiquidityAtom.reportChanged();
    }, _$txsDexLiquidityAtom, name: '${_$txsDexLiquidityAtom.name}_set');
  }

  final _$txsLoadingAtom = Atom(name: '_AcalaStore.txsLoading');

  @override
  bool get txsLoading {
    _$txsLoadingAtom.context.enforceReadPolicy(_$txsLoadingAtom);
    _$txsLoadingAtom.reportObserved();
    return super.txsLoading;
  }

  @override
  set txsLoading(bool value) {
    _$txsLoadingAtom.context.conditionallyRunInAction(() {
      super.txsLoading = value;
      _$txsLoadingAtom.reportChanged();
    }, _$txsLoadingAtom, name: '${_$txsLoadingAtom.name}_set');
  }

  final _$currentSwapPairAtom = Atom(name: '_AcalaStore.currentSwapPair');

  @override
  List<String> get currentSwapPair {
    _$currentSwapPairAtom.context.enforceReadPolicy(_$currentSwapPairAtom);
    _$currentSwapPairAtom.reportObserved();
    return super.currentSwapPair;
  }

  @override
  set currentSwapPair(List<String> value) {
    _$currentSwapPairAtom.context.conditionallyRunInAction(() {
      super.currentSwapPair = value;
      _$currentSwapPairAtom.reportChanged();
    }, _$currentSwapPairAtom, name: '${_$currentSwapPairAtom.name}_set');
  }

  final _$swapRatioAtom = Atom(name: '_AcalaStore.swapRatio');

  @override
  String get swapRatio {
    _$swapRatioAtom.context.enforceReadPolicy(_$swapRatioAtom);
    _$swapRatioAtom.reportObserved();
    return super.swapRatio;
  }

  @override
  set swapRatio(String value) {
    _$swapRatioAtom.context.conditionallyRunInAction(() {
      super.swapRatio = value;
      _$swapRatioAtom.reportChanged();
    }, _$swapRatioAtom, name: '${_$swapRatioAtom.name}_set');
  }

  final _$swapPoolAtom = Atom(name: '_AcalaStore.swapPool');

  @override
  Map<String, dynamic> get swapPool {
    _$swapPoolAtom.context.enforceReadPolicy(_$swapPoolAtom);
    _$swapPoolAtom.reportObserved();
    return super.swapPool;
  }

  @override
  set swapPool(Map<String, dynamic> value) {
    _$swapPoolAtom.context.conditionallyRunInAction(() {
      super.swapPool = value;
      _$swapPoolAtom.reportChanged();
    }, _$swapPoolAtom, name: '${_$swapPoolAtom.name}_set');
  }

  final _$swapPoolSharesTotalAtom =
      Atom(name: '_AcalaStore.swapPoolSharesTotal');

  @override
  Map<String, BigInt> get swapPoolSharesTotal {
    _$swapPoolSharesTotalAtom.context
        .enforceReadPolicy(_$swapPoolSharesTotalAtom);
    _$swapPoolSharesTotalAtom.reportObserved();
    return super.swapPoolSharesTotal;
  }

  @override
  set swapPoolSharesTotal(Map<String, BigInt> value) {
    _$swapPoolSharesTotalAtom.context.conditionallyRunInAction(() {
      super.swapPoolSharesTotal = value;
      _$swapPoolSharesTotalAtom.reportChanged();
    }, _$swapPoolSharesTotalAtom,
        name: '${_$swapPoolSharesTotalAtom.name}_set');
  }

  final _$swapPoolRatiosAtom = Atom(name: '_AcalaStore.swapPoolRatios');

  @override
  Map<String, dynamic> get swapPoolRatios {
    _$swapPoolRatiosAtom.context.enforceReadPolicy(_$swapPoolRatiosAtom);
    _$swapPoolRatiosAtom.reportObserved();
    return super.swapPoolRatios;
  }

  @override
  set swapPoolRatios(Map<String, dynamic> value) {
    _$swapPoolRatiosAtom.context.conditionallyRunInAction(() {
      super.swapPoolRatios = value;
      _$swapPoolRatiosAtom.reportChanged();
    }, _$swapPoolRatiosAtom, name: '${_$swapPoolRatiosAtom.name}_set');
  }

  final _$swapPoolRewardsAtom = Atom(name: '_AcalaStore.swapPoolRewards');

  @override
  Map<String, double> get swapPoolRewards {
    _$swapPoolRewardsAtom.context.enforceReadPolicy(_$swapPoolRewardsAtom);
    _$swapPoolRewardsAtom.reportObserved();
    return super.swapPoolRewards;
  }

  @override
  set swapPoolRewards(Map<String, double> value) {
    _$swapPoolRewardsAtom.context.conditionallyRunInAction(() {
      super.swapPoolRewards = value;
      _$swapPoolRewardsAtom.reportChanged();
    }, _$swapPoolRewardsAtom, name: '${_$swapPoolRewardsAtom.name}_set');
  }

  final _$swapPoolSharesAtom = Atom(name: '_AcalaStore.swapPoolShares');

  @override
  ObservableMap<String, BigInt> get swapPoolShares {
    _$swapPoolSharesAtom.context.enforceReadPolicy(_$swapPoolSharesAtom);
    _$swapPoolSharesAtom.reportObserved();
    return super.swapPoolShares;
  }

  @override
  set swapPoolShares(ObservableMap<String, BigInt> value) {
    _$swapPoolSharesAtom.context.conditionallyRunInAction(() {
      super.swapPoolShares = value;
      _$swapPoolSharesAtom.reportChanged();
    }, _$swapPoolSharesAtom, name: '${_$swapPoolSharesAtom.name}_set');
  }

  final _$swapPoolShareRewardsAtom =
      Atom(name: '_AcalaStore.swapPoolShareRewards');

  @override
  ObservableMap<String, BigInt> get swapPoolShareRewards {
    _$swapPoolShareRewardsAtom.context
        .enforceReadPolicy(_$swapPoolShareRewardsAtom);
    _$swapPoolShareRewardsAtom.reportObserved();
    return super.swapPoolShareRewards;
  }

  @override
  set swapPoolShareRewards(ObservableMap<String, BigInt> value) {
    _$swapPoolShareRewardsAtom.context.conditionallyRunInAction(() {
      super.swapPoolShareRewards = value;
      _$swapPoolShareRewardsAtom.reportChanged();
    }, _$swapPoolShareRewardsAtom,
        name: '${_$swapPoolShareRewardsAtom.name}_set');
  }

  final _$setLoanTxsAsyncAction = AsyncAction('setLoanTxs');

  @override
  Future<void> setLoanTxs(List list,
      {bool reset = false, dynamic needCache = true}) {
    return _$setLoanTxsAsyncAction
        .run(() => super.setLoanTxs(list, reset: reset, needCache: needCache));
  }

  final _$setSwapTxsAsyncAction = AsyncAction('setSwapTxs');

  @override
  Future<void> setSwapTxs(List list,
      {bool reset = false, dynamic needCache = true}) {
    return _$setSwapTxsAsyncAction
        .run(() => super.setSwapTxs(list, reset: reset, needCache: needCache));
  }

  final _$setDexLiquidityTxsAsyncAction = AsyncAction('setDexLiquidityTxs');

  @override
  Future<void> setDexLiquidityTxs(List list,
      {bool reset = false, dynamic needCache = true}) {
    return _$setDexLiquidityTxsAsyncAction.run(() =>
        super.setDexLiquidityTxs(list, reset: reset, needCache: needCache));
  }

  final _$_cacheTxsAsyncAction = AsyncAction('_cacheTxs');

  @override
  Future<void> _cacheTxs(List list, String cacheKey) {
    return _$_cacheTxsAsyncAction.run(() => super._cacheTxs(list, cacheKey));
  }

  final _$loadCacheAsyncAction = AsyncAction('loadCache');

  @override
  Future<void> loadCache() {
    return _$loadCacheAsyncAction.run(() => super.loadCache());
  }

  final _$setSwapPoolAsyncAction = AsyncAction('setSwapPool');

  @override
  Future<void> setSwapPool(Map<String, dynamic> map) {
    return _$setSwapPoolAsyncAction.run(() => super.setSwapPool(map));
  }

  final _$setSwapPoolSharesTotalAsyncAction =
      AsyncAction('setSwapPoolSharesTotal');

  @override
  Future<void> setSwapPoolSharesTotal(Map<String, BigInt> map) {
    return _$setSwapPoolSharesTotalAsyncAction
        .run(() => super.setSwapPoolSharesTotal(map));
  }

  final _$setSwapPoolRatiosAsyncAction = AsyncAction('setSwapPoolRatios');

  @override
  Future<void> setSwapPoolRatios(Map<String, dynamic> map) {
    return _$setSwapPoolRatiosAsyncAction
        .run(() => super.setSwapPoolRatios(map));
  }

  final _$setSwapPoolRewardsAsyncAction = AsyncAction('setSwapPoolRewards');

  @override
  Future<void> setSwapPoolRewards(Map<String, dynamic> map) {
    return _$setSwapPoolRewardsAsyncAction
        .run(() => super.setSwapPoolRewards(map));
  }

  final _$setSwapPoolShareAsyncAction = AsyncAction('setSwapPoolShare');

  @override
  Future<void> setSwapPoolShare(String currencyId, BigInt share) {
    return _$setSwapPoolShareAsyncAction
        .run(() => super.setSwapPoolShare(currencyId, share));
  }

  final _$setSwapPoolShareRewardsAsyncAction =
      AsyncAction('setSwapPoolShareRewards');

  @override
  Future<void> setSwapPoolShareRewards(String currencyId, BigInt rewards) {
    return _$setSwapPoolShareRewardsAsyncAction
        .run(() => super.setSwapPoolShareRewards(currencyId, rewards));
  }

  final _$_AcalaStoreActionController = ActionController(name: '_AcalaStore');

  @override
  void setAccountLoans(List list) {
    final _$actionInfo = _$_AcalaStoreActionController.startAction();
    try {
      return super.setAccountLoans(list);
    } finally {
      _$_AcalaStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setLoanTypes(List list) {
    final _$actionInfo = _$_AcalaStoreActionController.startAction();
    try {
      return super.setLoanTypes(list);
    } finally {
      _$_AcalaStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setPrices(List list) {
    final _$actionInfo = _$_AcalaStoreActionController.startAction();
    try {
      return super.setPrices(list);
    } finally {
      _$_AcalaStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setSwapPair(List pair) {
    final _$actionInfo = _$_AcalaStoreActionController.startAction();
    try {
      return super.setSwapPair(pair);
    } finally {
      _$_AcalaStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setSwapRatio(String ratio) {
    final _$actionInfo = _$_AcalaStoreActionController.startAction();
    try {
      return super.setSwapRatio(ratio);
    } finally {
      _$_AcalaStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setTxsLoading(bool loading) {
    final _$actionInfo = _$_AcalaStoreActionController.startAction();
    try {
      return super.setTxsLoading(loading);
    } finally {
      _$_AcalaStoreActionController.endAction(_$actionInfo);
    }
  }
}

mixin _$LoanData on _LoanData, Store {}

mixin _$LoanType on _LoanType, Store {}

mixin _$TxLoanData on _TxLoanData, Store {}
