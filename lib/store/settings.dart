import 'package:flutter/cupertino.dart';
import 'package:mobx/mobx.dart';

import 'package:json_annotation/json_annotation.dart';
import 'package:polka_wallet/page/profile/settings/remoteNodeListPage.dart';
import 'package:polka_wallet/store/account.dart';
import 'package:polka_wallet/utils/format.dart';
import 'package:polka_wallet/utils/localStorage.dart';

part 'settings.g.dart';

class SettingsStore = _SettingsStore with _$SettingsStore;

abstract class _SettingsStore with Store {
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
  Future<void> init() async {
    await Future.wait([
      loadLocalCode(),
      loadEndpoint(),
      loadCustomSS58Format(),
      loadContacts(),
    ]);
  }

  @action
  Future<void> setLocalCode(String code) async {
    await LocalStorage.setLocale(code);
    loadLocalCode();
  }

  @action
  Future<void> loadLocalCode() async {
    localeCode = await LocalStorage.getLocale();
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
    networkState = NetworkState.fromJson(data);
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
    LocalStorage.setEndpoint(value);
  }

  @action
  Future<void> loadEndpoint() async {
    Map<String, dynamic> value = await LocalStorage.getEndpoint();
    if (value == null) {
      value = Locale.cachedLocaleString.contains('zh')
          ? default_node_zh
          : default_node;
    }
    endpoint = EndpointData.fromJson(value);
  }

  @action
  void setCustomSS58Format(Map<String, dynamic> value) {
    customSS58Format = value;
    LocalStorage.setCustomSS58(value);
  }

  @action
  Future<void> loadCustomSS58Format() async {
    customSS58Format = await LocalStorage.getCustomSS58();
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
