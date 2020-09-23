// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'laminarMarginData.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LaminarMarginPoolInfoData _$LaminarMarginPoolInfoDataFromJson(
    Map<String, dynamic> json) {
  return LaminarMarginPoolInfoData()
    ..poolId = json['poolId'] as String
    ..balance = json['balance'] as String
    ..options = (json['options'] as List)
        ?.map((e) => e == null
            ? null
            : LaminarMarginPairData.fromJson(e as Map<String, dynamic>))
        ?.toList();
}

Map<String, dynamic> _$LaminarMarginPoolInfoDataToJson(
        LaminarMarginPoolInfoData instance) =>
    <String, dynamic>{
      'poolId': instance.poolId,
      'balance': instance.balance,
      'options': instance.options,
    };

LaminarMarginPairData _$LaminarMarginPairDataFromJson(
    Map<String, dynamic> json) {
  return LaminarMarginPairData()
    ..poolId = json['poolId'] as String
    ..pairId = json['pairId'] as String
    ..bidSpread = json['bidSpread']
    ..askSpread = json['askSpread']
    ..enabledTrades =
        (json['enabledTrades'] as List)?.map((e) => e as String)?.toList()
    ..pair = json['pair'] == null
        ? null
        : LaminarMarginPairItemData.fromJson(
            json['pair'] as Map<String, dynamic>);
}

Map<String, dynamic> _$LaminarMarginPairDataToJson(
        LaminarMarginPairData instance) =>
    <String, dynamic>{
      'poolId': instance.poolId,
      'pairId': instance.pairId,
      'bidSpread': instance.bidSpread,
      'askSpread': instance.askSpread,
      'enabledTrades': instance.enabledTrades,
      'pair': instance.pair,
    };

LaminarMarginPairItemData _$LaminarMarginPairItemDataFromJson(
    Map<String, dynamic> json) {
  return LaminarMarginPairItemData()
    ..base = json['base'] as String
    ..quote = json['quote'] as String;
}

Map<String, dynamic> _$LaminarMarginPairItemDataToJson(
        LaminarMarginPairItemData instance) =>
    <String, dynamic>{
      'base': instance.base,
      'quote': instance.quote,
    };

LaminarMarginTraderInfoData _$LaminarMarginTraderInfoDataFromJson(
    Map<String, dynamic> json) {
  return LaminarMarginTraderInfoData()
    ..poolId = json['poolId'] as String
    ..accumulatedSwap = json['accumulatedSwap'] as String
    ..balance = json['balance'] as String
    ..equity = json['equity'] as String
    ..freeMargin = json['freeMargin'] as String
    ..marginHeld = json['marginHeld'] as String
    ..marginLevel = json['marginLevel'] as String
    ..totalLeveragedPosition = json['totalLeveragedPosition'] as String
    ..unrealizedPl = json['unrealizedPl'] as String;
}

Map<String, dynamic> _$LaminarMarginTraderInfoDataToJson(
        LaminarMarginTraderInfoData instance) =>
    <String, dynamic>{
      'poolId': instance.poolId,
      'accumulatedSwap': instance.accumulatedSwap,
      'balance': instance.balance,
      'equity': instance.equity,
      'freeMargin': instance.freeMargin,
      'marginHeld': instance.marginHeld,
      'marginLevel': instance.marginLevel,
      'totalLeveragedPosition': instance.totalLeveragedPosition,
      'unrealizedPl': instance.unrealizedPl,
    };
