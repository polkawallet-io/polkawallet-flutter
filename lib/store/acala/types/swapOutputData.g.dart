// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'swapOutputData.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SwapOutputData _$SwapOutputDataFromJson(Map<String, dynamic> json) {
  return SwapOutputData()
    ..path = (json['path'] as List)?.map((e) => e as String)?.toList()
    ..amount = (json['amount'] as num)?.toDouble();
}

Map<String, dynamic> _$SwapOutputDataToJson(SwapOutputData instance) =>
    <String, dynamic>{
      'path': instance.path,
      'amount': instance.amount,
    };
