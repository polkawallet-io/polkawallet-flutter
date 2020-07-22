// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'laminar.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic

mixin _$LaminarStore on _LaminarStore, Store {
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

  final _$tokensAtom = Atom(name: '_LaminarStore.tokens');

  @override
  List<LaminarTokenData> get tokens {
    _$tokensAtom.reportRead();
    return super.tokens;
  }

  @override
  set tokens(List<LaminarTokenData> value) {
    _$tokensAtom.reportWrite(value, super.tokens, () {
      super.tokens = value;
    });
  }

  final _$accountBalanceAtom = Atom(name: '_LaminarStore.accountBalance');

  @override
  List<LaminarBalanceData> get accountBalance {
    _$accountBalanceAtom.reportRead();
    return super.accountBalance;
  }

  @override
  set accountBalance(List<LaminarBalanceData> value) {
    _$accountBalanceAtom.reportWrite(value, super.accountBalance, () {
      super.accountBalance = value;
    });
  }

  final _$setTransferTxsAsyncAction =
      AsyncAction('_LaminarStore.setTransferTxs');

  @override
  Future<void> setTransferTxs(List<dynamic> list,
      {bool reset = false, dynamic needCache = true}) {
    return _$setTransferTxsAsyncAction.run(
        () => super.setTransferTxs(list, reset: reset, needCache: needCache));
  }

  final _$setTokenListAsyncAction = AsyncAction('_LaminarStore.setTokenList');

  @override
  Future<void> setTokenList(List<dynamic> data, {bool shouldCache = true}) {
    return _$setTokenListAsyncAction
        .run(() => super.setTokenList(data, shouldCache: shouldCache));
  }

  final _$setAccountBalanceAsyncAction =
      AsyncAction('_LaminarStore.setAccountBalance');

  @override
  Future<void> setAccountBalance(List<dynamic> data,
      {bool shouldCache = true}) {
    return _$setAccountBalanceAsyncAction
        .run(() => super.setAccountBalance(data, shouldCache: shouldCache));
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

  @override
  String toString() {
    return '''
txsTransfer: ${txsTransfer},
tokens: ${tokens},
accountBalance: ${accountBalance}
    ''';
  }
}
