import 'dart:convert';
import 'package:json_annotation/json_annotation.dart';

enum CeremonyPhase {
  REGISTERING,
  ASSIGNING,
  ATTESTING
}

T getEnumFromString<T>(Iterable<T> values, String value) {
  return values.firstWhere((type) => type.toString().split(".").last == value,
      orElse: () => null);
}