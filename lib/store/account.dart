import 'package:flutter_aes_ecb_pkcs5/flutter_aes_ecb_pkcs5.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:mobx/mobx.dart';
import 'package:polka_wallet/utils/format.dart';

import 'package:polka_wallet/utils/localStorage.dart';

part 'account.g.dart';

class AccountStore extends _AccountStore with _$AccountStore {}

abstract class _AccountStore with Store {
  @observable
  bool loading = true;

  @observable
  AccountCreate newAccount = AccountCreate();

  @observable
  AccountData currentAccount = AccountData();

  @observable
  ObservableList<AccountData> accountList = ObservableList<AccountData>();

  @observable
  ObservableMap<String, Map> accountIndexMap = ObservableMap<String, Map>();

  @observable
  ObservableMap<String, String> pubKeyAddressMap =
      ObservableMap<String, String>();

  @observable
  ObservableMap<String, String> accountIconsMap =
      ObservableMap<String, String>();

  @computed
  ObservableList<AccountData> get optionalAccounts {
    return ObservableList.of(accountList.where(
        (i) => (pubKeyAddressMap[i.pubKey] ?? i.address) != currentAddress));
  }

  @computed
  String get currentAddress {
    return pubKeyAddressMap[currentAccount.pubKey] ?? currentAccount.address;
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
  void setCurrentAccount(AccountData acc) {
    currentAccount = acc;

    LocalStorage.setCurrentAccount(acc.pubKey);
  }

  @action
  void updateAccountName(String name) {
    Map<String, dynamic> acc = AccountData.toJson(currentAccount);
    acc['name'] = name;

    updateAccount(acc);
  }

  @action
  Future<void> updateAccount(Map<String, dynamic> acc) async {
    AccountData accNew = AccountData.fromJson(acc);
    await LocalStorage.removeAccount(accNew.pubKey);
    await LocalStorage.addAccount(acc);

    await loadAccount();
  }

  @action
  Future<void> addAccount(Map<String, dynamic> acc, String password) async {
    // save mnemonic and remove it before add account
    if (acc['mnemonic'] != null) {
      encryptMnemonic(acc['pubKey'], acc['mnemonic'], password);
      acc.remove(acc['mnemonic']);
    }

    await LocalStorage.addAccount(acc);
    await LocalStorage.setCurrentAccount(acc['pubKey']);

    await loadAccount();
  }

  @action
  Future<void> removeAccount(AccountData acc) async {
    await LocalStorage.removeAccount(acc.pubKey);

    // remove mnemonic after removing account
    Map stored = await LocalStorage.getMnemonic();
    if (stored[acc.pubKey] != null) {
      stored.remove([acc.pubKey]);
      LocalStorage.setMnemonic(stored);
    }

    // set new currentAccount after currentAccount was removed
    List<Map<String, dynamic>> accounts = await LocalStorage.getAccountList();
    if (accounts.length > 0) {
      await LocalStorage.setCurrentAccount(accounts[0]['pubKey']);
    } else {
      await LocalStorage.setCurrentAccount('');
    }

    await loadAccount();
  }

  @action
  Future<void> loadAccount() async {
    List<Map<String, dynamic>> accList = await LocalStorage.getAccountList();
    accountList =
        ObservableList.of(accList.map((i) => AccountData.fromJson(i)));

    if (accountList.length > 0) {
      String pubKey = await LocalStorage.getCurrentAccount();
      int accIndex = accList.indexWhere((i) => i['pubKey'] == pubKey);
      if (accIndex >= 0) {
        Map<String, dynamic> acc = accList[accIndex];
        currentAccount = AccountData.fromJson(acc);
      }
    }
    loading = false;
  }

  @action
  Future<void> encryptMnemonic(
      String pubKey, String mnemonic, String password) async {
    String key = Fmt.passwordToEncryptKey(password);
    String encrypted = await FlutterAesEcbPkcs5.encryptString(mnemonic, key);
    Map stored = await LocalStorage.getMnemonic();
    stored[pubKey] = encrypted;
    LocalStorage.setMnemonic(stored);
  }

  @action
  Future<String> decryptMnemonic(String pubKey, String password) async {
    Map stored = await LocalStorage.getMnemonic();
    String encrypted = stored[pubKey];
    if (encrypted == null) {
      return null;
    }
    return FlutterAesEcbPkcs5.decryptString(
        encrypted, Fmt.passwordToEncryptKey(password));
  }

  @action
  Future<bool> checkMnemonicExist(String pubKey) async {
    Map stored = await LocalStorage.getMnemonic();
    String encrypted = stored[pubKey];
    return encrypted != null;
  }

  @action
  Future<void> updateMnemonic(
      String pubKey, String passwordOld, String passwordNew) async {
    Map stored = await LocalStorage.getMnemonic();
    if (stored[pubKey] == null) {
      return;
    }
    String mnemonic = await FlutterAesEcbPkcs5.decryptString(
        stored[pubKey], Fmt.passwordToEncryptKey(passwordOld));
    encryptMnemonic(pubKey, mnemonic, passwordNew);
  }

  @action
  void setPubKeyAddressMap(List list) {
    list.forEach((i) {
      pubKeyAddressMap[i['pubKey']] = i['address'];
    });
  }

  @action
  void setAccountIconsMap(List list) {
    list.forEach((i) {
      accountIconsMap[i[0]] = i[1];
    });
  }

  @action
  void setAccountsIndex(List list) {
    list.forEach((i) {
      accountIndexMap[i['accountId']] = i;
    });
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
class AccountData extends _AccountData with _$AccountData {
  static AccountData fromJson(Map<String, dynamic> json) =>
      _$AccountDataFromJson(json);
  static Map<String, dynamic> toJson(AccountData acc) =>
      _$AccountDataToJson(acc);
}

abstract class _AccountData with Store {
  @observable
  String name = '';

  @observable
  String address = '';

  @observable
  String encoded = '';

  @observable
  String pubKey = '';

  @observable
  Map<String, dynamic> encoding = Map<String, dynamic>();

  @observable
  Map<String, dynamic> meta = Map<String, dynamic>();
}
