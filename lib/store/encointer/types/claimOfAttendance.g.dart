// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'claimOfAttendance.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ClaimOfAttendance _$ClaimOfAttendanceFromJson(Map<String, dynamic> json) {
  return ClaimOfAttendance(
    json['claimant_public'] as String,
    json['ceremony_index'] as int,
    json['currency_identifier'] as String,
    json['meetup_index'] as int,
    json['location'] == null
        ? null
        : Location.fromJson(json['location'] as Map<String, dynamic>),
    json['timestamp'] as int,
    json['number_of_participants_confirmed'] as int,
  );
}

Map<String, dynamic> _$ClaimOfAttendanceToJson(ClaimOfAttendance instance) =>
    <String, dynamic>{
      'claimant_public': instance.claimantPublic,
      'ceremony_index': instance.ceremonyIndex,
      'currency_identifier': instance.currencyIdentifier,
      'meetup_index': instance.meetupIndex,
      'location': instance.location?.toJson(),
      'timestamp': instance.timestamp,
      'number_of_participants_confirmed':
          instance.numberOfParticipantsConfirmed,
    };
