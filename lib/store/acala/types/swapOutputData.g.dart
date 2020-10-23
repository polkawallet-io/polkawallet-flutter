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
