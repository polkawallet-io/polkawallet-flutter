// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'laminarSyntheticData.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LaminarSyntheticPoolInfoData _$LaminarSyntheticPoolInfoDataFromJson(
    Map<String, dynamic> json) {
  return LaminarSyntheticPoolInfoData()
    ..poolId = json['poolId'] as String
    ..options = (json['options'] as List)
        ?.map((e) => e == null
            ? null
            : LaminarSyntheticPoolTokenData.fromJson(e as Map<String, dynamic>))
        ?.toList();
}

Map<String, dynamic> _$LaminarSyntheticPoolInfoDataToJson(
        LaminarSyntheticPoolInfoData instance) =>
    <String, dynamic>{
      'poolId': instance.poolId,
      'options': instance.options,
    };

LaminarSyntheticPoolTokenData _$LaminarSyntheticPoolTokenDataFromJson(
    Map<String, dynamic> json) {
  return LaminarSyntheticPoolTokenData()
    ..poolId = json['poolId'] as String
    ..tokenId = json['tokenId'] as String
    ..bidSpread = json['bidSpread']
    ..askSpread = json['askSpread']
    ..additionalCollateralRatio = json['additionalCollateralRatio'] as String;
}

Map<String, dynamic> _$LaminarSyntheticPoolTokenDataToJson(
        LaminarSyntheticPoolTokenData instance) =>
    <String, dynamic>{
      'poolId': instance.poolId,
      'tokenId': instance.tokenId,
      'bidSpread': instance.bidSpread,
      'askSpread': instance.askSpread,
      'additionalCollateralRatio': instance.additionalCollateralRatio,
    };
