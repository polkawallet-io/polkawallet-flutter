// Run: `flutter pub run build_runner build` in order to create/update the *.g.dart
import 'dart:convert';

import 'package:json_annotation/json_annotation.dart';

part 'workerApi.g.dart';

@JsonSerializable()
class PubKeyPinPair {
  PubKeyPinPair(this.pubKey, this.pin);

  String pubKey;
  String pin;

  @override
  String toString() {
    return jsonEncode(this);
  }

  factory PubKeyPinPair.fromJson(Map<String, dynamic> json) => _$PubKeyPinPairFromJson(json);
  Map<String, dynamic> toJson() => _$PubKeyPinPairToJson(this);
}
