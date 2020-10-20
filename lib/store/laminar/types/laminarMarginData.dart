import 'package:json_annotation/json_annotation.dart';

part 'laminarMarginData.g.dart';

@JsonSerializable()
class LaminarMarginPoolInfoData extends _LaminarMarginPoolInfoData {
  static LaminarMarginPoolInfoData fromJson(Map<String, dynamic> json) =>
      _$LaminarMarginPoolInfoDataFromJson(json);
  Map<String, dynamic> toJson() => _$LaminarMarginPoolInfoDataToJson(this);
}

abstract class _LaminarMarginPoolInfoData {
  String poolId;
  String balance;
  List<LaminarMarginPairData> options;
}

@JsonSerializable()
class LaminarMarginPairData extends _LaminarMarginPoolPairData {
  static LaminarMarginPairData fromJson(Map<String, dynamic> json) =>
      _$LaminarMarginPairDataFromJson(json);
  Map<String, dynamic> toJson() => _$LaminarMarginPairDataToJson(this);
}

abstract class _LaminarMarginPoolPairData {
  String poolId;
  String pairId;
  dynamic bidSpread;
  dynamic askSpread;
  List<String> enabledTrades;
  LaminarMarginPairItemData pair;
}

@JsonSerializable()
class LaminarMarginPairItemData extends _LaminarMarginPairItemData {
  static LaminarMarginPairItemData fromJson(Map<String, dynamic> json) =>
      _$LaminarMarginPairItemDataFromJson(json);
  Map<String, dynamic> toJson() => _$LaminarMarginPairItemDataToJson(this);
}

abstract class _LaminarMarginPairItemData {
  String base;
  String quote;
}

@JsonSerializable()
class LaminarMarginTraderInfoData extends _LaminarMarginTraderInfoData {
  static LaminarMarginTraderInfoData fromJson(Map<String, dynamic> json) =>
      _$LaminarMarginTraderInfoDataFromJson(json);
  Map<String, dynamic> toJson() => _$LaminarMarginTraderInfoDataToJson(this);
}

abstract class _LaminarMarginTraderInfoData {
  String poolId;
  String accumulatedSwap;
  String balance;
  String equity;
  String freeMargin;
  String marginHeld;
  String marginLevel;
  String totalLeveragedPosition;
  String unrealizedPl;
}
