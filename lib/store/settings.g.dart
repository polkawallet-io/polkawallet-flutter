// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'settings.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

NetworkState _$NetworkStateFromJson(Map<String, dynamic> json) {
  return NetworkState()
    ..endpoint = json['endpoint'] as String
    ..ss58Format = json['ss58Format'] as int
    ..tokenDecimals = json['tokenDecimals'] as int
    ..tokenSymbol = json['tokenSymbol'] as String;
}

Map<String, dynamic> _$NetworkStateToJson(NetworkState instance) =>
    <String, dynamic>{
      'endpoint': instance.endpoint,
      'ss58Format': instance.ss58Format,
      'tokenDecimals': instance.tokenDecimals,
      'tokenSymbol': instance.tokenSymbol,
    };

EndpointData _$EndpointDataFromJson(Map<String, dynamic> json) {
  return EndpointData()
    ..color = json['color'] as String
    ..info = json['info'] as String
    ..ss58 = json['ss58'] as int
    ..text = json['text'] as String
    ..value = json['value'] as String;
}

Map<String, dynamic> _$EndpointDataToJson(EndpointData instance) =>
    <String, dynamic>{
      'color': instance.color,
      'info': instance.info,
      'ss58': instance.ss58,
      'text': instance.text,
      'value': instance.value,
    };

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic

mixin _$SettingsStore on _SettingsStore, Store {
  Computed<List<EndpointData>> _$endpointListComputed;

  @override
  List<EndpointData> get endpointList => (_$endpointListComputed ??=
          Computed<List<EndpointData>>(() => super.endpointList,
              name: '_SettingsStore.endpointList'))
      .value;
  Computed<List<AccountData>> _$contactListAllComputed;

  @override
  List<AccountData> get contactListAll => (_$contactListAllComputed ??=
          Computed<List<AccountData>>(() => super.contactListAll,
              name: '_SettingsStore.contactListAll'))
      .value;
  Computed<String> _$existentialDepositComputed;

  @override
  String get existentialDeposit => (_$existentialDepositComputed ??=
          Computed<String>(() => super.existentialDeposit,
              name: '_SettingsStore.existentialDeposit'))
      .value;
  Computed<String> _$transactionBaseFeeComputed;

  @override
  String get transactionBaseFee => (_$transactionBaseFeeComputed ??=
          Computed<String>(() => super.transactionBaseFee,
              name: '_SettingsStore.transactionBaseFee'))
      .value;
  Computed<String> _$transactionByteFeeComputed;

  @override
  String get transactionByteFee => (_$transactionByteFeeComputed ??=
          Computed<String>(() => super.transactionByteFee,
              name: '_SettingsStore.transactionByteFee'))
      .value;

  final _$loadingAtom = Atom(name: '_SettingsStore.loading');

  @override
  bool get loading {
    _$loadingAtom.reportRead();
    return super.loading;
  }

  @override
  set loading(bool value) {
    _$loadingAtom.reportWrite(value, super.loading, () {
      super.loading = value;
    });
  }

  final _$localeCodeAtom = Atom(name: '_SettingsStore.localeCode');

  @override
  String get localeCode {
    _$localeCodeAtom.reportRead();
    return super.localeCode;
  }

  @override
  set localeCode(String value) {
    _$localeCodeAtom.reportWrite(value, super.localeCode, () {
      super.localeCode = value;
    });
  }

  final _$endpointAtom = Atom(name: '_SettingsStore.endpoint');

  @override
  EndpointData get endpoint {
    _$endpointAtom.reportRead();
    return super.endpoint;
  }

  @override
  set endpoint(EndpointData value) {
    _$endpointAtom.reportWrite(value, super.endpoint, () {
      super.endpoint = value;
    });
  }

  final _$customSS58FormatAtom = Atom(name: '_SettingsStore.customSS58Format');

  @override
  Map<String, dynamic> get customSS58Format {
    _$customSS58FormatAtom.reportRead();
    return super.customSS58Format;
  }

  @override
  set customSS58Format(Map<String, dynamic> value) {
    _$customSS58FormatAtom.reportWrite(value, super.customSS58Format, () {
      super.customSS58Format = value;
    });
  }

  final _$networkNameAtom = Atom(name: '_SettingsStore.networkName');

  @override
  String get networkName {
    _$networkNameAtom.reportRead();
    return super.networkName;
  }

  @override
  set networkName(String value) {
    _$networkNameAtom.reportWrite(value, super.networkName, () {
      super.networkName = value;
    });
  }

  final _$networkStateAtom = Atom(name: '_SettingsStore.networkState');

  @override
  NetworkState get networkState {
    _$networkStateAtom.reportRead();
    return super.networkState;
  }

  @override
  set networkState(NetworkState value) {
    _$networkStateAtom.reportWrite(value, super.networkState, () {
      super.networkState = value;
    });
  }

  final _$networkConstAtom = Atom(name: '_SettingsStore.networkConst');

  @override
  Map<dynamic, dynamic> get networkConst {
    _$networkConstAtom.reportRead();
    return super.networkConst;
  }

  @override
  set networkConst(Map<dynamic, dynamic> value) {
    _$networkConstAtom.reportWrite(value, super.networkConst, () {
      super.networkConst = value;
    });
  }

  final _$contactListAtom = Atom(name: '_SettingsStore.contactList');

  @override
  ObservableList<AccountData> get contactList {
    _$contactListAtom.reportRead();
    return super.contactList;
  }

  @override
  set contactList(ObservableList<AccountData> value) {
    _$contactListAtom.reportWrite(value, super.contactList, () {
      super.contactList = value;
    });
  }

  final _$initAsyncAction = AsyncAction('_SettingsStore.init');

  @override
  Future<void> init(String sysLocaleCode) {
    return _$initAsyncAction.run(() => super.init(sysLocaleCode));
  }

  final _$setLocalCodeAsyncAction = AsyncAction('_SettingsStore.setLocalCode');

  @override
  Future<void> setLocalCode(String code) {
    return _$setLocalCodeAsyncAction.run(() => super.setLocalCode(code));
  }

  final _$loadLocalCodeAsyncAction =
      AsyncAction('_SettingsStore.loadLocalCode');

  @override
  Future<void> loadLocalCode() {
    return _$loadLocalCodeAsyncAction.run(() => super.loadLocalCode());
  }

  final _$setNetworkStateAsyncAction =
      AsyncAction('_SettingsStore.setNetworkState');

  @override
  Future<void> setNetworkState(Map<String, dynamic> data,
      {bool needCache = true}) {
    return _$setNetworkStateAsyncAction
        .run(() => super.setNetworkState(data, needCache: needCache));
  }

  final _$loadNetworkStateCacheAsyncAction =
      AsyncAction('_SettingsStore.loadNetworkStateCache');

  @override
  Future<void> loadNetworkStateCache() {
    return _$loadNetworkStateCacheAsyncAction
        .run(() => super.loadNetworkStateCache());
  }

  final _$setNetworkConstAsyncAction =
      AsyncAction('_SettingsStore.setNetworkConst');

  @override
  Future<void> setNetworkConst(Map<String, dynamic> data,
      {bool needCache = true}) {
    return _$setNetworkConstAsyncAction
        .run(() => super.setNetworkConst(data, needCache: needCache));
  }

  final _$loadContactsAsyncAction = AsyncAction('_SettingsStore.loadContacts');

  @override
  Future<void> loadContacts() {
    return _$loadContactsAsyncAction.run(() => super.loadContacts());
  }

  final _$addContactAsyncAction = AsyncAction('_SettingsStore.addContact');

  @override
  Future<void> addContact(Map<String, dynamic> con) {
    return _$addContactAsyncAction.run(() => super.addContact(con));
  }

  final _$removeContactAsyncAction =
      AsyncAction('_SettingsStore.removeContact');

  @override
  Future<void> removeContact(AccountData con) {
    return _$removeContactAsyncAction.run(() => super.removeContact(con));
  }

  final _$updateContactAsyncAction =
      AsyncAction('_SettingsStore.updateContact');

  @override
  Future<void> updateContact(Map<String, dynamic> con) {
    return _$updateContactAsyncAction.run(() => super.updateContact(con));
  }

  final _$loadEndpointAsyncAction = AsyncAction('_SettingsStore.loadEndpoint');

  @override
  Future<void> loadEndpoint(String sysLocaleCode) {
    return _$loadEndpointAsyncAction
        .run(() => super.loadEndpoint(sysLocaleCode));
  }

  final _$loadCustomSS58FormatAsyncAction =
      AsyncAction('_SettingsStore.loadCustomSS58Format');

  @override
  Future<void> loadCustomSS58Format() {
    return _$loadCustomSS58FormatAsyncAction
        .run(() => super.loadCustomSS58Format());
  }

  final _$_SettingsStoreActionController =
      ActionController(name: '_SettingsStore');

  @override
  void setNetworkLoading(bool isLoading) {
    final _$actionInfo = _$_SettingsStoreActionController.startAction(
        name: '_SettingsStore.setNetworkLoading');
    try {
      return super.setNetworkLoading(isLoading);
    } finally {
      _$_SettingsStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setNetworkName(String name) {
    final _$actionInfo = _$_SettingsStoreActionController.startAction(
        name: '_SettingsStore.setNetworkName');
    try {
      return super.setNetworkName(name);
    } finally {
      _$_SettingsStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setEndpoint(EndpointData value) {
    final _$actionInfo = _$_SettingsStoreActionController.startAction(
        name: '_SettingsStore.setEndpoint');
    try {
      return super.setEndpoint(value);
    } finally {
      _$_SettingsStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setCustomSS58Format(Map<String, dynamic> value) {
    final _$actionInfo = _$_SettingsStoreActionController.startAction(
        name: '_SettingsStore.setCustomSS58Format');
    try {
      return super.setCustomSS58Format(value);
    } finally {
      _$_SettingsStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
loading: ${loading},
localeCode: ${localeCode},
endpoint: ${endpoint},
customSS58Format: ${customSS58Format},
networkName: ${networkName},
networkState: ${networkState},
networkConst: ${networkConst},
contactList: ${contactList},
endpointList: ${endpointList},
contactListAll: ${contactListAll},
existentialDeposit: ${existentialDeposit},
transactionBaseFee: ${transactionBaseFee},
transactionByteFee: ${transactionByteFee}
    ''';
  }
}
