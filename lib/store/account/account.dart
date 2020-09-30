import 'package:flutter_aes_ecb_pkcs5/flutter_aes_ecb_pkcs5.dart';
import 'package:mobx/mobx.dart';
import 'package:polka_wallet/page/profile/settings/ss58PrefixListPage.dart';
import 'package:polka_wallet/store/account/types/accountBondedInfo.dart';
import 'package:polka_wallet/store/account/types/accountData.dart';
import 'package:polka_wallet/store/account/types/accountRecoveryInfo.dart';
import 'package:polka_wallet/store/app.dart';
import 'package:polka_wallet/utils/format.dart';

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
    acc['name'] =
        newAccount.name.isEmpty ? acc['meta']['name'] : newAccount.name;
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
  String currentAccountPubKey = '';

  @observable
  ObservableList<AccountData> accountList = ObservableList<AccountData>();

  @observable
  ObservableMap<String, Map> addressIndexMap = ObservableMap<String, Map>();

  @observable
  Map<String, Map> accountIndexMap = Map<String, Map>();

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

  @observable
  AccountRecoveryInfo recoveryInfo = AccountRecoveryInfo();

  @computed
  AccountData get currentAccount {
    int i = accountListAll.indexWhere((i) => i.pubKey == currentAccountPubKey);
    if (i < 0) {
      return accountListAll[0] ?? AccountData();
    }
    return accountListAll[i];
  }

  @computed
  List<AccountData> get optionalAccounts {
    return accountListAll
        .where((i) => i.pubKey != currentAccountPubKey)
        .toList();
  }

  /// accountList with observations
  @computed
  List<AccountData> get accountListAll {
    List<AccountData> accList = accountList.toList();
    List<AccountData> contactList = rootStore.settings.contactList.toList();
    contactList.retainWhere((i) => i.observation ?? false);
    accList.addAll(contactList);
    return accList;
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
        ? pubKeyAddressMap[ss58][currentAccountPubKey] ?? currentAccount.address
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
  void resetNewAccount() {
    newAccount = AccountCreate();
  }

  @action
  void setCurrentAccount(String pubKey) {
    currentAccountPubKey = pubKey;

    rootStore.localStorage.setCurrentAccount(pubKey);
  }

  @action
  Future<void> updateAccountName(String name) async {
    Map<String, dynamic> acc = AccountData.toJson(currentAccount);
    acc['meta']['name'] = name;

    await updateAccount(acc);
  }

  @action
  Future<void> updateAccount(Map<String, dynamic> acc) async {
    acc = _formatMetaData(acc);

    AccountData accNew = AccountData.fromJson(acc);
    await rootStore.localStorage.removeAccount(accNew.pubKey);
    await rootStore.localStorage.addAccount(acc);

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
        acc.remove(seedType);
      }
    }

    saveSeed(AccountStore.seedTypeMnemonic);
    saveSeed(AccountStore.seedTypeRawSeed);

    // format meta data of acc
    acc = _formatMetaData(acc);

    int index = accountList.indexWhere((i) => i.pubKey == pubKey);
    if (index > -1) {
      await rootStore.localStorage.removeAccount(pubKey);
      print('removed acc: $pubKey');
    }
    await rootStore.localStorage.addAccount(acc);
    await rootStore.localStorage.setCurrentAccount(pubKey);

    await loadAccount();

    // clear the temp account after addAccount finished
    newAccount = AccountCreate();
  }

  @action
  Future<void> removeAccount(AccountData acc) async {
    await rootStore.localStorage.removeAccount(acc.pubKey);

    // remove encrypted seed after removing account
    deleteSeed(AccountStore.seedTypeMnemonic, acc.pubKey);
    deleteSeed(AccountStore.seedTypeRawSeed, acc.pubKey);

    // set new currentAccount after currentAccount was removed
    List<Map<String, dynamic>> accounts =
        await rootStore.localStorage.getAccountList();
    if (accounts.length > 0) {
      currentAccountPubKey = accounts[0]['pubKey'];
    } else {
      currentAccountPubKey = '';
    }
    await rootStore.localStorage.setCurrentAccount(currentAccountPubKey);

    await loadAccount();
  }

  @action
  Future<void> loadAccount() async {
    List<Map<String, dynamic>> accList =
        await rootStore.localStorage.getAccountList();
    accountList =
        ObservableList.of(accList.map((i) => AccountData.fromJson(i)));

    currentAccountPubKey = await rootStore.localStorage.getCurrentAccount();
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
    Map stored = await rootStore.localStorage.getSeeds(seedType);
    stored[pubKey] = encrypted;
    rootStore.localStorage.setSeeds(seedType, stored);
  }

  @action
  Future<String> decryptSeed(
      String pubKey, String seedType, String password) async {
    Map stored = await rootStore.localStorage.getSeeds(seedType);
    String encrypted = stored[pubKey];
    if (encrypted == null) {
      return null;
    }
    return FlutterAesEcbPkcs5.decryptString(
        encrypted, Fmt.passwordToEncryptKey(password));
  }

  @action
  Future<bool> checkSeedExist(String seedType, String pubKey) async {
    Map stored = await rootStore.localStorage.getSeeds(seedType);
    String encrypted = stored[pubKey];
    return encrypted != null;
  }

  @action
  Future<void> updateSeed(
      String pubKey, String passwordOld, String passwordNew) async {
    Map storedMnemonics =
        await rootStore.localStorage.getSeeds(AccountStore.seedTypeMnemonic);
    Map storedRawSeeds =
        await rootStore.localStorage.getSeeds(AccountStore.seedTypeRawSeed);
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
    Map stored = await rootStore.localStorage.getSeeds(seedType);
    if (stored[pubKey] != null) {
      stored.remove(pubKey);
      rootStore.localStorage.setSeeds(seedType, stored);
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
    final Map<String, Map> data = {};
    list.forEach((i) {
      data[i['accountId']] = i;
    });
    accountIndexMap = data;
  }

  @action
  void setAddressIndex(List list) {
    list.forEach((i) {
      addressIndexMap[i['accountId']] = i;
    });
  }

  @action
  void setAccountRecoveryInfo(Map json) {
    recoveryInfo = json != null
        ? AccountRecoveryInfo.fromJson(json)
        : AccountRecoveryInfo();
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
