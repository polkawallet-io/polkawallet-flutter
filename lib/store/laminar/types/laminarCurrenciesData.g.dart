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
    ..tokenId = json['tokenId'] as String
    ..value = json['value'] as String
    ..timestamp = json['timestamp'] as int;
}

Map<String, dynamic> _$LaminarPriceDataToJson(LaminarPriceData instance) =>
    <String, dynamic>{
      'tokenId': instance.tokenId,
      'value': instance.value,
      'timestamp': instance.timestamp,
    };
