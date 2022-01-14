// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'claimOfAttendance.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ClaimOfAttendance _$ClaimOfAttendanceFromJson(Map<String, dynamic> json) {
  return ClaimOfAttendance(
    json['claimantPublic'] as String,
    json['ceremonyIndex'] as int,
    json['communityIdentifier'] == null
        ? null
        : CommunityIdentifier.fromJson(json['communityIdentifier'] as Map<String, dynamic>),
    json['meetupIndex'] as int,
    json['location'] == null ? null : Location.fromJson(json['location'] as Map<String, dynamic>),
    json['timestamp'] as int,
    json['numberOfParticipantsConfirmed'] as int,
  )..claimantSignature = (json['claimantSignature'] as Map<String, dynamic>)?.map(
      (k, e) => MapEntry(k, e as String),
    );
}

Map<String, dynamic> _$ClaimOfAttendanceToJson(ClaimOfAttendance instance) => <String, dynamic>{
      'claimantPublic': instance.claimantPublic,
      'ceremonyIndex': instance.ceremonyIndex,
      'communityIdentifier': instance.communityIdentifier?.toJson(),
      'meetupIndex': instance.meetupIndex,
      'location': instance.location?.toJson(),
      'timestamp': instance.timestamp,
      'numberOfParticipantsConfirmed': instance.numberOfParticipantsConfirmed,
      'claimantSignature': instance.claimantSignature,
    };
