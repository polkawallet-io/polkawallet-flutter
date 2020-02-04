// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'account.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Account _$AccountFromJson(Map<String, dynamic> json) {
  return Account()
    ..name = json['name'] as String
    ..address = json['address'] as String
    ..encoded = json['encoded'] as String
    ..encoding = json['encoding'] as Map<String, dynamic>
    ..meta = json['meta'] as Map<String, dynamic>;
}

Map<String, dynamic> _$AccountToJson(Account instance) => <String, dynamic>{
      'name': instance.name,
      'address': instance.address,
      'encoded': instance.encoded,
      'encoding': instance.encoding,
      'meta': instance.meta,
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

  final _$newAccountAtom = Atom(name: '_AccountStore.newAccount');

  @override
  AccountCreate get newAccount {
    _$newAccountAtom.context.enforceReadPolicy(_$newAccountAtom);
    _$newAccountAtom.reportObserved();
    return super.newAccount;
  }

  @override
  set newAccount(AccountCreate value) {
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

  final _$assetsStateAtom = Atom(name: '_AccountStore.assetsState');

  @override
  AssetsState get assetsState {
    _$assetsStateAtom.context.enforceReadPolicy(_$assetsStateAtom);
    _$assetsStateAtom.reportObserved();
    return super.assetsState;
  }

  @override
  set assetsState(AssetsState value) {
    _$assetsStateAtom.context.conditionallyRunInAction(() {
      super.assetsState = value;
      _$assetsStateAtom.reportChanged();
    }, _$assetsStateAtom, name: '${_$assetsStateAtom.name}_set');
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
  Future<void> addAccount(Map<String, dynamic> acc) {
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
  void setNewAccount(String name, String password) {
    final _$actionInfo = _$_AccountStoreActionController.startAction();
    try {
      return super.setNewAccount(name, password);
    } finally {
      _$_AccountStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setNewAccountKey(String key) {
    final _$actionInfo = _$_AccountStoreActionController.startAction();
    try {
      return super.setNewAccountKey(key);
    } finally {
      _$_AccountStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void resetNewAccount(String name, String password) {
    final _$actionInfo = _$_AccountStoreActionController.startAction();
    try {
      return super.resetNewAccount(name, password);
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

mixin _$AccountCreate on _AccountCreate, Store {
  final _$nameAtom = Atom(name: '_AccountCreate.name');

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

  final _$passwordAtom = Atom(name: '_AccountCreate.password');

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

  final _$keyAtom = Atom(name: '_AccountCreate.key');

  @override
  String get key {
    _$keyAtom.context.enforceReadPolicy(_$keyAtom);
    _$keyAtom.reportObserved();
    return super.key;
  }

  @override
  set key(String value) {
    _$keyAtom.context.conditionallyRunInAction(() {
      super.key = value;
      _$keyAtom.reportChanged();
    }, _$keyAtom, name: '${_$keyAtom.name}_set');
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

  final _$encodedAtom = Atom(name: '_Account.encoded');

  @override
  String get encoded {
    _$encodedAtom.context.enforceReadPolicy(_$encodedAtom);
    _$encodedAtom.reportObserved();
    return super.encoded;
  }

  @override
  set encoded(String value) {
    _$encodedAtom.context.conditionallyRunInAction(() {
      super.encoded = value;
      _$encodedAtom.reportChanged();
    }, _$encodedAtom, name: '${_$encodedAtom.name}_set');
  }

  final _$encodingAtom = Atom(name: '_Account.encoding');

  @override
  Map<String, dynamic> get encoding {
    _$encodingAtom.context.enforceReadPolicy(_$encodingAtom);
    _$encodingAtom.reportObserved();
    return super.encoding;
  }

  @override
  set encoding(Map<String, dynamic> value) {
    _$encodingAtom.context.conditionallyRunInAction(() {
      super.encoding = value;
      _$encodingAtom.reportChanged();
    }, _$encodingAtom, name: '${_$encodingAtom.name}_set');
  }

  final _$metaAtom = Atom(name: '_Account.meta');

  @override
  Map<String, dynamic> get meta {
    _$metaAtom.context.enforceReadPolicy(_$metaAtom);
    _$metaAtom.reportObserved();
    return super.meta;
  }

  @override
  set meta(Map<String, dynamic> value) {
    _$metaAtom.context.conditionallyRunInAction(() {
      super.meta = value;
      _$metaAtom.reportChanged();
    }, _$metaAtom, name: '${_$metaAtom.name}_set');
  }
}
