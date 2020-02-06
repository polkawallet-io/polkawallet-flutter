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

NetworkConst _$NetworkConstFromJson(Map<String, dynamic> json) {
  return NetworkConst()
    ..creationFee = json['creationFee'] as int
    ..transferFee = json['transferFee'] as int;
}

Map<String, dynamic> _$NetworkConstToJson(NetworkConst instance) =>
    <String, dynamic>{
      'creationFee': instance.creationFee,
      'transferFee': instance.transferFee,
    };

ContactData _$ContactDataFromJson(Map<String, dynamic> json) {
  return ContactData()
    ..name = json['name'] as String
    ..address = json['address'] as String
    ..memo = json['memo'] as String;
}

Map<String, dynamic> _$ContactDataToJson(ContactData instance) =>
    <String, dynamic>{
      'name': instance.name,
      'address': instance.address,
      'memo': instance.memo,
    };

EndpointData _$EndpointDataFromJson(Map<String, dynamic> json) {
  return EndpointData()
    ..info = json['info'] as String
    ..text = json['text'] as String
    ..value = json['value'] as String;
}

Map<String, dynamic> _$EndpointDataToJson(EndpointData instance) =>
    <String, dynamic>{
      'info': instance.info,
      'text': instance.text,
      'value': instance.value,
    };

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic

mixin _$SettingsStore on _SettingsStore, Store {
  Computed<String> _$creationFeeViewComputed;

  @override
  String get creationFeeView => (_$creationFeeViewComputed ??=
          Computed<String>(() => super.creationFeeView))
      .value;
  Computed<String> _$transferFeeViewComputed;

  @override
  String get transferFeeView => (_$transferFeeViewComputed ??=
          Computed<String>(() => super.transferFeeView))
      .value;

  final _$loadingAtom = Atom(name: '_SettingsStore.loading');

  @override
  bool get loading {
    _$loadingAtom.context.enforceReadPolicy(_$loadingAtom);
    _$loadingAtom.reportObserved();
    return super.loading;
  }

  @override
  set loading(bool value) {
    _$loadingAtom.context.conditionallyRunInAction(() {
      super.loading = value;
      _$loadingAtom.reportChanged();
    }, _$loadingAtom, name: '${_$loadingAtom.name}_set');
  }

  final _$endpointAtom = Atom(name: '_SettingsStore.endpoint');

  @override
  EndpointData get endpoint {
    _$endpointAtom.context.enforceReadPolicy(_$endpointAtom);
    _$endpointAtom.reportObserved();
    return super.endpoint;
  }

  @override
  set endpoint(EndpointData value) {
    _$endpointAtom.context.conditionallyRunInAction(() {
      super.endpoint = value;
      _$endpointAtom.reportChanged();
    }, _$endpointAtom, name: '${_$endpointAtom.name}_set');
  }

  final _$networkNameAtom = Atom(name: '_SettingsStore.networkName');

  @override
  String get networkName {
    _$networkNameAtom.context.enforceReadPolicy(_$networkNameAtom);
    _$networkNameAtom.reportObserved();
    return super.networkName;
  }

  @override
  set networkName(String value) {
    _$networkNameAtom.context.conditionallyRunInAction(() {
      super.networkName = value;
      _$networkNameAtom.reportChanged();
    }, _$networkNameAtom, name: '${_$networkNameAtom.name}_set');
  }

  final _$networkStateAtom = Atom(name: '_SettingsStore.networkState');

  @override
  NetworkState get networkState {
    _$networkStateAtom.context.enforceReadPolicy(_$networkStateAtom);
    _$networkStateAtom.reportObserved();
    return super.networkState;
  }

  @override
  set networkState(NetworkState value) {
    _$networkStateAtom.context.conditionallyRunInAction(() {
      super.networkState = value;
      _$networkStateAtom.reportChanged();
    }, _$networkStateAtom, name: '${_$networkStateAtom.name}_set');
  }

  final _$networkConstAtom = Atom(name: '_SettingsStore.networkConst');

  @override
  NetworkConst get networkConst {
    _$networkConstAtom.context.enforceReadPolicy(_$networkConstAtom);
    _$networkConstAtom.reportObserved();
    return super.networkConst;
  }

  @override
  set networkConst(NetworkConst value) {
    _$networkConstAtom.context.conditionallyRunInAction(() {
      super.networkConst = value;
      _$networkConstAtom.reportChanged();
    }, _$networkConstAtom, name: '${_$networkConstAtom.name}_set');
  }

  final _$contactListAtom = Atom(name: '_SettingsStore.contactList');

  @override
  ObservableList<ContactData> get contactList {
    _$contactListAtom.context.enforceReadPolicy(_$contactListAtom);
    _$contactListAtom.reportObserved();
    return super.contactList;
  }

  @override
  set contactList(ObservableList<ContactData> value) {
    _$contactListAtom.context.conditionallyRunInAction(() {
      super.contactList = value;
      _$contactListAtom.reportChanged();
    }, _$contactListAtom, name: '${_$contactListAtom.name}_set');
  }

  final _$setNetworkStateAsyncAction = AsyncAction('setNetworkState');

  @override
  Future<void> setNetworkState(Map<String, dynamic> data) {
    return _$setNetworkStateAsyncAction.run(() => super.setNetworkState(data));
  }

  final _$setNetworkConstAsyncAction = AsyncAction('setNetworkConst');

  @override
  Future<void> setNetworkConst(Map<String, dynamic> data) {
    return _$setNetworkConstAsyncAction.run(() => super.setNetworkConst(data));
  }

  final _$loadContactsAsyncAction = AsyncAction('loadContacts');

  @override
  Future<void> loadContacts() {
    return _$loadContactsAsyncAction.run(() => super.loadContacts());
  }

  final _$addContactAsyncAction = AsyncAction('addContact');

  @override
  Future<void> addContact(Map<String, dynamic> con) {
    return _$addContactAsyncAction.run(() => super.addContact(con));
  }

  final _$removeContactAsyncAction = AsyncAction('removeContact');

  @override
  Future<void> removeContact(ContactData con) {
    return _$removeContactAsyncAction.run(() => super.removeContact(con));
  }

  final _$updateContactAsyncAction = AsyncAction('updateContact');

  @override
  Future<void> updateContact(Map<String, dynamic> con) {
    return _$updateContactAsyncAction.run(() => super.updateContact(con));
  }

  final _$loadEndpointAsyncAction = AsyncAction('loadEndpoint');

  @override
  Future<void> loadEndpoint() {
    return _$loadEndpointAsyncAction.run(() => super.loadEndpoint());
  }

  final _$_SettingsStoreActionController =
      ActionController(name: '_SettingsStore');

  @override
  void setNetworkName(String name) {
    final _$actionInfo = _$_SettingsStoreActionController.startAction();
    try {
      return super.setNetworkName(name);
    } finally {
      _$_SettingsStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setEndpoint(Map<String, dynamic> value) {
    final _$actionInfo = _$_SettingsStoreActionController.startAction();
    try {
      return super.setEndpoint(value);
    } finally {
      _$_SettingsStoreActionController.endAction(_$actionInfo);
    }
  }
}

mixin _$NetworkState on _NetworkState, Store {
  final _$endpointAtom = Atom(name: '_NetworkState.endpoint');

  @override
  String get endpoint {
    _$endpointAtom.context.enforceReadPolicy(_$endpointAtom);
    _$endpointAtom.reportObserved();
    return super.endpoint;
  }

  @override
  set endpoint(String value) {
    _$endpointAtom.context.conditionallyRunInAction(() {
      super.endpoint = value;
      _$endpointAtom.reportChanged();
    }, _$endpointAtom, name: '${_$endpointAtom.name}_set');
  }

  final _$ss58FormatAtom = Atom(name: '_NetworkState.ss58Format');

  @override
  int get ss58Format {
    _$ss58FormatAtom.context.enforceReadPolicy(_$ss58FormatAtom);
    _$ss58FormatAtom.reportObserved();
    return super.ss58Format;
  }

  @override
  set ss58Format(int value) {
    _$ss58FormatAtom.context.conditionallyRunInAction(() {
      super.ss58Format = value;
      _$ss58FormatAtom.reportChanged();
    }, _$ss58FormatAtom, name: '${_$ss58FormatAtom.name}_set');
  }

  final _$tokenDecimalsAtom = Atom(name: '_NetworkState.tokenDecimals');

  @override
  int get tokenDecimals {
    _$tokenDecimalsAtom.context.enforceReadPolicy(_$tokenDecimalsAtom);
    _$tokenDecimalsAtom.reportObserved();
    return super.tokenDecimals;
  }

  @override
  set tokenDecimals(int value) {
    _$tokenDecimalsAtom.context.conditionallyRunInAction(() {
      super.tokenDecimals = value;
      _$tokenDecimalsAtom.reportChanged();
    }, _$tokenDecimalsAtom, name: '${_$tokenDecimalsAtom.name}_set');
  }

  final _$tokenSymbolAtom = Atom(name: '_NetworkState.tokenSymbol');

  @override
  String get tokenSymbol {
    _$tokenSymbolAtom.context.enforceReadPolicy(_$tokenSymbolAtom);
    _$tokenSymbolAtom.reportObserved();
    return super.tokenSymbol;
  }

  @override
  set tokenSymbol(String value) {
    _$tokenSymbolAtom.context.conditionallyRunInAction(() {
      super.tokenSymbol = value;
      _$tokenSymbolAtom.reportChanged();
    }, _$tokenSymbolAtom, name: '${_$tokenSymbolAtom.name}_set');
  }
}

mixin _$NetworkConst on _NetworkConst, Store {
  final _$creationFeeAtom = Atom(name: '_NetworkConst.creationFee');

  @override
  int get creationFee {
    _$creationFeeAtom.context.enforceReadPolicy(_$creationFeeAtom);
    _$creationFeeAtom.reportObserved();
    return super.creationFee;
  }

  @override
  set creationFee(int value) {
    _$creationFeeAtom.context.conditionallyRunInAction(() {
      super.creationFee = value;
      _$creationFeeAtom.reportChanged();
    }, _$creationFeeAtom, name: '${_$creationFeeAtom.name}_set');
  }

  final _$transferFeeAtom = Atom(name: '_NetworkConst.transferFee');

  @override
  int get transferFee {
    _$transferFeeAtom.context.enforceReadPolicy(_$transferFeeAtom);
    _$transferFeeAtom.reportObserved();
    return super.transferFee;
  }

  @override
  set transferFee(int value) {
    _$transferFeeAtom.context.conditionallyRunInAction(() {
      super.transferFee = value;
      _$transferFeeAtom.reportChanged();
    }, _$transferFeeAtom, name: '${_$transferFeeAtom.name}_set');
  }
}

mixin _$ContactData on _ContactData, Store {
  final _$nameAtom = Atom(name: '_ContactData.name');

  @override
  String get name {
    _$nameAtom.context.enforceReadPolicy(_$nameAtom);
    _$nameAtom.reportObserved();
    return super.name;
  }

  @override
  set name(String value) {
    _$nameAtom.context.conditionallyRunInAction(() {
      super.name = value;
      _$nameAtom.reportChanged();
    }, _$nameAtom, name: '${_$nameAtom.name}_set');
  }

  final _$addressAtom = Atom(name: '_ContactData.address');

  @override
  String get address {
    _$addressAtom.context.enforceReadPolicy(_$addressAtom);
    _$addressAtom.reportObserved();
    return super.address;
  }

  @override
  set address(String value) {
    _$addressAtom.context.conditionallyRunInAction(() {
      super.address = value;
      _$addressAtom.reportChanged();
    }, _$addressAtom, name: '${_$addressAtom.name}_set');
  }

  final _$memoAtom = Atom(name: '_ContactData.memo');

  @override
  String get memo {
    _$memoAtom.context.enforceReadPolicy(_$memoAtom);
    _$memoAtom.reportObserved();
    return super.memo;
  }

  @override
  set memo(String value) {
    _$memoAtom.context.conditionallyRunInAction(() {
      super.memo = value;
      _$memoAtom.reportChanged();
    }, _$memoAtom, name: '${_$memoAtom.name}_set');
  }
}

mixin _$EndpointData on _EndpointData, Store {
  final _$infoAtom = Atom(name: '_EndpointData.info');

  @override
  String get info {
    _$infoAtom.context.enforceReadPolicy(_$infoAtom);
    _$infoAtom.reportObserved();
    return super.info;
  }

  @override
  set info(String value) {
    _$infoAtom.context.conditionallyRunInAction(() {
      super.info = value;
      _$infoAtom.reportChanged();
    }, _$infoAtom, name: '${_$infoAtom.name}_set');
  }

  final _$textAtom = Atom(name: '_EndpointData.text');

  @override
  String get text {
    _$textAtom.context.enforceReadPolicy(_$textAtom);
    _$textAtom.reportObserved();
    return super.text;
  }

  @override
  set text(String value) {
    _$textAtom.context.conditionallyRunInAction(() {
      super.text = value;
      _$textAtom.reportChanged();
    }, _$textAtom, name: '${_$textAtom.name}_set');
  }

  final _$valueAtom = Atom(name: '_EndpointData.value');

  @override
  String get value {
    _$valueAtom.context.enforceReadPolicy(_$valueAtom);
    _$valueAtom.reportObserved();
    return super.value;
  }

  @override
  set value(String value) {
    _$valueAtom.context.conditionallyRunInAction(() {
      super.value = value;
      _$valueAtom.reportChanged();
    }, _$valueAtom, name: '${_$valueAtom.name}_set');
  }
}
