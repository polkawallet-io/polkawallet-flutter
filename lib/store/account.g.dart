// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'account.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Account _$AccountFromJson(Map<String, dynamic> json) {
  return Account(
    json['name'] as String,
  )
    ..password = json['password'] as String
    ..address = json['address'] as String
    ..seed = json['seed'] as String
    ..mnemonic = json['mnemonic'] as String;
}

Map<String, dynamic> _$AccountToJson(Account instance) => <String, dynamic>{
      'name': instance.name,
      'password': instance.password,
      'address': instance.address,
      'seed': instance.seed,
      'mnemonic': instance.mnemonic,
    };

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic

mixin _$AccountStore on _AccountStore, Store {
  Computed<ObservableList<Account>> _$optionalAccountsComputed;

  @override
  ObservableList<Account> get optionalAccounts =>
      (_$optionalAccountsComputed ??=
              Computed<ObservableList<Account>>(() => super.optionalAccounts))
          .value;

  final _$descriptionAtom = Atom(name: '_AccountStore.description');

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

  final _$newAccountAtom = Atom(name: '_AccountStore.newAccount');

  @override
  Account get newAccount {
    _$newAccountAtom.context.enforceReadPolicy(_$newAccountAtom);
    _$newAccountAtom.reportObserved();
    return super.newAccount;
  }

  @override
  set newAccount(Account value) {
    _$newAccountAtom.context.conditionallyRunInAction(() {
      super.newAccount = value;
      _$newAccountAtom.reportChanged();
    }, _$newAccountAtom, name: '${_$newAccountAtom.name}_set');
  }

  final _$currentAccountAtom = Atom(name: '_AccountStore.currentAccount');

  @override
  Account get currentAccount {
    _$currentAccountAtom.context.enforceReadPolicy(_$currentAccountAtom);
    _$currentAccountAtom.reportObserved();
    return super.currentAccount;
  }

  @override
  set currentAccount(Account value) {
    _$currentAccountAtom.context.conditionallyRunInAction(() {
      super.currentAccount = value;
      _$currentAccountAtom.reportChanged();
    }, _$currentAccountAtom, name: '${_$currentAccountAtom.name}_set');
  }

  final _$accountListAtom = Atom(name: '_AccountStore.accountList');

  @override
  ObservableList<Account> get accountList {
    _$accountListAtom.context.enforceReadPolicy(_$accountListAtom);
    _$accountListAtom.reportObserved();
    return super.accountList;
  }

  @override
  set accountList(ObservableList<Account> value) {
    _$accountListAtom.context.conditionallyRunInAction(() {
      super.accountList = value;
      _$accountListAtom.reportChanged();
    }, _$accountListAtom, name: '${_$accountListAtom.name}_set');
  }

  final _$addAccountAsyncAction = AsyncAction('addAccount');

  @override
  Future<void> addAccount(Account acc) {
    return _$addAccountAsyncAction.run(() => super.addAccount(acc));
  }

  final _$removeAccountAsyncAction = AsyncAction('removeAccount');

  @override
  Future<void> removeAccount(Account acc) {
    return _$removeAccountAsyncAction.run(() => super.removeAccount(acc));
  }

  final _$loadAccountAsyncAction = AsyncAction('loadAccount');

  @override
  Future<void> loadAccount() {
    return _$loadAccountAsyncAction.run(() => super.loadAccount());
  }

  final _$_AccountStoreActionController =
      ActionController(name: '_AccountStore');

  @override
  void setNewAccount(Map<String, dynamic> acc) {
    final _$actionInfo = _$_AccountStoreActionController.startAction();
    try {
      return super.setNewAccount(acc);
    } finally {
      _$_AccountStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setCurrentAccount(Account acc) {
    final _$actionInfo = _$_AccountStoreActionController.startAction();
    try {
      return super.setCurrentAccount(acc);
    } finally {
      _$_AccountStoreActionController.endAction(_$actionInfo);
    }
  }
}

mixin _$Account on _Account, Store {
  final _$nameAtom = Atom(name: '_Account.name');

  @override
  String get name {
    _$nameAtom.context.enforceReadPolicy(_$nameAtom);
    _$nameAtom.reportObserved();
    return super.name;
  }

  @override
  set name(String value) {
    _$nameAtom.context.conditionallyRunInAction(() {
      super.name = value;
      _$nameAtom.reportChanged();
    }, _$nameAtom, name: '${_$nameAtom.name}_set');
  }

  final _$passwordAtom = Atom(name: '_Account.password');

  @override
  String get password {
    _$passwordAtom.context.enforceReadPolicy(_$passwordAtom);
    _$passwordAtom.reportObserved();
    return super.password;
  }

  @override
  set password(String value) {
    _$passwordAtom.context.conditionallyRunInAction(() {
      super.password = value;
      _$passwordAtom.reportChanged();
    }, _$passwordAtom, name: '${_$passwordAtom.name}_set');
  }

  final _$addressAtom = Atom(name: '_Account.address');

  @override
  String get address {
    _$addressAtom.context.enforceReadPolicy(_$addressAtom);
    _$addressAtom.reportObserved();
    return super.address;
  }

  @override
  set address(String value) {
    _$addressAtom.context.conditionallyRunInAction(() {
      super.address = value;
      _$addressAtom.reportChanged();
    }, _$addressAtom, name: '${_$addressAtom.name}_set');
  }

  final _$seedAtom = Atom(name: '_Account.seed');

  @override
  String get seed {
    _$seedAtom.context.enforceReadPolicy(_$seedAtom);
    _$seedAtom.reportObserved();
    return super.seed;
  }

  @override
  set seed(String value) {
    _$seedAtom.context.conditionallyRunInAction(() {
      super.seed = value;
      _$seedAtom.reportChanged();
    }, _$seedAtom, name: '${_$seedAtom.name}_set');
  }

  final _$mnemonicAtom = Atom(name: '_Account.mnemonic');

  @override
  String get mnemonic {
    _$mnemonicAtom.context.enforceReadPolicy(_$mnemonicAtom);
    _$mnemonicAtom.reportObserved();
    return super.mnemonic;
  }

  @override
  set mnemonic(String value) {
    _$mnemonicAtom.context.conditionallyRunInAction(() {
      super.mnemonic = value;
      _$mnemonicAtom.reportChanged();
    }, _$mnemonicAtom, name: '${_$mnemonicAtom.name}_set');
  }
}
