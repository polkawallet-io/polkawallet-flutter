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
  String tokenId;
  String value;
  int timestamp;
}
