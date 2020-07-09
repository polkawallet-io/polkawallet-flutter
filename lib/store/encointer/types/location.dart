import 'package:json_annotation/json_annotation.dart';

// Run: `flutter pub run build_runner build` in order to create/update the *.g.dart
part 'location.g.dart';

@JsonSerializable()
class Location {
  Location(this.lon, this.lat);

  final BigInt lon;
  final BigInt lat;

  factory Location.fromJson(Map<String, dynamic> json) =>
      _$LocationFromJson(json);
  Map<String, dynamic> toJson() =>
      _$LocationToJson(this);
}
