// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'location.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Location _$LocationFromJson(Map<String, dynamic> json) {
  return Location(
    json['lon'] == null ? null : BigInt.parse(json['lon'] as String),
    json['lat'] == null ? null : BigInt.parse(json['lat'] as String),
  );
}

Map<String, dynamic> _$LocationToJson(Location instance) => <String, dynamic>{
      'lon': instance.lon?.toString(),
      'lat': instance.lat?.toString(),
    };
