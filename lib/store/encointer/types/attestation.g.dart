// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'attestation.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Attestation _$AttestationFromJson(Map<String, dynamic> json) {
  return Attestation(
    json['claim'] == null
        ? null
        : ClaimOfAttendance.fromJson(json['claim'] as Map<String, dynamic>),
    (json['signature'] as Map<String, dynamic>)?.map(
      (k, e) => MapEntry(k, e as String),
    ),
    json['public'] as String,
  );
}

Map<String, dynamic> _$AttestationToJson(Attestation instance) =>
    <String, dynamic>{
      'claim': instance.claim?.toJson(),
      'signature': instance.signature,
      'public': instance.public,
    };

AttestationResult _$AttestationResultFromJson(Map<String, dynamic> json) {
  return AttestationResult(
    json['attestation'] == null
        ? null
        : Attestation.fromJson(json['attestation'] as Map<String, dynamic>),
    json['attestation_hex'] as String,
  );
}

Map<String, dynamic> _$AttestationResultToJson(AttestationResult instance) =>
    <String, dynamic>{
      'attestation': instance.attestation?.toJson(),
      'attestation_hex': instance.attestationHex,
    };
