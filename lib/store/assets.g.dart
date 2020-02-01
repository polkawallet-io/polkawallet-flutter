// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'assets.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic

mixin _$AssetsState on _AssetsState, Store {
  final _$balanceAtom = Atom(name: '_AssetsState.balance');

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

  final _$txsAtom = Atom(name: '_AssetsState.txs');

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

  final _$txDetailAtom = Atom(name: '_AssetsState.txDetail');

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
