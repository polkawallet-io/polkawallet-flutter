import 'package:mobx/mobx.dart';

import 'package:json_annotation/json_annotation.dart';
import 'package:polka_wallet/page/profile/settings/remoteNodeListPage.dart';
import 'package:polka_wallet/page/profile/settings/ss58PrefixListPage.dart';
import 'package:polka_wallet/store/account.dart';
import 'package:polka_wallet/utils/format.dart';
import 'package:polka_wallet/utils/localStorage.dart';

part 'settings.g.dart';

class SettingsStore = _SettingsStore with _$SettingsStore;

abstract class _SettingsStore with Store {
  final String localStorageLocaleKey = 'locale';
  final String localStorageEndpointKey = 'endpoint';
  final String localStorageSS58Key = 'custom_ss58';

  final String cacheNetworkStateKey = 'network';

  @observable
  bool loading = true;

  @observable
  String localeCode = '';

  @observable
  EndpointData endpoint = EndpointData();

  @observable
  Map<String, dynamic> customSS58Format = Map<String, dynamic>();

  @observable
  String networkName = '';

  @observable
  NetworkState networkState = NetworkState();

  @observable
  Map networkConst = Map();

  @observable
  ObservableList<AccountData> contactList = ObservableList<AccountData>();

  @computed
  String get existentialDeposit {
    return Fmt.token(networkConst['balances']['existentialDeposit'],
        decimals: networkState.tokenDecimals);
  }

  @computed
  String get transactionBaseFee {
    return Fmt.token(networkConst['transactionPayment']['transactionBaseFee'],
        decimals: networkState.tokenDecimals);
  }

  @computed
  String get transactionByteFee {
    return Fmt.token(networkConst['transactionPayment']['transactionByteFee'],
        decimals: networkState.tokenDecimals, fullLength: true);
  }

  @action
  Future<void> init(String sysLocaleCode) async {
    await loadLocalCode();
    await Future.wait([
      loadEndpoint(sysLocaleCode),
      loadCustomSS58Format(),
      loadNetworkStateCache(),
      loadContacts(),
    ]);
  }

  @action
  Future<void> setLocalCode(String code) async {
    await LocalStorage.setKV(localStorageLocaleKey, code);
    loadLocalCode();
  }

  @action
  Future<void> loadLocalCode() async {
    String stored = await LocalStorage.getKV(localStorageLocaleKey);
    if (stored != null) {
      localeCode = stored;
    }
  }

  @action
  void setNetworkLoading(bool isLoading) {
    loading = isLoading;
  }

  @action
  void setNetworkName(String name) {
    print('set netwwork name: $name');
    networkName = name;
    loading = false;
  }

  @action
  Future<void> setNetworkState(Map<String, dynamic> data) async {
    LocalStorage.setKV(cacheNetworkStateKey, data);

    networkState = NetworkState.fromJson(data);
  }

  @action
  Future<void> loadNetworkStateCache() async {
    var data = await LocalStorage.getKV(cacheNetworkStateKey);
    if (data != null) {
      networkState = NetworkState.fromJson(data);
    }
  }

  @action
  Future<void> setNetworkConst(Map<String, dynamic> data) async {
    networkConst = data;
  }

  @action
  Future<void> loadContacts() async {
    List<Map<String, dynamic>> ls = await LocalStorage.getContractList();
    contactList = ObservableList.of(ls.map((i) => AccountData.fromJson(i)));
  }

  @action
  Future<void> addContact(Map<String, dynamic> con) async {
    await LocalStorage.addContact(con);
    loadContacts();
  }

  @action
  Future<void> removeContact(AccountData con) async {
    await LocalStorage.removeContact(con.address);
    loadContacts();
  }

  @action
  Future<void> updateContact(Map<String, dynamic> con) async {
    await LocalStorage.updateContact(con);
    loadContacts();
  }

  @action
  void setEndpoint(Map<String, dynamic> value) {
    endpoint = EndpointData.fromJson(value);
    LocalStorage.setKV(localStorageEndpointKey, value);
  }

  @action
  Future<void> loadEndpoint(String sysLocaleCode) async {
    Map<String, dynamic> value =
        await LocalStorage.getKV(localStorageEndpointKey);
    if (value == null) {
      value = sysLocaleCode.contains('zh') ? default_node_zh : default_node;
    }
    endpoint = EndpointData.fromJson(value);
  }

  @action
  void setCustomSS58Format(Map<String, dynamic> value) {
    customSS58Format = value;
    LocalStorage.setKV(localStorageSS58Key, value);
  }

  @action
  Future<void> loadCustomSS58Format() async {
    Map<String, dynamic> ss58 = await LocalStorage.getKV(localStorageSS58Key);

    customSS58Format = ss58 ?? default_ss58_prefix;
  }
}

@JsonSerializable()
class NetworkState extends _NetworkState with _$NetworkState {
  static NetworkState fromJson(Map<String, dynamic> json) =>
      _$NetworkStateFromJson(json);
  static Map<String, dynamic> toJson(NetworkState net) =>
      _$NetworkStateToJson(net);
}

abstract class _NetworkState with Store {
  @observable
  String endpoint = '';

  @observable
  int ss58Format = 0;

  @observable
  int tokenDecimals = 0;

  @observable
  String tokenSymbol = '';
}

@JsonSerializable()
class EndpointData extends _EndpointData with _$EndpointData {
  static EndpointData fromJson(Map<String, dynamic> json) =>
      _$EndpointDataFromJson(json);
  static Map<String, dynamic> toJson(EndpointData data) =>
      _$EndpointDataToJson(data);
}

abstract class _EndpointData with Store {
  @observable
  String info = '';

  @observable
  String text = '';

  @observable
  String value = '';
}
