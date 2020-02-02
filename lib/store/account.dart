import 'dart:convert';

import 'package:json_annotation/json_annotation.dart';
import 'package:mobx/mobx.dart';
import 'package:polka_wallet/service/polkascan.dart';

import 'package:polka_wallet/utils/localStorage.dart';

import 'package:polka_wallet/store/assets.dart';

part 'account.g.dart';

class AccountStore extends _AccountStore with _$AccountStore {}

abstract class _AccountStore with Store {
  @observable
  AccountCreate newAccount = AccountCreate();

  @observable
  Account currentAccount = Account();

  @observable
  AssetsState assetsState = AssetsState();

  @observable
  ObservableList<Account> accountList = ObservableList<Account>();

  @computed
  ObservableList<Account> get optionalAccounts {
    return ObservableList.of(
        accountList.where((i) => i.address != currentAccount.address));
  }

  @action
  void setNewAccount(String name, String password) {
    newAccount.name = name;
    newAccount.password = password;
  }

  @action
  void setNewAccountKey(String key) {
    newAccount.key = key;
  }

  @action
  void resetNewAccount(String name, String password) {
    newAccount = AccountCreate();
  }

  @action
  void setCurrentAccount(Account acc) {
    currentAccount = acc;
    assetsState.address = acc.address;

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
    assetsState.balance = balance;
  }

  @action
  Future<void> getTxs() async {
    String data = await PolkaScanApi.fetchTxs(currentAccount.address);
    List<dynamic> txs = jsonDecode(data)['data'];
    assetsState.txs.clear();
    txs.forEach((i) {
      TransferData tx = TransferData.fromJson(i);
      assetsState.txs.add(tx);
    });
  }

  @action
  void setTxsFilter(int filter) {
    assetsState.txsFilter = filter;
  }

  @action
  Future<void> getBlock(String hash) async {
    if (assetsState.blockMap[hash] == null) {
      String data = await PolkaScanApi.fetchBlock(hash);
      assetsState.blockMap[hash] =
          BlockData.fromJson(jsonDecode(data)['data']['attributes']);
    }
  }
}

class AccountCreate extends _AccountCreate with _$AccountCreate {}

abstract class _AccountCreate with Store {
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
