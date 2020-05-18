import 'package:flutter_aes_ecb_pkcs5/flutter_aes_ecb_pkcs5.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:mobx/mobx.dart';
import 'package:polka_wallet/page/profile/settings/ss58PrefixListPage.dart';
import 'package:polka_wallet/store/app.dart';
import 'package:polka_wallet/utils/format.dart';

import 'package:polka_wallet/utils/localStorage.dart';

part 'account.g.dart';

class AccountStore extends _AccountStore with _$AccountStore {
  AccountStore(AppStore appStore) : super(appStore);

  static const String seedTypeMnemonic = 'mnemonic';
  static const String seedTypeRawSeed = 'rawSeed';
  static const String seedTypeKeystore = 'keystore';
}

abstract class _AccountStore with Store {
  _AccountStore(this.rootStore);

  final AppStore rootStore;

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
  ObservableMap<int, Map<String, String>> pubKeyAddressMap =
      ObservableMap<int, Map<String, String>>();

  @observable
  ObservableMap<String, String> pubKeyIconsMap =
      ObservableMap<String, String>();

  @observable
  ObservableMap<String, String> addressIconsMap =
      ObservableMap<String, String>();

  @computed
  ObservableList<AccountData> get optionalAccounts {
    int ss58 = rootStore.settings.customSS58Format['value'];
    if (rootStore.settings.customSS58Format['info'] ==
        default_ss58_prefix['info']) {
      ss58 = rootStore.settings.endpoint.ss58;
      print(ss58);
    }
    return ObservableList.of(accountList.where((i) =>
        (pubKeyAddressMap[ss58][i.pubKey] ?? i.address) != currentAddress));
  }

  @computed
  String get currentAddress {
//    int ss58 = rootStore.settings.endpoint.ss58;
    int ss58 = rootStore.settings.customSS58Format['value'];
    if (rootStore.settings.customSS58Format['info'] ==
        default_ss58_prefix['info']) {
      ss58 = rootStore.settings.endpoint.ss58;
//      print(ss58);
    }
    return pubKeyAddressMap[ss58] != null
        ? pubKeyAddressMap[ss58][currentAccount.pubKey] ??
            currentAccount.address
        : currentAccount.address;
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
    String pubKey = acc['pubKey'];
    // save seed and remove it before add account
    void saveSeed(String seedType) {
      String seed = acc[seedType];
      if (seed != null && seed.isNotEmpty) {
        encryptSeed(pubKey, acc[seedType], seedType, password);
        acc.remove(acc[seedType]);
      }
    }

    saveSeed(AccountStore.seedTypeMnemonic);
    saveSeed(AccountStore.seedTypeRawSeed);

    // format meta data of acc
    acc = _formatMetaData(acc);

    int index = accountList.indexWhere((i) => i.pubKey == pubKey);
    if (index > -1) {
      await LocalStorage.removeAccount(pubKey);
      print('removed acc: $pubKey');
    }
    await LocalStorage.addAccount(acc);
    await LocalStorage.setCurrentAccount(pubKey);

    await loadAccount();

    // clear the temp account after addAccount finished
    newAccount = AccountCreate();
  }

  @action
  Future<void> removeAccount(AccountData acc) async {
    await LocalStorage.removeAccount(acc.pubKey);

    // remove encrypted seed after removing account
    deleteSeed(AccountStore.seedTypeMnemonic, acc.pubKey);
    deleteSeed(AccountStore.seedTypeRawSeed, acc.pubKey);

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
    Map storedMnemonics =
        await LocalStorage.getSeeds(AccountStore.seedTypeMnemonic);
    Map storedRawSeeds =
        await LocalStorage.getSeeds(AccountStore.seedTypeRawSeed);
    String encryptedSeed = '';
    String seedType = '';
    if (storedMnemonics[pubKey] != null) {
      encryptedSeed = storedMnemonics[pubKey];
      seedType = AccountStore.seedTypeMnemonic;
    } else if (storedMnemonics[pubKey] != null) {
      encryptedSeed = storedRawSeeds[pubKey];
      seedType = AccountStore.seedTypeRawSeed;
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
  void setPubKeyAddressMap(Map<String, Map> data) {
    data.keys.forEach((ss58) {
      // get old data map
      Map<String, String> addresses =
          Map.of(pubKeyAddressMap[int.parse(ss58)] ?? {});
      // set new data
      Map.of(data[ss58]).forEach((k, v) {
        addresses[k] = v;
      });
      print(addresses);
      // update state
      pubKeyAddressMap[int.parse(ss58)] = addresses;
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
