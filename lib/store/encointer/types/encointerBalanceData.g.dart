// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'encointerBalanceData.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

EncointerBalanceData _$EncointerBalanceDataFromJson(Map<String, dynamic> json) {
  return EncointerBalanceData(
    json['cid'] as String,
    json['balance_entry'] == null
        ? null
        : BalanceEntry.fromJson(json['balance_entry'] as Map<String, dynamic>),
  );
}

Map<String, dynamic> _$EncointerBalanceDataToJson(
        EncointerBalanceData instance) =>
    <String, dynamic>{
      'cid': instance.cid,
      'balance_entry': instance.balanceEntry?.toJson(),
    };

BalanceEntry _$BalanceEntryFromJson(Map<String, dynamic> json) {
  return BalanceEntry(
    json['principal'] as num,
    json['last_update'] as int,
  );
}

Map<String, dynamic> _$BalanceEntryToJson(BalanceEntry instance) =>
    <String, dynamic>{
      'principal': instance.principal,
      'last_update': instance.lastUpdate,
    };
