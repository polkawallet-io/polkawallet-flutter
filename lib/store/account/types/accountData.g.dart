// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'accountData.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AccountData _$AccountDataFromJson(Map<String, dynamic> json) {
  return AccountData()
    ..name = json['name'] as String
    ..address = json['address'] as String
    ..encoded = json['encoded'] as String
    ..pubKey = json['pubKey'] as String
    ..encoding = json['encoding'] as Map<String, dynamic>
    ..meta = json['meta'] as Map<String, dynamic>
    ..memo = json['memo'] as String
    ..observation = json['observation'] as bool;
}

Map<String, dynamic> _$AccountDataToJson(AccountData instance) =>
    <String, dynamic>{
      'name': instance.name,
      'address': instance.address,
      'encoded': instance.encoded,
      'pubKey': instance.pubKey,
      'encoding': instance.encoding,
      'meta': instance.meta,
      'memo': instance.memo,
      'observation': instance.observation,
    };
