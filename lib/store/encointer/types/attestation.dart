// Run: `flutter pub run build_runner build` in order to create/update the *.g.dart
import 'dart:convert';

import 'package:json_annotation/json_annotation.dart';

import 'claimOfAttendance.dart';

part 'attestation.g.dart';

// explicit = true as we have nested Json with ClaimOfAttendance
// field rename such that the fields match the ones defined in the runtime
@JsonSerializable(explicitToJson: true, fieldRename: FieldRename.snake)
class Attestation {
  Attestation(this.claim, this.signature, this.public);

  ClaimOfAttendance claim;
  Map<String, String> signature;
  String public;

  @override
  String toString() {
    return jsonEncode(this);
  }

  factory Attestation.fromJson(Map<String, dynamic> json) => _$AttestationFromJson(json);
  Map<String, dynamic> toJson() => _$AttestationToJson(this);
}

// explicit = true as we have nested Json with ClaimOfAttendance
// field rename such that the fields match the ones defined in the runtime
@JsonSerializable(explicitToJson: true, fieldRename: FieldRename.snake)
class AttestationResult {
  AttestationResult(this.attestation, this.attestationHex);

  Attestation attestation;
  String attestationHex;

  @override
  String toString() {
    return jsonEncode(this);
  }

  factory AttestationResult.fromJson(Map<String, dynamic> json) => _$AttestationResultFromJson(json);
  Map<String, dynamic> toJson() => _$AttestationResultToJson(this);
}
