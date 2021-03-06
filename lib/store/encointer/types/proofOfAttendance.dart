import 'dart:convert';

import 'package:json_annotation/json_annotation.dart';

// Run: `flutter pub run build_runner build` in order to create/update the *.g.dart

part 'proofOfAttendance.g.dart';

// explicit = true as we have nested Json with location
// field rename such that the fields match the ones defined in the runtime
@JsonSerializable(explicitToJson: true, fieldRename: FieldRename.snake)
class ProofOfAttendance {
  ProofOfAttendance(
    this.proverPublic,
    this.ceremonyIndex,
    this.communityIdentifier,
    this.attendeePublic,
    this.attendeeSignature,
  );

  String proverPublic;
  int ceremonyIndex;
  String communityIdentifier;
  String attendeePublic;
  Map<String, String> attendeeSignature;

  @override
  String toString() {
    return jsonEncode(this);
  }

  factory ProofOfAttendance.fromJson(Map<String, dynamic> json) => _$ProofOfAttendanceFromJson(json);
  Map<String, dynamic> toJson() => _$ProofOfAttendanceToJson(this);
}
