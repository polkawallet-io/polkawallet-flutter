import 'package:json_annotation/json_annotation.dart';
import 'package:mobx/mobx.dart';

import 'package:polka_wallet/utils/localStorage.dart';

import 'package:polka_wallet/store/assets.dart';

part 'account.g.dart';

// TODO: refactor AccountStore
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
  void updateAccountName(String name) {
    Map<String, dynamic> acc = Account.toJson(currentAccount);
    acc['name'] = name;

    updateAccount(acc);
  }

  @action
  Future<void> updateAccount(Map<String, dynamic> acc) async {
    Account accNew = Account.fromJson(acc);
    await LocalStorage.removeAccount(accNew.address);
    await LocalStorage.addAccount(acc);

    await loadAccount();
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
      assetsState.address = currentAccount.address;
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
