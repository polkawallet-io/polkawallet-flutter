import 'dart:convert';

import 'package:json_annotation/json_annotation.dart';
import 'package:polka_wallet/store/encointer/types/location.dart';

// Run: `flutter pub run build_runner build` in order to create/update the *.g.dart

part 'claimOfAttendance.g.dart';

// explicit = true as we have nested Json with location
// field rename such that the fields match the ones defined in the runtime
@JsonSerializable(explicitToJson: true, fieldRename: FieldRename.snake)
class ClaimOfAttendance {
  ClaimOfAttendance(this.claimantPublic, this.ceremonyIndex, this.currencyIdentifier,
      this.meetupIndex, this.location, this.timestamp, this.numberOfParticipantsConfirmed);

  String claimantPublic;
  int ceremonyIndex;
  String currencyIdentifier;
  int meetupIndex;
  Location location;
  int timestamp;
  int numberOfParticipantsConfirmed;

  @override
  String toString() {
    return jsonEncode(this);
  }

  factory ClaimOfAttendance.fromJson(Map<String, dynamic> json) =>
      _$ClaimOfAttendanceFromJson(json);
  Map<String, dynamic> toJson() =>
      _$ClaimOfAttendanceToJson(this);
}