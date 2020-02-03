import 'package:mobx/mobx.dart';

import 'package:json_annotation/json_annotation.dart';
import 'package:polka_wallet/utils/format.dart';

part 'settings.g.dart';

class SettingsStore = _SettingsStore with _$SettingsStore;

abstract class _SettingsStore with Store {
  _SettingsStore();

  @observable
  String networkName = '';

  @observable
  NetworkState networkState = NetworkState('');

  @observable
  NetworkConst networkConst = NetworkConst();

  @computed
  String get creationFeeView {
    return Fmt.token(networkConst.creationFee, networkState.tokenDecimals);
  }

  @computed
  String get transferFeeView {
    return Fmt.token(networkConst.transferFee, networkState.tokenDecimals);
  }

  @action
  void setNetworkName(String name) {
    networkName = name;
  }

  @action
  Future<void> setNetworkState(Map<String, dynamic> data) async {
    networkState = NetworkState.fromJson(data);
  }

  @action
  Future<void> setNetworkConst(Map<String, dynamic> data) async {
    networkConst = NetworkConst.fromJson(data);
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
