// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'account.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic

mixin _$AccountStore on _AccountStore, Store {
  Computed<AccountData> _$currentAccountComputed;

  @override
  AccountData get currentAccount => (_$currentAccountComputed ??=
          Computed<AccountData>(() => super.currentAccount,
              name: '_AccountStore.currentAccount'))
      .value;
  Computed<List<AccountData>> _$optionalAccountsComputed;

  @override
  List<AccountData> get optionalAccounts => (_$optionalAccountsComputed ??=
          Computed<List<AccountData>>(() => super.optionalAccounts,
              name: '_AccountStore.optionalAccounts'))
      .value;
  Computed<List<AccountData>> _$accountListAllComputed;

  @override
  List<AccountData> get accountListAll => (_$accountListAllComputed ??=
          Computed<List<AccountData>>(() => super.accountListAll,
              name: '_AccountStore.accountListAll'))
      .value;
  Computed<String> _$currentAddressComputed;

  @override
  String get currentAddress =>
      (_$currentAddressComputed ??= Computed<String>(() => super.currentAddress,
              name: '_AccountStore.currentAddress'))
          .value;

  final _$loadingAtom = Atom(name: '_AccountStore.loading');

  @override
  bool get loading {
    _$loadingAtom.reportRead();
    return super.loading;
  }

  @override
  set loading(bool value) {
    _$loadingAtom.reportWrite(value, super.loading, () {
      super.loading = value;
    });
  }

  final _$txStatusAtom = Atom(name: '_AccountStore.txStatus');

  @override
  String get txStatus {
    _$txStatusAtom.reportRead();
    return super.txStatus;
  }

  @override
  set txStatus(String value) {
    _$txStatusAtom.reportWrite(value, super.txStatus, () {
      super.txStatus = value;
    });
  }

  final _$newAccountAtom = Atom(name: '_AccountStore.newAccount');

  @override
  AccountCreate get newAccount {
    _$newAccountAtom.reportRead();
    return super.newAccount;
  }

  @override
  set newAccount(AccountCreate value) {
    _$newAccountAtom.reportWrite(value, super.newAccount, () {
      super.newAccount = value;
    });
  }

  final _$currentAccountPubKeyAtom =
      Atom(name: '_AccountStore.currentAccountPubKey');

  @override
  String get currentAccountPubKey {
    _$currentAccountPubKeyAtom.reportRead();
    return super.currentAccountPubKey;
  }

  @override
  set currentAccountPubKey(String value) {
    _$currentAccountPubKeyAtom.reportWrite(value, super.currentAccountPubKey,
        () {
      super.currentAccountPubKey = value;
    });
  }

  final _$accountListAtom = Atom(name: '_AccountStore.accountList');

  @override
  ObservableList<AccountData> get accountList {
    _$accountListAtom.reportRead();
    return super.accountList;
  }

  @override
  set accountList(ObservableList<AccountData> value) {
    _$accountListAtom.reportWrite(value, super.accountList, () {
      super.accountList = value;
    });
  }

  final _$addressIndexMapAtom = Atom(name: '_AccountStore.addressIndexMap');

  @override
  ObservableMap<String, Map<dynamic, dynamic>> get addressIndexMap {
    _$addressIndexMapAtom.reportRead();
    return super.addressIndexMap;
  }

  @override
  set addressIndexMap(ObservableMap<String, Map<dynamic, dynamic>> value) {
    _$addressIndexMapAtom.reportWrite(value, super.addressIndexMap, () {
      super.addressIndexMap = value;
    });
  }

  final _$accountIndexMapAtom = Atom(name: '_AccountStore.accountIndexMap');

  @override
  Map<String, Map<dynamic, dynamic>> get accountIndexMap {
    _$accountIndexMapAtom.reportRead();
    return super.accountIndexMap;
  }

  @override
  set accountIndexMap(Map<String, Map<dynamic, dynamic>> value) {
    _$accountIndexMapAtom.reportWrite(value, super.accountIndexMap, () {
      super.accountIndexMap = value;
    });
  }

  final _$pubKeyBondedMapAtom = Atom(name: '_AccountStore.pubKeyBondedMap');

  @override
  ObservableMap<String, AccountBondedInfo> get pubKeyBondedMap {
    _$pubKeyBondedMapAtom.reportRead();
    return super.pubKeyBondedMap;
  }

  @override
  set pubKeyBondedMap(ObservableMap<String, AccountBondedInfo> value) {
    _$pubKeyBondedMapAtom.reportWrite(value, super.pubKeyBondedMap, () {
      super.pubKeyBondedMap = value;
    });
  }

  final _$pubKeyAddressMapAtom = Atom(name: '_AccountStore.pubKeyAddressMap');

  @override
  ObservableMap<int, Map<String, String>> get pubKeyAddressMap {
    _$pubKeyAddressMapAtom.reportRead();
    return super.pubKeyAddressMap;
  }

  @override
  set pubKeyAddressMap(ObservableMap<int, Map<String, String>> value) {
    _$pubKeyAddressMapAtom.reportWrite(value, super.pubKeyAddressMap, () {
      super.pubKeyAddressMap = value;
    });
  }

  final _$pubKeyIconsMapAtom = Atom(name: '_AccountStore.pubKeyIconsMap');

  @override
  ObservableMap<String, String> get pubKeyIconsMap {
    _$pubKeyIconsMapAtom.reportRead();
    return super.pubKeyIconsMap;
  }

  @override
  set pubKeyIconsMap(ObservableMap<String, String> value) {
    _$pubKeyIconsMapAtom.reportWrite(value, super.pubKeyIconsMap, () {
      super.pubKeyIconsMap = value;
    });
  }

  final _$addressIconsMapAtom = Atom(name: '_AccountStore.addressIconsMap');

  @override
  ObservableMap<String, String> get addressIconsMap {
    _$addressIconsMapAtom.reportRead();
    return super.addressIconsMap;
  }

  @override
  set addressIconsMap(ObservableMap<String, String> value) {
    _$addressIconsMapAtom.reportWrite(value, super.addressIconsMap, () {
      super.addressIconsMap = value;
    });
  }

  final _$recoveryInfoAtom = Atom(name: '_AccountStore.recoveryInfo');

  @override
  AccountRecoveryInfo get recoveryInfo {
    _$recoveryInfoAtom.reportRead();
    return super.recoveryInfo;
  }

  @override
  set recoveryInfo(AccountRecoveryInfo value) {
    _$recoveryInfoAtom.reportWrite(value, super.recoveryInfo, () {
      super.recoveryInfo = value;
    });
  }

  final _$updateAccountNameAsyncAction =
      AsyncAction('_AccountStore.updateAccountName');

  @override
  Future<void> updateAccountName(String name) {
    return _$updateAccountNameAsyncAction
        .run(() => super.updateAccountName(name));
  }

  final _$updateAccountAsyncAction = AsyncAction('_AccountStore.updateAccount');

  @override
  Future<void> updateAccount(Map<String, dynamic> acc) {
    return _$updateAccountAsyncAction.run(() => super.updateAccount(acc));
  }

  final _$addAccountAsyncAction = AsyncAction('_AccountStore.addAccount');

  @override
  Future<void> addAccount(Map<String, dynamic> acc, String password) {
    return _$addAccountAsyncAction.run(() => super.addAccount(acc, password));
  }

  final _$removeAccountAsyncAction = AsyncAction('_AccountStore.removeAccount');

  @override
  Future<void> removeAccount(AccountData acc) {
    return _$removeAccountAsyncAction.run(() => super.removeAccount(acc));
  }

  final _$loadAccountAsyncAction = AsyncAction('_AccountStore.loadAccount');

  @override
  Future<void> loadAccount() {
    return _$loadAccountAsyncAction.run(() => super.loadAccount());
  }

  final _$setAccountsBondedAsyncAction =
      AsyncAction('_AccountStore.setAccountsBonded');

  @override
  Future<void> setAccountsBonded(List<dynamic> ls) {
    return _$setAccountsBondedAsyncAction
        .run(() => super.setAccountsBonded(ls));
  }

  final _$encryptSeedAsyncAction = AsyncAction('_AccountStore.encryptSeed');

  @override
  Future<void> encryptSeed(
      String pubKey, String seed, String seedType, String password) {
    return _$encryptSeedAsyncAction
        .run(() => super.encryptSeed(pubKey, seed, seedType, password));
  }

  final _$decryptSeedAsyncAction = AsyncAction('_AccountStore.decryptSeed');

  @override
  Future<String> decryptSeed(String pubKey, String seedType, String password) {
    return _$decryptSeedAsyncAction
        .run(() => super.decryptSeed(pubKey, seedType, password));
  }

  final _$checkSeedExistAsyncAction =
      AsyncAction('_AccountStore.checkSeedExist');

  @override
  Future<bool> checkSeedExist(String seedType, String pubKey) {
    return _$checkSeedExistAsyncAction
        .run(() => super.checkSeedExist(seedType, pubKey));
  }

  final _$updateSeedAsyncAction = AsyncAction('_AccountStore.updateSeed');

  @override
  Future<void> updateSeed(
      String pubKey, String passwordOld, String passwordNew) {
    return _$updateSeedAsyncAction
        .run(() => super.updateSeed(pubKey, passwordOld, passwordNew));
  }

  final _$deleteSeedAsyncAction = AsyncAction('_AccountStore.deleteSeed');

  @override
  Future<void> deleteSeed(String seedType, String pubKey) {
    return _$deleteSeedAsyncAction
        .run(() => super.deleteSeed(seedType, pubKey));
  }

  final _$_AccountStoreActionController =
      ActionController(name: '_AccountStore');

  @override
  void setTxStatus(String status) {
    final _$actionInfo = _$_AccountStoreActionController.startAction(
        name: '_AccountStore.setTxStatus');
    try {
      return super.setTxStatus(status);
    } finally {
      _$_AccountStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setNewAccount(String name, String password) {
    final _$actionInfo = _$_AccountStoreActionController.startAction(
        name: '_AccountStore.setNewAccount');
    try {
      return super.setNewAccount(name, password);
    } finally {
      _$_AccountStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setNewAccountKey(String key) {
    final _$actionInfo = _$_AccountStoreActionController.startAction(
        name: '_AccountStore.setNewAccountKey');
    try {
      return super.setNewAccountKey(key);
    } finally {
      _$_AccountStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void resetNewAccount() {
    final _$actionInfo = _$_AccountStoreActionController.startAction(
        name: '_AccountStore.resetNewAccount');
    try {
      return super.resetNewAccount();
    } finally {
      _$_AccountStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setCurrentAccount(String pubKey) {
    final _$actionInfo = _$_AccountStoreActionController.startAction(
        name: '_AccountStore.setCurrentAccount');
    try {
      return super.setCurrentAccount(pubKey);
    } finally {
      _$_AccountStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setPubKeyAddressMap(Map<String, Map<dynamic, dynamic>> data) {
    final _$actionInfo = _$_AccountStoreActionController.startAction(
        name: '_AccountStore.setPubKeyAddressMap');
    try {
      return super.setPubKeyAddressMap(data);
    } finally {
      _$_AccountStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setPubKeyIconsMap(List<dynamic> list) {
    final _$actionInfo = _$_AccountStoreActionController.startAction(
        name: '_AccountStore.setPubKeyIconsMap');
    try {
      return super.setPubKeyIconsMap(list);
    } finally {
      _$_AccountStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setAddressIconsMap(List<dynamic> list) {
    final _$actionInfo = _$_AccountStoreActionController.startAction(
        name: '_AccountStore.setAddressIconsMap');
    try {
      return super.setAddressIconsMap(list);
    } finally {
      _$_AccountStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setAccountsIndex(List<dynamic> list) {
    final _$actionInfo = _$_AccountStoreActionController.startAction(
        name: '_AccountStore.setAccountsIndex');
    try {
      return super.setAccountsIndex(list);
    } finally {
      _$_AccountStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setAddressIndex(List<dynamic> list) {
    final _$actionInfo = _$_AccountStoreActionController.startAction(
        name: '_AccountStore.setAddressIndex');
    try {
      return super.setAddressIndex(list);
    } finally {
      _$_AccountStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setAccountRecoveryInfo(Map<dynamic, dynamic> json) {
    final _$actionInfo = _$_AccountStoreActionController.startAction(
        name: '_AccountStore.setAccountRecoveryInfo');
    try {
      return super.setAccountRecoveryInfo(json);
    } finally {
      _$_AccountStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
loading: ${loading},
txStatus: ${txStatus},
newAccount: ${newAccount},
currentAccountPubKey: ${currentAccountPubKey},
accountList: ${accountList},
addressIndexMap: ${addressIndexMap},
accountIndexMap: ${accountIndexMap},
pubKeyBondedMap: ${pubKeyBondedMap},
pubKeyAddressMap: ${pubKeyAddressMap},
pubKeyIconsMap: ${pubKeyIconsMap},
addressIconsMap: ${addressIconsMap},
recoveryInfo: ${recoveryInfo},
currentAccount: ${currentAccount},
optionalAccounts: ${optionalAccounts},
accountListAll: ${accountListAll},
currentAddress: ${currentAddress}
    ''';
  }
}

mixin _$AccountCreate on _AccountCreate, Store {
  final _$nameAtom = Atom(name: '_AccountCreate.name');

  @override
  String get name {
    _$nameAtom.reportRead();
    return super.name;
  }

  @override
  set name(String value) {
    _$nameAtom.reportWrite(value, super.name, () {
      super.name = value;
    });
  }

  final _$passwordAtom = Atom(name: '_AccountCreate.password');

  @override
  String get password {
    _$passwordAtom.reportRead();
    return super.password;
  }

  @override
  set password(String value) {
    _$passwordAtom.reportWrite(value, super.password, () {
      super.password = value;
    });
  }

  final _$keyAtom = Atom(name: '_AccountCreate.key');

  @override
  String get key {
    _$keyAtom.reportRead();
    return super.key;
  }

  @override
  set key(String value) {
    _$keyAtom.reportWrite(value, super.key, () {
      super.key = value;
    });
  }

  @override
  String toString() {
    return '''
name: ${name},
password: ${password},
key: ${key}
    ''';
  }
}
