// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'proofOfAttendance.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ProofOfAttendance _$ProofOfAttendanceFromJson(Map<String, dynamic> json) {
  return ProofOfAttendance(
    json['prover_public'] as String,
    json['ceremony_index'] as int,
    json['community_identifier'] as String,
    json['attendee_public'] as String,
    (json['attendee_signature'] as Map<String, dynamic>)?.map(
      (k, e) => MapEntry(k, e as String),
    ),
  );
}

Map<String, dynamic> _$ProofOfAttendanceToJson(ProofOfAttendance instance) => <String, dynamic>{
      'prover_public': instance.proverPublic,
      'ceremony_index': instance.ceremonyIndex,
      'community_identifier': instance.communityIdentifier,
      'attendee_public': instance.attendeePublic,
      'attendee_signature': instance.attendeeSignature,
    };
