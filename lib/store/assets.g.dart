// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'assets.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic

mixin _$AssetsStore on _AssetsStore, Store {
  final _$descriptionAtom = Atom(name: '_AssetsStore.description');

  @override
  String get description {
    _$descriptionAtom.context.enforceReadPolicy(_$descriptionAtom);
    _$descriptionAtom.reportObserved();
    return super.description;
  }

  @override
  set description(String value) {
    _$descriptionAtom.context.conditionallyRunInAction(() {
      super.description = value;
      _$descriptionAtom.reportChanged();
    }, _$descriptionAtom, name: '${_$descriptionAtom.name}_set');
  }

  final _$newAccountAtom = Atom(name: '_AssetsStore.newAccount');

  @override
  Map<String, dynamic> get newAccount {
    _$newAccountAtom.context.enforceReadPolicy(_$newAccountAtom);
    _$newAccountAtom.reportObserved();
    return super.newAccount;
  }

  @override
  set newAccount(Map<String, dynamic> value) {
    _$newAccountAtom.context.conditionallyRunInAction(() {
      super.newAccount = value;
      _$newAccountAtom.reportChanged();
    }, _$newAccountAtom, name: '${_$newAccountAtom.name}_set');
  }

  final _$currentAccountAtom = Atom(name: '_AssetsStore.currentAccount');

  @override
  Map<String, dynamic> get currentAccount {
    _$currentAccountAtom.context.enforceReadPolicy(_$currentAccountAtom);
    _$currentAccountAtom.reportObserved();
    return super.currentAccount;
  }

  @override
  set currentAccount(Map<String, dynamic> value) {
    _$currentAccountAtom.context.conditionallyRunInAction(() {
      super.currentAccount = value;
      _$currentAccountAtom.reportChanged();
    }, _$currentAccountAtom, name: '${_$currentAccountAtom.name}_set');
  }

  final _$loadAccountAsyncAction = AsyncAction('loadAccount');

  @override
  Future<void> loadAccount() {
    return _$loadAccountAsyncAction.run(() => super.loadAccount());
  }

  final _$_AssetsStoreActionController = ActionController(name: '_AssetsStore');

  @override
  void setNewAccount(Map<String, dynamic> acc) {
    final _$actionInfo = _$_AssetsStoreActionController.startAction();
    try {
      return super.setNewAccount(acc);
    } finally {
      _$_AssetsStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setCurrentAccount(Map<String, dynamic> acc) {
    final _$actionInfo = _$_AssetsStoreActionController.startAction();
    try {
      return super.setCurrentAccount(acc);
    } finally {
      _$_AssetsStoreActionController.endAction(_$actionInfo);
    }
  }
}
