// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'assets.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic

mixin _$AssetsStore on _AssetsStore, Store {
  Computed<ObservableList<TransferData>> _$txsViewComputed;

  @override
  ObservableList<TransferData> get txsView => (_$txsViewComputed ??=
          Computed<ObservableList<TransferData>>(() => super.txsView))
      .value;
  Computed<ObservableList<Map<String, dynamic>>> _$balanceHistoryComputed;

  @override
  ObservableList<Map<String, dynamic>> get balanceHistory =>
      (_$balanceHistoryComputed ??=
              Computed<ObservableList<Map<String, dynamic>>>(
                  () => super.balanceHistory))
          .value;

  final _$cacheTxsTimestampAtom = Atom(name: '_AssetsStore.cacheTxsTimestamp');

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

  final _$isTxsLoadingAtom = Atom(name: '_AssetsStore.isTxsLoading');

  @override
  bool get isTxsLoading {
    _$isTxsLoadingAtom.context.enforceReadPolicy(_$isTxsLoadingAtom);
    _$isTxsLoadingAtom.reportObserved();
    return super.isTxsLoading;
  }

  @override
  set isTxsLoading(bool value) {
    _$isTxsLoadingAtom.context.conditionallyRunInAction(() {
      super.isTxsLoading = value;
      _$isTxsLoadingAtom.reportChanged();
    }, _$isTxsLoadingAtom, name: '${_$isTxsLoadingAtom.name}_set');
  }

  final _$submittingAtom = Atom(name: '_AssetsStore.submitting');

  @override
  bool get submitting {
    _$submittingAtom.context.enforceReadPolicy(_$submittingAtom);
    _$submittingAtom.reportObserved();
    return super.submitting;
  }

  @override
  set submitting(bool value) {
    _$submittingAtom.context.conditionallyRunInAction(() {
      super.submitting = value;
      _$submittingAtom.reportChanged();
    }, _$submittingAtom, name: '${_$submittingAtom.name}_set');
  }

  final _$balanceAtom = Atom(name: '_AssetsStore.balance');

  @override
  String get balance {
    _$balanceAtom.context.enforceReadPolicy(_$balanceAtom);
    _$balanceAtom.reportObserved();
    return super.balance;
  }

  @override
  set balance(String value) {
    _$balanceAtom.context.conditionallyRunInAction(() {
      super.balance = value;
      _$balanceAtom.reportChanged();
    }, _$balanceAtom, name: '${_$balanceAtom.name}_set');
  }

  final _$txsAtom = Atom(name: '_AssetsStore.txs');

  @override
  ObservableList<TransferData> get txs {
    _$txsAtom.context.enforceReadPolicy(_$txsAtom);
    _$txsAtom.reportObserved();
    return super.txs;
  }

  @override
  set txs(ObservableList<TransferData> value) {
    _$txsAtom.context.conditionallyRunInAction(() {
      super.txs = value;
      _$txsAtom.reportChanged();
    }, _$txsAtom, name: '${_$txsAtom.name}_set');
  }

  final _$txsFilterAtom = Atom(name: '_AssetsStore.txsFilter');

  @override
  int get txsFilter {
    _$txsFilterAtom.context.enforceReadPolicy(_$txsFilterAtom);
    _$txsFilterAtom.reportObserved();
    return super.txsFilter;
  }

  @override
  set txsFilter(int value) {
    _$txsFilterAtom.context.conditionallyRunInAction(() {
      super.txsFilter = value;
      _$txsFilterAtom.reportChanged();
    }, _$txsFilterAtom, name: '${_$txsFilterAtom.name}_set');
  }

  final _$txDetailAtom = Atom(name: '_AssetsStore.txDetail');

  @override
  TransferData get txDetail {
    _$txDetailAtom.context.enforceReadPolicy(_$txDetailAtom);
    _$txDetailAtom.reportObserved();
    return super.txDetail;
  }

  @override
  set txDetail(TransferData value) {
    _$txDetailAtom.context.conditionallyRunInAction(() {
      super.txDetail = value;
      _$txDetailAtom.reportChanged();
    }, _$txDetailAtom, name: '${_$txDetailAtom.name}_set');
  }

  final _$blockMapAtom = Atom(name: '_AssetsStore.blockMap');

  @override
  ObservableMap<int, BlockData> get blockMap {
    _$blockMapAtom.context.enforceReadPolicy(_$blockMapAtom);
    _$blockMapAtom.reportObserved();
    return super.blockMap;
  }

  @override
  set blockMap(ObservableMap<int, BlockData> value) {
    _$blockMapAtom.context.conditionallyRunInAction(() {
      super.blockMap = value;
      _$blockMapAtom.reportChanged();
    }, _$blockMapAtom, name: '${_$blockMapAtom.name}_set');
  }

  final _$clearTxsAsyncAction = AsyncAction('clearTxs');

  @override
  Future<void> clearTxs() {
    return _$clearTxsAsyncAction.run(() => super.clearTxs());
  }

  final _$addTxsAsyncAction = AsyncAction('addTxs');

  @override
  Future<void> addTxs(List ls) {
    return _$addTxsAsyncAction.run(() => super.addTxs(ls));
  }

  final _$setBlockMapAsyncAction = AsyncAction('setBlockMap');

  @override
  Future<void> setBlockMap(String data) {
    return _$setBlockMapAsyncAction.run(() => super.setBlockMap(data));
  }

  final _$loadCacheAsyncAction = AsyncAction('loadCache');

  @override
  Future<void> loadCache() {
    return _$loadCacheAsyncAction.run(() => super.loadCache());
  }

  final _$_AssetsStoreActionController = ActionController(name: '_AssetsStore');

  @override
  void setTxsLoading(bool isLoading) {
    final _$actionInfo = _$_AssetsStoreActionController.startAction();
    try {
      return super.setTxsLoading(isLoading);
    } finally {
      _$_AssetsStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setAccountBalance(String amt) {
    final _$actionInfo = _$_AssetsStoreActionController.startAction();
    try {
      return super.setAccountBalance(amt);
    } finally {
      _$_AssetsStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setTxsFilter(int filter) {
    final _$actionInfo = _$_AssetsStoreActionController.startAction();
    try {
      return super.setTxsFilter(filter);
    } finally {
      _$_AssetsStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setTxDetail(TransferData tx) {
    final _$actionInfo = _$_AssetsStoreActionController.startAction();
    try {
      return super.setTxDetail(tx);
    } finally {
      _$_AssetsStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setSubmitting(bool isSubmitting) {
    final _$actionInfo = _$_AssetsStoreActionController.startAction();
    try {
      return super.setSubmitting(isSubmitting);
    } finally {
      _$_AssetsStoreActionController.endAction(_$actionInfo);
    }
  }
}

mixin _$TransferData on _TransferData, Store {
  final _$typeAtom = Atom(name: '_TransferData.type');

  @override
  String get type {
    _$typeAtom.context.enforceReadPolicy(_$typeAtom);
    _$typeAtom.reportObserved();
    return super.type;
  }

  @override
  set type(String value) {
    _$typeAtom.context.conditionallyRunInAction(() {
      super.type = value;
      _$typeAtom.reportChanged();
    }, _$typeAtom, name: '${_$typeAtom.name}_set');
  }

  final _$idAtom = Atom(name: '_TransferData.id');

  @override
  String get id {
    _$idAtom.context.enforceReadPolicy(_$idAtom);
    _$idAtom.reportObserved();
    return super.id;
  }

  @override
  set id(String value) {
    _$idAtom.context.conditionallyRunInAction(() {
      super.id = value;
      _$idAtom.reportChanged();
    }, _$idAtom, name: '${_$idAtom.name}_set');
  }

  final _$blockAtom = Atom(name: '_TransferData.block');

  @override
  int get block {
    _$blockAtom.context.enforceReadPolicy(_$blockAtom);
    _$blockAtom.reportObserved();
    return super.block;
  }

  @override
  set block(int value) {
    _$blockAtom.context.conditionallyRunInAction(() {
      super.block = value;
      _$blockAtom.reportChanged();
    }, _$blockAtom, name: '${_$blockAtom.name}_set');
  }

  final _$senderAtom = Atom(name: '_TransferData.sender');

  @override
  String get sender {
    _$senderAtom.context.enforceReadPolicy(_$senderAtom);
    _$senderAtom.reportObserved();
    return super.sender;
  }

  @override
  set sender(String value) {
    _$senderAtom.context.conditionallyRunInAction(() {
      super.sender = value;
      _$senderAtom.reportChanged();
    }, _$senderAtom, name: '${_$senderAtom.name}_set');
  }

  final _$senderIdAtom = Atom(name: '_TransferData.senderId');

  @override
  String get senderId {
    _$senderIdAtom.context.enforceReadPolicy(_$senderIdAtom);
    _$senderIdAtom.reportObserved();
    return super.senderId;
  }

  @override
  set senderId(String value) {
    _$senderIdAtom.context.conditionallyRunInAction(() {
      super.senderId = value;
      _$senderIdAtom.reportChanged();
    }, _$senderIdAtom, name: '${_$senderIdAtom.name}_set');
  }

  final _$destinationAtom = Atom(name: '_TransferData.destination');

  @override
  String get destination {
    _$destinationAtom.context.enforceReadPolicy(_$destinationAtom);
    _$destinationAtom.reportObserved();
    return super.destination;
  }

  @override
  set destination(String value) {
    _$destinationAtom.context.conditionallyRunInAction(() {
      super.destination = value;
      _$destinationAtom.reportChanged();
    }, _$destinationAtom, name: '${_$destinationAtom.name}_set');
  }

  final _$destinationIdAtom = Atom(name: '_TransferData.destinationId');

  @override
  String get destinationId {
    _$destinationIdAtom.context.enforceReadPolicy(_$destinationIdAtom);
    _$destinationIdAtom.reportObserved();
    return super.destinationId;
  }

  @override
  set destinationId(String value) {
    _$destinationIdAtom.context.conditionallyRunInAction(() {
      super.destinationId = value;
      _$destinationIdAtom.reportChanged();
    }, _$destinationIdAtom, name: '${_$destinationIdAtom.name}_set');
  }

  final _$valueAtom = Atom(name: '_TransferData.value');

  @override
  int get value {
    _$valueAtom.context.enforceReadPolicy(_$valueAtom);
    _$valueAtom.reportObserved();
    return super.value;
  }

  @override
  set value(int value) {
    _$valueAtom.context.conditionallyRunInAction(() {
      super.value = value;
      _$valueAtom.reportChanged();
    }, _$valueAtom, name: '${_$valueAtom.name}_set');
  }

  final _$feeAtom = Atom(name: '_TransferData.fee');

  @override
  int get fee {
    _$feeAtom.context.enforceReadPolicy(_$feeAtom);
    _$feeAtom.reportObserved();
    return super.fee;
  }

  @override
  set fee(int value) {
    _$feeAtom.context.conditionallyRunInAction(() {
      super.fee = value;
      _$feeAtom.reportChanged();
    }, _$feeAtom, name: '${_$feeAtom.name}_set');
  }
}

mixin _$BlockData on _BlockData, Store {
  final _$idAtom = Atom(name: '_BlockData.id');

  @override
  int get id {
    _$idAtom.context.enforceReadPolicy(_$idAtom);
    _$idAtom.reportObserved();
    return super.id;
  }

  @override
  set id(int value) {
    _$idAtom.context.conditionallyRunInAction(() {
      super.id = value;
      _$idAtom.reportChanged();
    }, _$idAtom, name: '${_$idAtom.name}_set');
  }

  final _$hashAtom = Atom(name: '_BlockData.hash');

  @override
  String get hash {
    _$hashAtom.context.enforceReadPolicy(_$hashAtom);
    _$hashAtom.reportObserved();
    return super.hash;
  }

  @override
  set hash(String value) {
    _$hashAtom.context.conditionallyRunInAction(() {
      super.hash = value;
      _$hashAtom.reportChanged();
    }, _$hashAtom, name: '${_$hashAtom.name}_set');
  }

  final _$timeAtom = Atom(name: '_BlockData.time');

  @override
  DateTime get time {
    _$timeAtom.context.enforceReadPolicy(_$timeAtom);
    _$timeAtom.reportObserved();
    return super.time;
  }

  @override
  set time(DateTime value) {
    _$timeAtom.context.conditionallyRunInAction(() {
      super.time = value;
      _$timeAtom.reportChanged();
    }, _$timeAtom, name: '${_$timeAtom.name}_set');
  }
}
