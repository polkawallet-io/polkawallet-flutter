// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'genExternalLinksParams.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GenExternalLinksParams _$GenExternalLinksParamsFromJson(
    Map<String, dynamic> json) {
  return GenExternalLinksParams()
    ..data = json['data'] as String
    ..hash = json['hash'] as String
    ..type = json['type'] as String
    ..withShort = json['withShort'] as bool;
}

Map<String, dynamic> _$GenExternalLinksParamsToJson(
        GenExternalLinksParams instance) =>
    <String, dynamic>{
      'data': instance.data,
      'hash': instance.hash,
      'type': instance.type,
      'withShort': instance.withShort,
    };
