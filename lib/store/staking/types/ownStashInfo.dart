import 'package:json_annotation/json_annotation.dart';

part 'ownStashInfo.g.dart';

@JsonSerializable()
class OwnStashInfoData extends _OwnStashInfoData {
  static OwnStashInfoData fromJson(Map<String, dynamic> json) =>
      _$OwnStashInfoDataFromJson(json);
}

abstract class _OwnStashInfoData {
  LedgerInfoData account;
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
  Map<String, dynamic> unbondings;
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

@JsonSerializable()
class LedgerInfoData extends _LedgerInfoData {
  static LedgerInfoData fromJson(Map<String, dynamic> json) =>
      _$LedgerInfoDataFromJson(json);
}

abstract class _LedgerInfoData {
  String accountId;
  String controllerId;
  String stashId;
  Map<String, dynamic> exposure;
  Map<String, dynamic> stakingLedger;
  Map<String, dynamic> validatorPrefs;
  dynamic redeemable;
}

@JsonSerializable()
class UnbondingInfoData extends _UnbondingInfoData {
  static UnbondingInfoData fromJson(Map<String, dynamic> json) =>
      _$UnbondingInfoDataFromJson(json);
}

abstract class _UnbondingInfoData {
  List mapped;
  dynamic total;
}
