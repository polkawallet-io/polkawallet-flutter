// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'laminar.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic

mixin _$LaminarStore on _LaminarStore, Store {
  Computed<List<LaminarSyntheticPoolTokenData>> _$syntheticTokensComputed;

  @override
  List<LaminarSyntheticPoolTokenData> get syntheticTokens =>
      (_$syntheticTokensComputed ??=
              Computed<List<LaminarSyntheticPoolTokenData>>(
                  () => super.syntheticTokens,
                  name: '_LaminarStore.syntheticTokens'))
          .value;
  Computed<List<LaminarMarginPairData>> _$marginTokensComputed;

  @override
  List<LaminarMarginPairData> get marginTokens => (_$marginTokensComputed ??=
          Computed<List<LaminarMarginPairData>>(() => super.marginTokens,
              name: '_LaminarStore.marginTokens'))
      .value;

  final _$txsTransferAtom = Atom(name: '_LaminarStore.txsTransfer');

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

  final _$txsSwapAtom = Atom(name: '_LaminarStore.txsSwap');

  @override
  ObservableList<LaminarTxSwapData> get txsSwap {
    _$txsSwapAtom.reportRead();
    return super.txsSwap;
  }

  @override
  set txsSwap(ObservableList<LaminarTxSwapData> value) {
    _$txsSwapAtom.reportWrite(value, super.txsSwap, () {
      super.txsSwap = value;
    });
  }

  final _$tokenPricesAtom = Atom(name: '_LaminarStore.tokenPrices');

  @override
  Map<String, LaminarPriceData> get tokenPrices {
    _$tokenPricesAtom.reportRead();
    return super.tokenPrices;
  }

  @override
  set tokenPrices(Map<String, LaminarPriceData> value) {
    _$tokenPricesAtom.reportWrite(value, super.tokenPrices, () {
      super.tokenPrices = value;
    });
  }

  final _$syntheticPoolInfoAtom = Atom(name: '_LaminarStore.syntheticPoolInfo');

  @override
  ObservableMap<String, LaminarSyntheticPoolInfoData> get syntheticPoolInfo {
    _$syntheticPoolInfoAtom.reportRead();
    return super.syntheticPoolInfo;
  }

  @override
  set syntheticPoolInfo(
      ObservableMap<String, LaminarSyntheticPoolInfoData> value) {
    _$syntheticPoolInfoAtom.reportWrite(value, super.syntheticPoolInfo, () {
      super.syntheticPoolInfo = value;
    });
  }

  final _$marginPoolInfoAtom = Atom(name: '_LaminarStore.marginPoolInfo');

  @override
  ObservableMap<String, LaminarMarginPoolInfoData> get marginPoolInfo {
    _$marginPoolInfoAtom.reportRead();
    return super.marginPoolInfo;
  }

  @override
  set marginPoolInfo(ObservableMap<String, LaminarMarginPoolInfoData> value) {
    _$marginPoolInfoAtom.reportWrite(value, super.marginPoolInfo, () {
      super.marginPoolInfo = value;
    });
  }

  final _$marginTraderInfoAtom = Atom(name: '_LaminarStore.marginTraderInfo');

  @override
  ObservableMap<String, LaminarMarginTraderInfoData> get marginTraderInfo {
    _$marginTraderInfoAtom.reportRead();
    return super.marginTraderInfo;
  }

  @override
  set marginTraderInfo(
      ObservableMap<String, LaminarMarginTraderInfoData> value) {
    _$marginTraderInfoAtom.reportWrite(value, super.marginTraderInfo, () {
      super.marginTraderInfo = value;
    });
  }

  final _$setSwapTxsAsyncAction = AsyncAction('_LaminarStore.setSwapTxs');

  @override
  Future<void> setSwapTxs(List<dynamic> list,
      {bool reset = false, dynamic needCache = true}) {
    return _$setSwapTxsAsyncAction
        .run(() => super.setSwapTxs(list, reset: reset, needCache: needCache));
  }

  final _$loadAccountCacheAsyncAction =
      AsyncAction('_LaminarStore.loadAccountCache');

  @override
  Future<void> loadAccountCache() {
    return _$loadAccountCacheAsyncAction.run(() => super.loadAccountCache());
  }

  final _$loadCacheAsyncAction = AsyncAction('_LaminarStore.loadCache');

  @override
  Future<void> loadCache() {
    return _$loadCacheAsyncAction.run(() => super.loadCache());
  }

  final _$_LaminarStoreActionController =
      ActionController(name: '_LaminarStore');

  @override
  void setTransferTxs(List<dynamic> list,
      {bool reset = false, dynamic needCache = true}) {
    final _$actionInfo = _$_LaminarStoreActionController.startAction(
        name: '_LaminarStore.setTransferTxs');
    try {
      return super.setTransferTxs(list, reset: reset, needCache: needCache);
    } finally {
      _$_LaminarStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setTokenPrices(List<dynamic> prices) {
    final _$actionInfo = _$_LaminarStoreActionController.startAction(
        name: '_LaminarStore.setTokenPrices');
    try {
      return super.setTokenPrices(prices);
    } finally {
      _$_LaminarStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setSyntheticPoolInfo(Map<dynamic, dynamic> info) {
    final _$actionInfo = _$_LaminarStoreActionController.startAction(
        name: '_LaminarStore.setSyntheticPoolInfo');
    try {
      return super.setSyntheticPoolInfo(info);
    } finally {
      _$_LaminarStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setMarginPoolInfo(Map<dynamic, dynamic> info) {
    final _$actionInfo = _$_LaminarStoreActionController.startAction(
        name: '_LaminarStore.setMarginPoolInfo');
    try {
      return super.setMarginPoolInfo(info);
    } finally {
      _$_LaminarStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setMarginTraderInfo(Map<dynamic, dynamic> info) {
    final _$actionInfo = _$_LaminarStoreActionController.startAction(
        name: '_LaminarStore.setMarginTraderInfo');
    try {
      return super.setMarginTraderInfo(info);
    } finally {
      _$_LaminarStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
txsTransfer: ${txsTransfer},
txsSwap: ${txsSwap},
tokenPrices: ${tokenPrices},
syntheticPoolInfo: ${syntheticPoolInfo},
marginPoolInfo: ${marginPoolInfo},
marginTraderInfo: ${marginTraderInfo},
syntheticTokens: ${syntheticTokens},
marginTokens: ${marginTokens}
    ''';
  }
}
