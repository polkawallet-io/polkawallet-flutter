// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'config.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Config _$ConfigFromJson(Map<String, dynamic> json) {
  return Config(
    initialRoute: json['initialRoute'] as String,
    mockLocalStorage: json['mockLocalStorage'] as bool,
    mockSubstrateApi: json['mockSubstrateApi'] as bool,
  );
}

Map<String, dynamic> _$ConfigToJson(Config instance) => <String, dynamic>{
      'initialRoute': instance.initialRoute,
      'mockLocalStorage': instance.mockLocalStorage,
      'mockSubstrateApi': instance.mockSubstrateApi,
    };
