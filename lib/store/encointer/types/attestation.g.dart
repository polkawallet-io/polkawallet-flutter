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
    json['signature'] as Map<String, dynamic>,
    json['public'] as String,
  );
}

Map<String, dynamic> _$AttestationToJson(Attestation instance) =>
    <String, dynamic>{
      'claim': instance.claim?.toJson(),
      'signature': instance.signature,
      'public': instance.public,
    };
