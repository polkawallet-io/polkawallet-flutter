import 'package:json_annotation/json_annotation.dart';

part 'ownStashInfo.g.dart';

@JsonSerializable()
class OwnStashInfoData extends _OwnStashInfoData {
  static OwnStashInfoData fromJson(Map<String, dynamic> json) =>
      _$OwnStashInfoDataFromJson(json);
}

abstract class _OwnStashInfoData {
  String controllerId;
  String destination;
  int destinationId;
  Map<String, dynamic> exposure;
  String hexSessionIdNext;
  String hexSessionIdQueue;
  bool isOwnController;
  bool isOwnStash;
  bool isStashNominating;
  bool isStashValidating;
  List<String> nominating;
  List<String> sessionIds;
  Map<String, dynamic> stakingLedger;
  String stashId;
  Map<String, dynamic> validatorPrefs;
  NomineesInfoData inactives;
}

@JsonSerializable()
class NomineesInfoData extends _NomineesInfoData {
  static NomineesInfoData fromJson(Map<String, dynamic> json) =>
      _$NomineesInfoDataFromJson(json);
}

abstract class _NomineesInfoData {
  List<String> nomsActive;
  List<String> nomsChilled;
  List<String> nomsInactive;
  List<String> nomsOver;
  List<String> nomsWaiting;
}
