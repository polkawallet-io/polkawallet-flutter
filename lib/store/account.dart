import 'dart:convert';

import 'package:json_annotation/json_annotation.dart';
import 'package:mobx/mobx.dart';

import 'package:polka_wallet/utils/localStorage.dart';

part 'account.g.dart';

class AccountStore extends _AccountStore with _$AccountStore {
  AccountStore();
}

abstract class _AccountStore with Store {
  _AccountStore();

  @observable
  AccountCreate newAccount = AccountCreate();

  @observable
  Account currentAccount = Account();

  @observable
  AccountState accountState = AccountState('');

  @observable
  ObservableList<Account> accountList = ObservableList<Account>();

  @computed
  ObservableList<Account> get optionalAccounts {
    return ObservableList.of(
        accountList.where((i) => i.address != currentAccount.address));
  }

  @action
  void setNewAccount(String name, String password) {
    AccountCreate acc = AccountCreate();
    acc.name = name;
    acc.password = password;
    newAccount = acc;
  }

  @action
  void setNewAccountKey(String key) {
    AccountCreate acc = AccountCreate();
    acc.name = newAccount.name;
    acc.password = newAccount.password;
    acc.key = key;
    newAccount = acc;
    print(key);
  }

  @action
  void resetNewAccount(String name, String password) {
    newAccount = AccountCreate();
  }

  @action
  void setCurrentAccount(Account acc) {
    currentAccount = acc;
    accountState = AccountState(currentAccount.address);

    LocalStorage.setCurrentAccount(acc.address);
  }

  @action
  Future<void> addAccount(Map<String, dynamic> acc) async {
    await LocalStorage.addAccount(acc);
    await LocalStorage.setCurrentAccount(acc['address']);

    await loadAccount();
  }

  @action
  Future<void> removeAccount(Account acc) async {
    LocalStorage.removeAccount(acc.address);

    List<Map<String, dynamic>> accounts = await LocalStorage.getAccountList();
    if (accounts.length > 0) {
      await LocalStorage.setCurrentAccount(accounts[0]['address']);
    } else {
      await LocalStorage.setCurrentAccount('');
    }

    await loadAccount();
  }

  @action
  Future<void> loadAccount() async {
    List<Map<String, dynamic>> accList = await LocalStorage.getAccountList();
    accountList = ObservableList.of(accList.map((i) => Account.fromJson(i)));

    if (accountList.length > 0) {
      String address = await LocalStorage.getCurrentAccount();
      Map<String, dynamic> acc =
          accList.firstWhere((i) => i['address'] == address);
      currentAccount = Account.fromJson(acc);
    }
    print('load account: ${currentAccount.name}');
  }

  @action
  void setAccountBalance(String balance) {
    accountState.balance = balance;
  }
}

class AccountCreate with Store {
  @observable
  String name = '';

  @observable
  String password = '';

  @observable
  String key = '';
}

@JsonSerializable()
class Account extends _Account with _$Account {
  static Account fromJson(Map<String, dynamic> json) => _$AccountFromJson(json);
  static Map<String, dynamic> toJson(Account acc) => _$AccountToJson(acc);
}

abstract class _Account with Store {
  @observable
  String name = '';

  @observable
  String address = '';

  @observable
  String encoded = '';

  @observable
  Map<String, dynamic> encoding = Map<String, dynamic>();

  @observable
  Map<String, dynamic> meta = Map<String, dynamic>();
}

class AccountState extends _AccountState with _$AccountState {
  AccountState(String address) : super(address);
}

abstract class _AccountState with Store {
  _AccountState(this.address);

  @observable
  String address = '';

  @observable
  String balance = '0';
}
