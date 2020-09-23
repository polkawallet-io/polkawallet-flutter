import 'package:json_annotation/json_annotation.dart';

part 'laminarSyntheticData.g.dart';

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
  String additionalCollateralRatio;
}
