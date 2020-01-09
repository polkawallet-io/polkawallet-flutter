import 'dart:convert';

import 'package:mobx/mobx.dart';

import 'package:polka_wallet/utils/localStorage.dart';

part 'assets.g.dart';

class AssetsStore extends _AssetsStore with _$AssetsStore {
  AssetsStore();
}

abstract class _AssetsStore with Store {
  _AssetsStore();

  @observable
  String description = '';

  @observable
  Map<String, dynamic> newAccount = ObservableMap.of(Map<String, dynamic>.from({
    'name': '',
    'password': '',
    'address': '',
    'seed': '',
    'isLocked': false,
    'mnemonic': '',
  }));

  @observable
  Map<String, dynamic> currentAccount =
      ObservableMap.of(Map<String, dynamic>.from({
    'name': '',
    'password': '',
    'address': '',
    'seed': '',
    'isLocked': false,
    'mnemonic': '',
  }));

  @action
  void setNewAccount(Map<String, dynamic> acc) {
    for (var k in acc.keys) {
      newAccount[k] = acc[k];
    }

    print('setNewAccount:');
    print(newAccount);
  }

  @action
  void setCurrentAccount(Map<String, dynamic> acc) {
    for (var k in acc.keys) {
      currentAccount[k] = acc[k];
    }

    print('setCurrentAccount:');
    print(currentAccount);
  }

  @action
  Future<void> loadAccount() async {
    String accStr = await LocalStorage.getItem('acc');

    print('load acc: $accStr');
    if (accStr != null) {
      Map<String, dynamic> acc = jsonDecode(accStr);
      setCurrentAccount(acc);
    }
  }
}
