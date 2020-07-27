import 'package:json_annotation/json_annotation.dart';

part 'laminarCurrenciesData.g.dart';

@JsonSerializable()
class LaminarTokenData extends _LaminarTokenData {
  static LaminarTokenData fromJson(Map<String, dynamic> json) =>
      _$LaminarTokenDataFromJson(json);
  static Map<String, dynamic> toJson(LaminarTokenData info) =>
      _$LaminarTokenDataToJson(info);
}

abstract class _LaminarTokenData {
  String name;
  String symbol;
  String id;
  int precision;
  bool isBaseToken;
  bool isNetworkToken;
}

@JsonSerializable()
class LaminarBalanceData extends _LaminarBalanceData {
  static LaminarBalanceData fromJson(Map<String, dynamic> json) =>
      _$LaminarBalanceDataFromJson(json);
  static Map<String, dynamic> toJson(LaminarBalanceData info) =>
      _$LaminarBalanceDataToJson(info);
}

abstract class _LaminarBalanceData {
  String tokenId;
  String free;
}

@JsonSerializable()
class LaminarPriceData extends _LaminarPriceData {
  static LaminarPriceData fromJson(Map<String, dynamic> json) =>
      _$LaminarPriceDataFromJson(json);
  static Map<String, dynamic> toJson(LaminarPriceData info) =>
      _$LaminarPriceDataToJson(info);
}

abstract class _LaminarPriceData {
  String value;
  int timestamp;
}

@JsonSerializable()
class LaminarSyntheticPoolInfoData extends _LaminarSyntheticPoolInfoData {
  static LaminarSyntheticPoolInfoData fromJson(Map<String, dynamic> json) =>
      _$LaminarSyntheticPoolInfoDataFromJson(json);
  static Map<String, dynamic> toJson(LaminarSyntheticPoolInfoData info) =>
      _$LaminarSyntheticPoolInfoDataToJson(info);
}

abstract class _LaminarSyntheticPoolInfoData {
  String poolId;
  List<LaminarSyntheticPoolTokenData> options;
}

@JsonSerializable()
class LaminarSyntheticPoolTokenData extends _LaminarSyntheticPoolTokenData {
  static LaminarSyntheticPoolTokenData fromJson(Map<String, dynamic> json) =>
      _$LaminarSyntheticPoolTokenDataFromJson(json);
  static Map<String, dynamic> toJson(LaminarSyntheticPoolTokenData info) =>
      _$LaminarSyntheticPoolTokenDataToJson(info);
}

abstract class _LaminarSyntheticPoolTokenData {
  String poolId;
  String tokenId;
  dynamic bidSpread;
  dynamic askSpread;
  double additionalCollateralRatio;
  bool syntheticEnabled;
}
