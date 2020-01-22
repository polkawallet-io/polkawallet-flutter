// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'settings.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

NetworkState _$NetworkStateFromJson(Map<String, dynamic> json) {
  return NetworkState(
    json['endpoint'] as String,
  )
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

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic

mixin _$SettingsStore on _SettingsStore, Store {
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

  final _$setNetworkStateAsyncAction = AsyncAction('setNetworkState');

  @override
  Future<void> setNetworkState(Map<String, dynamic> data) {
    return _$setNetworkStateAsyncAction.run(() => super.setNetworkState(data));
  }

  final _$setNetworkNameAsyncAction = AsyncAction('setNetworkName');

  @override
  Future<void> setNetworkName(String name) {
    return _$setNetworkNameAsyncAction.run(() => super.setNetworkName(name));
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
