// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'workerApi.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PubKeyPinPair _$PubKeyPinPairFromJson(Map<String, dynamic> json) {
  return PubKeyPinPair(
    json['pubKey'] as String,
    json['pin'] as String,
  );
}

Map<String, dynamic> _$PubKeyPinPairToJson(PubKeyPinPair instance) =>
    <String, dynamic>{
      'pubKey': instance.pubKey,
      'pin': instance.pin,
    };
