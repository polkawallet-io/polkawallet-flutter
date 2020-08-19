// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'acala.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic

mixin _$AcalaStore on _AcalaStore, Store {
  Computed<List<String>> _$swapTokensComputed;

  @override
  List<String> get swapTokens =>
      (_$swapTokensComputed ??= Computed<List<String>>(() => super.swapTokens,
              name: '_AcalaStore.swapTokens'))
          .value;
  Computed<double> _$swapFeeComputed;

  @override
  double get swapFee => (_$swapFeeComputed ??=
          Computed<double>(() => super.swapFee, name: '_AcalaStore.swapFee'))
      .value;
  Computed<double> _$dexLiquidityRewardsComputed;

  @override
  double get dexLiquidityRewards => (_$dexLiquidityRewardsComputed ??=
          Computed<double>(() => super.dexLiquidityRewards,
              name: '_AcalaStore.dexLiquidityRewards'))
      .value;

  final _$airdropsAtom = Atom(name: '_AcalaStore.airdrops');

  @override
  Map<String, BigInt> get airdrops {
    _$airdropsAtom.reportRead();
    return super.airdrops;
  }

  @override
  set airdrops(Map<String, BigInt> value) {
    _$airdropsAtom.reportWrite(value, super.airdrops, () {
      super.airdrops = value;
    });
  }

  final _$loanTypesAtom = Atom(name: '_AcalaStore.loanTypes');

  @override
  List<LoanType> get loanTypes {
    _$loanTypesAtom.reportRead();
    return super.loanTypes;
  }

  @override
  set loanTypes(List<LoanType> value) {
    _$loanTypesAtom.reportWrite(value, super.loanTypes, () {
      super.loanTypes = value;
    });
  }

  final _$loansAtom = Atom(name: '_AcalaStore.loans');

  @override
  Map<String, LoanData> get loans {
    _$loansAtom.reportRead();
    return super.loans;
  }

  @override
  set loans(Map<String, LoanData> value) {
    _$loansAtom.reportWrite(value, super.loans, () {
      super.loans = value;
    });
  }

  final _$pricesAtom = Atom(name: '_AcalaStore.prices');

  @override
  Map<String, BigInt> get prices {
    _$pricesAtom.reportRead();
    return super.prices;
  }

  @override
  set prices(Map<String, BigInt> value) {
    _$pricesAtom.reportWrite(value, super.prices, () {
      super.prices = value;
    });
  }

  final _$txsTransferAtom = Atom(name: '_AcalaStore.txsTransfer');

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

  final _$txsLoanAtom = Atom(name: '_AcalaStore.txsLoan');

  @override
  ObservableList<TxLoanData> get txsLoan {
    _$txsLoanAtom.reportRead();
    return super.txsLoan;
  }

  @override
  set txsLoan(ObservableList<TxLoanData> value) {
    _$txsLoanAtom.reportWrite(value, super.txsLoan, () {
      super.txsLoan = value;
    });
  }

  final _$txsSwapAtom = Atom(name: '_AcalaStore.txsSwap');

  @override
  ObservableList<TxSwapData> get txsSwap {
    _$txsSwapAtom.reportRead();
    return super.txsSwap;
  }

  @override
  set txsSwap(ObservableList<TxSwapData> value) {
    _$txsSwapAtom.reportWrite(value, super.txsSwap, () {
      super.txsSwap = value;
    });
  }

  final _$txsDexLiquidityAtom = Atom(name: '_AcalaStore.txsDexLiquidity');

  @override
  ObservableList<TxDexLiquidityData> get txsDexLiquidity {
    _$txsDexLiquidityAtom.reportRead();
    return super.txsDexLiquidity;
  }

  @override
  set txsDexLiquidity(ObservableList<TxDexLiquidityData> value) {
    _$txsDexLiquidityAtom.reportWrite(value, super.txsDexLiquidity, () {
      super.txsDexLiquidity = value;
    });
  }

  final _$txsHomaAtom = Atom(name: '_AcalaStore.txsHoma');

  @override
  ObservableList<TxHomaData> get txsHoma {
    _$txsHomaAtom.reportRead();
    return super.txsHoma;
  }

  @override
  set txsHoma(ObservableList<TxHomaData> value) {
    _$txsHomaAtom.reportWrite(value, super.txsHoma, () {
      super.txsHoma = value;
    });
  }

  final _$txsLoadingAtom = Atom(name: '_AcalaStore.txsLoading');

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

  final _$swapPoolRatiosAtom = Atom(name: '_AcalaStore.swapPoolRatios');

  @override
  ObservableMap<String, String> get swapPoolRatios {
    _$swapPoolRatiosAtom.reportRead();
    return super.swapPoolRatios;
  }

  @override
  set swapPoolRatios(ObservableMap<String, String> value) {
    _$swapPoolRatiosAtom.reportWrite(value, super.swapPoolRatios, () {
      super.swapPoolRatios = value;
    });
  }

  final _$swapPoolRewardsAtom = Atom(name: '_AcalaStore.swapPoolRewards');

  @override
  Map<String, double> get swapPoolRewards {
    _$swapPoolRewardsAtom.reportRead();
    return super.swapPoolRewards;
  }

  @override
  set swapPoolRewards(Map<String, double> value) {
    _$swapPoolRewardsAtom.reportWrite(value, super.swapPoolRewards, () {
      super.swapPoolRewards = value;
    });
  }

  final _$dexPoolInfoMapAtom = Atom(name: '_AcalaStore.dexPoolInfoMap');

  @override
  ObservableMap<String, DexPoolInfoData> get dexPoolInfoMap {
    _$dexPoolInfoMapAtom.reportRead();
    return super.dexPoolInfoMap;
  }

  @override
  set dexPoolInfoMap(ObservableMap<String, DexPoolInfoData> value) {
    _$dexPoolInfoMapAtom.reportWrite(value, super.dexPoolInfoMap, () {
      super.dexPoolInfoMap = value;
    });
  }

  final _$stakingPoolInfoAtom = Atom(name: '_AcalaStore.stakingPoolInfo');

  @override
  StakingPoolInfoData get stakingPoolInfo {
    _$stakingPoolInfoAtom.reportRead();
    return super.stakingPoolInfo;
  }

  @override
  set stakingPoolInfo(StakingPoolInfoData value) {
    _$stakingPoolInfoAtom.reportWrite(value, super.stakingPoolInfo, () {
      super.stakingPoolInfo = value;
    });
  }

  final _$homaUserInfoAtom = Atom(name: '_AcalaStore.homaUserInfo');

  @override
  HomaUserInfoData get homaUserInfo {
    _$homaUserInfoAtom.reportRead();
    return super.homaUserInfo;
  }

  @override
  set homaUserInfo(HomaUserInfoData value) {
    _$homaUserInfoAtom.reportWrite(value, super.homaUserInfo, () {
      super.homaUserInfo = value;
    });
  }

  final _$setTransferTxsAsyncAction = AsyncAction('_AcalaStore.setTransferTxs');

  @override
  Future<void> setTransferTxs(List<dynamic> list,
      {bool reset = false, dynamic needCache = true}) {
    return _$setTransferTxsAsyncAction.run(
        () => super.setTransferTxs(list, reset: reset, needCache: needCache));
  }

  final _$setLoanTxsAsyncAction = AsyncAction('_AcalaStore.setLoanTxs');

  @override
  Future<void> setLoanTxs(List<dynamic> list,
      {bool reset = false, dynamic needCache = true}) {
    return _$setLoanTxsAsyncAction
        .run(() => super.setLoanTxs(list, reset: reset, needCache: needCache));
  }

  final _$setSwapTxsAsyncAction = AsyncAction('_AcalaStore.setSwapTxs');

  @override
  Future<void> setSwapTxs(List<dynamic> list,
      {bool reset = false, dynamic needCache = true}) {
    return _$setSwapTxsAsyncAction
        .run(() => super.setSwapTxs(list, reset: reset, needCache: needCache));
  }

  final _$setDexLiquidityTxsAsyncAction =
      AsyncAction('_AcalaStore.setDexLiquidityTxs');

  @override
  Future<void> setDexLiquidityTxs(List<dynamic> list,
      {bool reset = false, dynamic needCache = true}) {
    return _$setDexLiquidityTxsAsyncAction.run(() =>
        super.setDexLiquidityTxs(list, reset: reset, needCache: needCache));
  }

  final _$setHomaTxsAsyncAction = AsyncAction('_AcalaStore.setHomaTxs');

  @override
  Future<void> setHomaTxs(List<dynamic> list,
      {bool reset = false, dynamic needCache = true}) {
    return _$setHomaTxsAsyncAction
        .run(() => super.setHomaTxs(list, reset: reset, needCache: needCache));
  }

  final _$loadCacheAsyncAction = AsyncAction('_AcalaStore.loadCache');

  @override
  Future<void> loadCache() {
    return _$loadCacheAsyncAction.run(() => super.loadCache());
  }

  final _$setSwapPoolRatioAsyncAction =
      AsyncAction('_AcalaStore.setSwapPoolRatio');

  @override
  Future<void> setSwapPoolRatio(String currencyId, String ratio) {
    return _$setSwapPoolRatioAsyncAction
        .run(() => super.setSwapPoolRatio(currencyId, ratio));
  }

  final _$setSwapPoolRewardsAsyncAction =
      AsyncAction('_AcalaStore.setSwapPoolRewards');

  @override
  Future<void> setSwapPoolRewards(Map<String, dynamic> map) {
    return _$setSwapPoolRewardsAsyncAction
        .run(() => super.setSwapPoolRewards(map));
  }

  final _$setDexPoolInfoAsyncAction = AsyncAction('_AcalaStore.setDexPoolInfo');

  @override
  Future<void> setDexPoolInfo(String currencyId, Map<dynamic, dynamic> info) {
    return _$setDexPoolInfoAsyncAction
        .run(() => super.setDexPoolInfo(currencyId, info));
  }

  final _$setHomaStakingPoolAsyncAction =
      AsyncAction('_AcalaStore.setHomaStakingPool');

  @override
  Future<void> setHomaStakingPool(Map<dynamic, dynamic> pool) {
    return _$setHomaStakingPoolAsyncAction
        .run(() => super.setHomaStakingPool(pool));
  }

  final _$setHomaUserInfoAsyncAction =
      AsyncAction('_AcalaStore.setHomaUserInfo');

  @override
  Future<void> setHomaUserInfo(Map<dynamic, dynamic> info) {
    return _$setHomaUserInfoAsyncAction.run(() => super.setHomaUserInfo(info));
  }

  final _$_AcalaStoreActionController = ActionController(name: '_AcalaStore');

  @override
  void setAirdrops(Map<dynamic, dynamic> amount, {bool needCache = true}) {
    final _$actionInfo = _$_AcalaStoreActionController.startAction(
        name: '_AcalaStore.setAirdrops');
    try {
      return super.setAirdrops(amount, needCache: needCache);
    } finally {
      _$_AcalaStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setAccountLoans(List<dynamic> list) {
    final _$actionInfo = _$_AcalaStoreActionController.startAction(
        name: '_AcalaStore.setAccountLoans');
    try {
      return super.setAccountLoans(list);
    } finally {
      _$_AcalaStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setLoanTypes(List<dynamic> list) {
    final _$actionInfo = _$_AcalaStoreActionController.startAction(
        name: '_AcalaStore.setLoanTypes');
    try {
      return super.setLoanTypes(list);
    } finally {
      _$_AcalaStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setPrices(List<dynamic> list) {
    final _$actionInfo = _$_AcalaStoreActionController.startAction(
        name: '_AcalaStore.setPrices');
    try {
      return super.setPrices(list);
    } finally {
      _$_AcalaStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setTxsLoading(bool loading) {
    final _$actionInfo = _$_AcalaStoreActionController.startAction(
        name: '_AcalaStore.setTxsLoading');
    try {
      return super.setTxsLoading(loading);
    } finally {
      _$_AcalaStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
airdrops: ${airdrops},
loanTypes: ${loanTypes},
loans: ${loans},
prices: ${prices},
txsTransfer: ${txsTransfer},
txsLoan: ${txsLoan},
txsSwap: ${txsSwap},
txsDexLiquidity: ${txsDexLiquidity},
txsHoma: ${txsHoma},
txsLoading: ${txsLoading},
swapPoolRatios: ${swapPoolRatios},
swapPoolRewards: ${swapPoolRewards},
dexPoolInfoMap: ${dexPoolInfoMap},
stakingPoolInfo: ${stakingPoolInfo},
homaUserInfo: ${homaUserInfo},
swapTokens: ${swapTokens},
swapFee: ${swapFee},
dexLiquidityRewards: ${dexLiquidityRewards}
    ''';
  }
}
