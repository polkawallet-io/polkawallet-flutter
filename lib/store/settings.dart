import 'package:encointer_wallet/config/consts.dart';
import 'package:encointer_wallet/config/node.dart';
import 'package:encointer_wallet/page/profile/settings/ss58PrefixListPage.dart';
import 'package:encointer_wallet/service/substrateApi/api.dart';
import 'package:encointer_wallet/store/account/types/accountData.dart';
import 'package:encointer_wallet/store/app.dart';
import 'package:encointer_wallet/utils/format.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:mobx/mobx.dart';

part 'settings.g.dart';

class SettingsStore extends _SettingsStore with _$SettingsStore {
  SettingsStore(AppStore store) : super(store);
}

abstract class _SettingsStore with Store {
  _SettingsStore(this.rootStore);

  final AppStore rootStore;

  final String localStorageLocaleKey = 'locale';
  final String localStorageEndpointKey = 'endpoint';
  final String localStorageSS58Key = 'custom_ss58';

  final String cacheNetworkStateKey = 'network';
  final String cacheNetworkConstKey = 'network_const';

  String _getCacheKeyOfNetwork(String key) {
    return '${endpoint.info}_$key';
  }

  @observable
  String cachedPin = '';

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
  NetworkState networkState;

  @observable
  Map networkConst = Map();

  @observable
  ObservableList<AccountData> contactList = ObservableList<AccountData>();

  @computed
  bool get endpointIsEncointer {
    return endpoint.info == networkEndpointEncointerGesell.info ||
        endpoint.info == networkEndpointEncointerGesellDev.info ||
        endpoint.info == networkEndpointEncointerCantillon.info ||
        endpoint.info == networkEndpointEncointerCantillonDev.info;
  }

  @computed
  bool get endpointIsGesell {
    return endpoint.info == networkEndpointEncointerGesell.info ||
        endpoint.info == networkEndpointEncointerGesellDev.info;
  }

  @computed
  bool get endpointIsCantillon {
    return !endpointIsGesell;
  }

  @computed
  String get ipfsGateway => endpoint?.ipfsGateway;

  @computed
  List<EndpointData> get endpointList {
    List<EndpointData> ls = List<EndpointData>.of(networkEndpoints);
    ls.retainWhere((i) => i.info == endpoint.info);
    return ls;
  }

  @computed
  List<AccountData> get contactListAll {
    List<AccountData> ls = List<AccountData>.of(rootStore.account.accountList);
    ls.addAll(contactList);
    return ls;
  }

  @computed
  String get existentialDeposit {
    return Fmt.token(
        BigInt.parse(networkConst['balances']['existentialDeposit'].toString()), networkState.tokenDecimals);
  }

  @computed
  String get transactionBaseFee {
    return Fmt.token(
        BigInt.parse(networkConst['transactionPayment']['transactionBaseFee'].toString()), networkState.tokenDecimals);
  }

  @computed
  String get transactionByteFee {
    return Fmt.token(
        BigInt.parse(networkConst['transactionPayment']['transactionByteFee'].toString()), networkState.tokenDecimals,
        length: networkState.tokenDecimals);
  }

  @action
  Future<void> init(String sysLocaleCode) async {
    await loadLocalCode();
    await loadEndpoint(sysLocaleCode);
    await Future.wait([
      loadCustomSS58Format(),
      loadNetworkStateCache(),
      loadContacts(),
    ]);
  }

  @action
  Future<void> setLocalCode(String code) async {
    await rootStore.localStorage.setObject(localStorageLocaleKey, code);
    localeCode = code;
  }

  @action
  Future<void> loadLocalCode() async {
    String stored = await rootStore.localStorage.getObject(localStorageLocaleKey);
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
    networkName = name;
    loading = false;
  }

  @action
  void setPin(String pin) {
    cachedPin = pin;
    if (pin.isNotEmpty) {
      rootStore.encointer.updateState();
      webApi.encointer.getEncointerBalance();
    }
  }

  @computed
  bool get isConnected {
    return !loading && networkName.isNotEmpty;
  }

  @action
  Future<void> setNetworkState(
    Map<String, dynamic> data, {
    bool needCache = true,
  }) async {
    networkState = NetworkState.fromJson(data);

    if (needCache) {
      rootStore.localStorage.setObject(
        _getCacheKeyOfNetwork(cacheNetworkStateKey),
        data,
      );
    }
  }

  @action
  Future<void> loadNetworkStateCache() async {
    final List data = await Future.wait([
      rootStore.localStorage.getObject(_getCacheKeyOfNetwork(cacheNetworkStateKey)),
      rootStore.localStorage.getObject(_getCacheKeyOfNetwork(cacheNetworkConstKey)),
    ]);
    if (data[0] != null) {
      setNetworkState(Map<String, dynamic>.of(data[0]), needCache: false);
    } else {
      setNetworkState({}, needCache: false);
    }

    if (data[1] != null) {
      setNetworkConst(Map<String, dynamic>.of(data[1]), needCache: false);
    } else {
      setNetworkConst({}, needCache: false);
    }
  }

  @action
  Future<void> setNetworkConst(
    Map<String, dynamic> data, {
    bool needCache = true,
  }) async {
    networkConst = data;

    if (needCache) {
      rootStore.localStorage.setObject(
        _getCacheKeyOfNetwork(cacheNetworkConstKey),
        data,
      );
    }
  }

  @action
  Future<void> loadContacts() async {
    List<Map<String, dynamic>> ls = await rootStore.localStorage.getContactList();
    contactList = ObservableList.of(ls.map((i) => AccountData.fromJson(i)));
  }

  @action
  Future<void> addContact(Map<String, dynamic> con) async {
    await rootStore.localStorage.addContact(con);
    await loadContacts();
  }

  @action
  Future<void> removeContact(AccountData con) async {
    await rootStore.localStorage.removeContact(con.address);
    loadContacts();
  }

  @action
  Future<void> updateContact(Map<String, dynamic> con) async {
    await rootStore.localStorage.updateContact(con);
    loadContacts();
  }

  @action
  void setEndpoint(EndpointData value) {
    endpoint = value;
    rootStore.localStorage.setObject(localStorageEndpointKey, EndpointData.toJson(value));
  }

  @action
  Future<void> loadEndpoint(String sysLocaleCode) async {
    Map<String, dynamic> value = await rootStore.localStorage.getObject(localStorageEndpointKey);
    if (value == null) {
      endpoint = networkEndpointEncointerGesell;
    } else {
      endpoint = EndpointData.fromJson(value);
    }
  }

  @action
  void setCustomSS58Format(Map<String, dynamic> value) {
    customSS58Format = value;
    rootStore.localStorage.setObject(localStorageSS58Key, value);
  }

  @action
  Future<void> loadCustomSS58Format() async {
    Map<String, dynamic> ss58 = await rootStore.localStorage.getObject(localStorageSS58Key);

    customSS58Format = ss58 ?? default_ss58_prefix;
  }

  String getCacheKey(String key) {
    return '${endpoint.info}_$key';
  }
}

@JsonSerializable(createFactory: false)
class NetworkState extends _NetworkState {
  NetworkState(String endpoint, int ss58Format, int tokenDecimals, String tokenSymbol)
      : super(endpoint, ss58Format, tokenDecimals, tokenSymbol);

  static NetworkState fromJson(Map<String, dynamic> json) {
    // js-api changed the return type of 'api.rpc.system.properties()', such that multiple balances are supported.
    // Hence, tokenDecimals/-symbols are returned as a List. However, encointer currently only has one token, thus the
    // `NetworkState` should use the first token.
    int decimals = (json['tokenDecimals'] is List) ? json['tokenDecimals'][0] : json['tokenDecimals'];
    String symbol = (json['tokenSymbol'] is List) ? json['tokenSymbol'][0] : json['tokenSymbol'];

    NetworkState ns = NetworkState(json['endpoint'], json['ss58Format'], decimals, symbol);
    // --dev chain doesn't specify token symbol -> will break things if not specified
    if (ns.tokenSymbol == null || (ns.tokenSymbol.length < 1)) {
      ns.tokenSymbol = 'ERT';
    }
    return ns;
  }

  static Map<String, dynamic> toJson(NetworkState net) => _$NetworkStateToJson(net);
}

// TODO: these were empty before, but had to add defaults for development chain
abstract class _NetworkState {
  _NetworkState(this.endpoint, this.ss58Format, this.tokenDecimals, this.tokenSymbol);

  String endpoint = '';
  int ss58Format = 42;
  int tokenDecimals = 12;
  String tokenSymbol = 'ERT';
}

@JsonSerializable(explicitToJson: true)
class EndpointData extends _EndpointData {
  static EndpointData fromJson(Map<String, dynamic> json) => _$EndpointDataFromJson(json);
  static Map<String, dynamic> toJson(EndpointData data) => _$EndpointDataToJson(data);
}

abstract class _EndpointData {
  String color = 'pink';
  String info = '';
  int ss58 = 42;
  String text = '';
  String value = '';
  String worker = ''; // only relevant for cantillon
  String mrenclave = ''; // relevant until we fetch mrenclave from substrateeRegistry
  NodeConfig overrideConfig;
  String ipfsGateway = '';
}
