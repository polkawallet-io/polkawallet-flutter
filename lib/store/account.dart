import 'package:flutter_aes_ecb_pkcs5/flutter_aes_ecb_pkcs5.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:mobx/mobx.dart';
import 'package:polka_wallet/utils/format.dart';

import 'package:polka_wallet/utils/localStorage.dart';

part 'account.g.dart';

class AccountStore extends _AccountStore with _$AccountStore {}

abstract class _AccountStore with Store {
  final String seedTypeMnemonic = 'mnemonic';
  final String seedTypeRaw = 'rawSeed';

  Map<String, dynamic> _formatMetaData(Map<String, dynamic> acc) {
    String name = acc['meta']['name'];
    if (name == null) {
      name = newAccount.name;
    }
    acc['name'] = name;
    if (acc['meta']['whenCreated'] == null) {
      acc['meta']['whenCreated'] = DateTime.now().millisecondsSinceEpoch;
    }
    acc['meta']['whenEdited'] = DateTime.now().millisecondsSinceEpoch;
    return acc;
  }

  @observable
  bool loading = true;

  @observable
  String txStatus = '';

  @observable
  AccountCreate newAccount = AccountCreate();

  @observable
  AccountData currentAccount = AccountData();

  @observable
  ObservableList<AccountData> accountList = ObservableList<AccountData>();

  @observable
  ObservableMap<String, Map> accountIndexMap = ObservableMap<String, Map>();

  @observable
  ObservableMap<String, AccountBondedInfo> pubKeyBondedMap =
      ObservableMap<String, AccountBondedInfo>();

  @observable
  ObservableMap<String, String> pubKeyAddressMap =
      ObservableMap<String, String>();

  @observable
  ObservableMap<String, String> pubKeyIconsMap =
      ObservableMap<String, String>();

  @observable
  ObservableMap<String, String> addressIconsMap =
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
  void setTxStatus(String status) {
    txStatus = status;
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
    acc['meta']['name'] = name;

    updateAccount(acc);
  }

  @action
  Future<void> updateAccount(Map<String, dynamic> acc) async {
    acc = _formatMetaData(acc);

    AccountData accNew = AccountData.fromJson(acc);
    await LocalStorage.removeAccount(accNew.pubKey);
    await LocalStorage.addAccount(acc);

    await loadAccount();
  }

  @action
  Future<void> addAccount(Map<String, dynamic> acc, String password) async {
    // save seed and remove it before add account
    void saveSeed(String seedType) {
      String seed = acc[seedType];
      if (seed != null && seed.isNotEmpty) {
        encryptSeed(acc['pubKey'], acc[seedType], seedType, password);
        acc.remove(acc[seedType]);
      }
    }

    saveSeed(seedTypeMnemonic);
    saveSeed(seedTypeRaw);

    // format meta data of acc
    acc = _formatMetaData(acc);

    await LocalStorage.addAccount(acc);
    await LocalStorage.setCurrentAccount(acc['pubKey']);

    await loadAccount();

    // clear the temp account after addAccount finished
    newAccount = AccountCreate();
  }

  @action
  Future<void> removeAccount(AccountData acc) async {
    await LocalStorage.removeAccount(acc.pubKey);

    // remove encrypted seed after removing account
    deleteSeed(seedTypeMnemonic, acc.pubKey);
    deleteSeed(seedTypeRaw, acc.pubKey);

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
  Future<void> setAccountsBonded(List ls) async {
    ls.forEach((i) {
      pubKeyBondedMap[i[0]] = AccountBondedInfo(i[0], i[1], i[2]);
    });
  }

  @action
  Future<void> encryptSeed(
      String pubKey, String seed, String seedType, String password) async {
    String key = Fmt.passwordToEncryptKey(password);
    String encrypted = await FlutterAesEcbPkcs5.encryptString(seed, key);
    Map stored = await LocalStorage.getSeeds(seedType);
    stored[pubKey] = encrypted;
    LocalStorage.setSeeds(seedType, stored);
  }

  @action
  Future<String> decryptSeed(
      String pubKey, String seedType, String password) async {
    Map stored = await LocalStorage.getSeeds(seedType);
    String encrypted = stored[pubKey];
    if (encrypted == null) {
      return null;
    }
    return FlutterAesEcbPkcs5.decryptString(
        encrypted, Fmt.passwordToEncryptKey(password));
  }

  @action
  Future<bool> checkSeedExist(String seedType, String pubKey) async {
    Map stored = await LocalStorage.getSeeds(seedType);
    String encrypted = stored[pubKey];
    return encrypted != null;
  }

  @action
  Future<void> updateSeed(
      String pubKey, String passwordOld, String passwordNew) async {
    Map storedMnemonics = await LocalStorage.getSeeds(seedTypeMnemonic);
    Map storedRawSeeds = await LocalStorage.getSeeds(seedTypeRaw);
    String encryptedSeed = '';
    String seedType = '';
    if (storedMnemonics[pubKey] != null) {
      encryptedSeed = storedMnemonics[pubKey];
      seedType = seedTypeMnemonic;
    } else if (storedMnemonics[pubKey] != null) {
      encryptedSeed = storedRawSeeds[pubKey];
      seedType = seedTypeRaw;
    } else {
      return;
    }

    String seed = await FlutterAesEcbPkcs5.decryptString(
        encryptedSeed, Fmt.passwordToEncryptKey(passwordOld));
    encryptSeed(pubKey, seed, seedType, passwordNew);
  }

  @action
  Future<void> deleteSeed(String seedType, String pubKey) async {
    Map stored = await LocalStorage.getSeeds(seedType);
    if (stored[pubKey] != null) {
      stored.remove(pubKey);
      LocalStorage.setSeeds(seedType, stored);
    }
  }

  @action
  void setPubKeyAddressMap(List list) {
    list.forEach((i) {
      pubKeyAddressMap[i['pubKey']] = i['address'];
    });
  }

  @action
  void setPubKeyIconsMap(List list) {
    list.forEach((i) {
      pubKeyIconsMap[i[0]] = i[1];
    });
  }

  @action
  void setAddressIconsMap(List list) {
    list.forEach((i) {
      addressIconsMap[i[0]] = i[1];
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

  @observable
  String memo = '';
}

class AccountBondedInfo {
  AccountBondedInfo(this.pubKey, this.controllerId, this.stashId);
  final String pubKey;
  // controllerId != null, means the account is a stash
  final String controllerId;
  // stashId != null, means the account is a controller
  final String stashId;
}
