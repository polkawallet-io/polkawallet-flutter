// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'node.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

NodeConfig _$NodeConfigFromJson(Map<String, dynamic> json) {
  return NodeConfig(
    json['types'] as Map<String, dynamic>,
    (json['pallets'] as Map<String, dynamic>)?.map(
      (k, e) => MapEntry(k, e == null ? null : Pallet.fromJson(e as Map<String, dynamic>)),
    ),
  );
}

Map<String, dynamic> _$NodeConfigToJson(NodeConfig instance) => <String, dynamic>{
      'types': instance.types,
      'pallets': instance.pallets?.map((k, e) => MapEntry(k, e?.toJson())),
    };

Pallet _$PalletFromJson(Map<String, dynamic> json) {
  return Pallet(
    json['name'] as String,
    (json['calls'] as Map<String, dynamic>)?.map(
      (k, e) => MapEntry(k, e as String),
    ),
  );
}

Map<String, dynamic> _$PalletToJson(Pallet instance) => <String, dynamic>{
      'name': instance.name,
      'calls': instance.calls,
    };
