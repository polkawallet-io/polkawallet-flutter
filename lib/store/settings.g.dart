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
