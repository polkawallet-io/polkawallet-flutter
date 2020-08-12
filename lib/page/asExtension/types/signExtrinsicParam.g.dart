// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'signExtrinsicParam.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SignExtrinsicParam _$SignExtrinsicParamFromJson(Map<String, dynamic> json) {
  return SignExtrinsicParam()
    ..address = json['address'] as String
    ..blockHash = json['blockHash'] as String
    ..blockNumber = json['blockNumber'] as String
    ..era = json['era'] as String
    ..genesisHash = json['genesisHash'] as String
    ..method = json['method'] as String
    ..nonce = json['nonce'] as String
    ..signedExtensions =
        (json['signedExtensions'] as List)?.map((e) => e as String)?.toList()
    ..specVersion = json['specVersion'] as String
    ..tip = json['tip'] as String
    ..transactionVersion = json['transactionVersion'] as String
    ..version = json['version'] as int;
}

Map<String, dynamic> _$SignExtrinsicParamToJson(SignExtrinsicParam instance) =>
    <String, dynamic>{
      'address': instance.address,
      'blockHash': instance.blockHash,
      'blockNumber': instance.blockNumber,
      'era': instance.era,
      'genesisHash': instance.genesisHash,
      'method': instance.method,
      'nonce': instance.nonce,
      'signedExtensions': instance.signedExtensions,
      'specVersion': instance.specVersion,
      'tip': instance.tip,
      'transactionVersion': instance.transactionVersion,
      'version': instance.version,
    };

SignBytesParam _$SignBytesParamFromJson(Map<String, dynamic> json) {
  return SignBytesParam()
    ..address = json['address'] as String
    ..data = json['data'] as String
    ..type = json['type'] as String;
}

Map<String, dynamic> _$SignBytesParamToJson(SignBytesParam instance) =>
    <String, dynamic>{
      'address': instance.address,
      'data': instance.data,
      'type': instance.type,
    };
