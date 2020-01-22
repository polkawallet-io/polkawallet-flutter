import 'package:mobx/mobx.dart';

import 'package:json_annotation/json_annotation.dart';

part 'settings.g.dart';

class SettingsStore = _SettingsStore with _$SettingsStore;

abstract class _SettingsStore with Store {
  _SettingsStore();

  @observable
  String networkName = '';

  @observable
  NetworkState networkState = NetworkState('');

  @action
  Future<void> setNetworkState(Map<String, dynamic> data) async {
    networkState = NetworkState.fromJson(data);
  }

  @action
  Future<void> setNetworkName(String name) async {
    networkName = name;
  }
}

@JsonSerializable()
class NetworkState extends _NetworkState with _$NetworkState {
  NetworkState(String endpoint) : super(endpoint);

  static NetworkState fromJson(Map<String, dynamic> json) =>
      _$NetworkStateFromJson(json);
  static Map<String, dynamic> toJson(NetworkState net) =>
      _$NetworkStateToJson(net);
}

abstract class _NetworkState with Store {
  _NetworkState(this.endpoint);

  @observable
  String endpoint = '';

  @observable
  int ss58Format = 0;

  @observable
  int tokenDecimals = 0;

  @observable
  String tokenSymbol = '';
}
