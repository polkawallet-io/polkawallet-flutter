// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'swapOutputData.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SwapOutputData _$SwapOutputDataFromJson(Map<String, dynamic> json) {
  return SwapOutputData()
    ..path = json['path'] as List
    ..amount = (json['amount'] as num)?.toDouble()
    ..input = json['input'] as String
    ..output = json['output'] as String;
}

Map<String, dynamic> _$SwapOutputDataToJson(SwapOutputData instance) =>
    <String, dynamic>{
      'path': instance.path,
      'amount': instance.amount,
      'input': instance.input,
      'output': instance.output,
    };

LPTokenData _$LPTokenDataFromJson(Map<String, dynamic> json) {
  return LPTokenData()
    ..currencyId =
        (json['currencyId'] as List)?.map((e) => e as String)?.toList()
    ..free = json['free'] as String;
}

Map<String, dynamic> _$LPTokenDataToJson(LPTokenData instance) =>
    <String, dynamic>{
      'currencyId': instance.currencyId,
      'free': instance.free,
    };

AcalaTokenData _$AcalaTokenDataFromJson(Map<String, dynamic> json) {
  return AcalaTokenData()
    ..chain = json['chain'] as String
    ..name = json['name'] as String
    ..symbol = json['symbol'] as String
    ..precision = json['precision'] as int
    ..amount = json['amount'] as String;
}

Map<String, dynamic> _$AcalaTokenDataToJson(AcalaTokenData instance) =>
    <String, dynamic>{
      'chain': instance.chain,
      'name': instance.name,
      'symbol': instance.symbol,
      'precision': instance.precision,
      'amount': instance.amount,
    };
