import 'package:mobx/mobx.dart';

import 'package:json_annotation/json_annotation.dart';
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
  String networkName = '';

  @observable
  NetworkState networkState = NetworkState();

  @observable
  NetworkConst networkConst = NetworkConst();

  @observable
  ObservableList<ContactData> contactList = ObservableList<ContactData>();

  @computed
  String get creationFeeView {
    return Fmt.token(networkConst.creationFee, networkState.tokenDecimals);
  }

  @computed
  String get transferFeeView {
    return Fmt.token(networkConst.transferFee, networkState.tokenDecimals);
  }

  @action
  void init() {
    loadLocalCode();
    loadEndpoint();
    loadContacts();
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
    networkName = name;
    loading = false;
  }

  @action
  Future<void> setNetworkState(Map<String, dynamic> data) async {
    networkState = NetworkState.fromJson(data);
  }

  @action
  Future<void> setNetworkConst(Map<String, dynamic> data) async {
    networkConst = NetworkConst.fromJson(data);
  }

  @action
  Future<void> loadContacts() async {
    List<Map<String, dynamic>> ls = await LocalStorage.getContractList();
    contactList = ObservableList.of(ls.map((i) => ContactData.fromJson(i)));
  }

  @action
  Future<void> addContact(Map<String, dynamic> con) async {
    await LocalStorage.addContact(con);
    loadContacts();
  }

  @action
  Future<void> removeContact(ContactData con) async {
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
    endpoint = EndpointData.fromJson(value);
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
class NetworkConst extends _NetworkConst with _$NetworkConst {
  static NetworkConst fromJson(Map<String, dynamic> json) =>
      _$NetworkConstFromJson(json);
  static Map<String, dynamic> toJson(NetworkConst net) =>
      _$NetworkConstToJson(net);
}

abstract class _NetworkConst with Store {
  @observable
  int creationFee = 0;

  @observable
  int transferFee = 0;
}

@JsonSerializable()
class ContactData extends _ContactData with _$ContactData {
  static ContactData fromJson(Map<String, dynamic> json) =>
      _$ContactDataFromJson(json);
  static Map<String, dynamic> toJson(ContactData data) =>
      _$ContactDataToJson(data);
}

abstract class _ContactData with Store {
  @observable
  String name = '';

  @observable
  String address = '';

  @observable
  String memo = '';
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
