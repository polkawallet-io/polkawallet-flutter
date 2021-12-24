// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'claimOfAttendance.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ClaimOfAttendance _$ClaimOfAttendanceFromJson(Map<String, dynamic> json) {
  return ClaimOfAttendance(
    json['claimant_public'] as String,
    json['ceremony_index'] as int,
    json['community_identifier'] == null
        ? null
        : CommunityIdentifier.fromJson(json['community_identifier'] as Map<String, dynamic>),
    json['meetup_location_index'] as int,
    json['location'] == null ? null : Location.fromJson(json['location'] as Map<String, dynamic>),
    json['timestamp'] as int,
    json['number_of_participants_confirmed'] as int,
  )..claimantSignature = (json['claimant_signature'] as Map<String, dynamic>)?.map(
      (k, e) => MapEntry(k, e as String),
    );
}

Map<String, dynamic> _$ClaimOfAttendanceToJson(ClaimOfAttendance instance) => <String, dynamic>{
      'claimant_public': instance.claimantPublic,
      'ceremony_index': instance.ceremonyIndex,
      'community_identifier': instance.communityIdentifier?.toJson(),
      'meetup_location_index': instance.meetupLocationIndex,
      'location': instance.location?.toJson(),
      'timestamp': instance.timestamp,
      'number_of_participants_confirmed': instance.numberOfParticipantsConfirmed,
      'claimant_signature': instance.claimantSignature,
    };
