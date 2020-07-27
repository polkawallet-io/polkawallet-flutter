// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'laminarCurrenciesData.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LaminarTokenData _$LaminarTokenDataFromJson(Map<String, dynamic> json) {
  return LaminarTokenData()
    ..name = json['name'] as String
    ..symbol = json['symbol'] as String
    ..id = json['id'] as String
    ..precision = json['precision'] as int
    ..isBaseToken = json['isBaseToken'] as bool
    ..isNetworkToken = json['isNetworkToken'] as bool;
}

Map<String, dynamic> _$LaminarTokenDataToJson(LaminarTokenData instance) =>
    <String, dynamic>{
      'name': instance.name,
      'symbol': instance.symbol,
      'id': instance.id,
      'precision': instance.precision,
      'isBaseToken': instance.isBaseToken,
      'isNetworkToken': instance.isNetworkToken,
    };

LaminarBalanceData _$LaminarBalanceDataFromJson(Map<String, dynamic> json) {
  return LaminarBalanceData()
    ..tokenId = json['tokenId'] as String
    ..free = json['free'] as String;
}

Map<String, dynamic> _$LaminarBalanceDataToJson(LaminarBalanceData instance) =>
    <String, dynamic>{
      'tokenId': instance.tokenId,
      'free': instance.free,
    };

LaminarPriceData _$LaminarPriceDataFromJson(Map<String, dynamic> json) {
  return LaminarPriceData()
    ..value = json['value'] as String
    ..timestamp = json['timestamp'] as int;
}

Map<String, dynamic> _$LaminarPriceDataToJson(LaminarPriceData instance) =>
    <String, dynamic>{
      'value': instance.value,
      'timestamp': instance.timestamp,
    };

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
    ..additionalCollateralRatio =
        (json['additionalCollateralRatio'] as num)?.toDouble()
    ..syntheticEnabled = json['syntheticEnabled'] as bool;
}

Map<String, dynamic> _$LaminarSyntheticPoolTokenDataToJson(
        LaminarSyntheticPoolTokenData instance) =>
    <String, dynamic>{
      'poolId': instance.poolId,
      'tokenId': instance.tokenId,
      'bidSpread': instance.bidSpread,
      'askSpread': instance.askSpread,
      'additionalCollateralRatio': instance.additionalCollateralRatio,
      'syntheticEnabled': instance.syntheticEnabled,
    };
