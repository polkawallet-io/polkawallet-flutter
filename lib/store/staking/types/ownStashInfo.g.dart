// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ownStashInfo.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OwnStashInfoData _$OwnStashInfoDataFromJson(Map<String, dynamic> json) {
  return OwnStashInfoData()
    ..account = json['account'] == null
        ? null
        : LedgerInfoData.fromJson(json['account'] as Map<String, dynamic>)
    ..controllerId = json['controllerId'] as String
    ..destination = json['destination'] as String
    ..destinationId = json['destinationId'] as int
    ..exposure = json['exposure'] as Map<String, dynamic>
    ..hexSessionIdNext = json['hexSessionIdNext'] as String
    ..hexSessionIdQueue = json['hexSessionIdQueue'] as String
    ..isOwnController = json['isOwnController'] as bool
    ..isOwnStash = json['isOwnStash'] as bool
    ..isStashNominating = json['isStashNominating'] as bool
    ..isStashValidating = json['isStashValidating'] as bool
    ..nominating =
        (json['nominating'] as List)?.map((e) => e as String)?.toList()
    ..sessionIds =
        (json['sessionIds'] as List)?.map((e) => e as String)?.toList()
    ..stakingLedger = json['stakingLedger'] as Map<String, dynamic>
    ..stashId = json['stashId'] as String
    ..validatorPrefs = json['validatorPrefs'] as Map<String, dynamic>
    ..inactives = json['inactives'] == null
        ? null
        : NomineesInfoData.fromJson(json['inactives'] as Map<String, dynamic>)
    ..unbondings = json['unbondings'] as Map<String, dynamic>;
}

Map<String, dynamic> _$OwnStashInfoDataToJson(OwnStashInfoData instance) =>
    <String, dynamic>{
      'account': instance.account,
      'controllerId': instance.controllerId,
      'destination': instance.destination,
      'destinationId': instance.destinationId,
      'exposure': instance.exposure,
      'hexSessionIdNext': instance.hexSessionIdNext,
      'hexSessionIdQueue': instance.hexSessionIdQueue,
      'isOwnController': instance.isOwnController,
      'isOwnStash': instance.isOwnStash,
      'isStashNominating': instance.isStashNominating,
      'isStashValidating': instance.isStashValidating,
      'nominating': instance.nominating,
      'sessionIds': instance.sessionIds,
      'stakingLedger': instance.stakingLedger,
      'stashId': instance.stashId,
      'validatorPrefs': instance.validatorPrefs,
      'inactives': instance.inactives,
      'unbondings': instance.unbondings,
    };

NomineesInfoData _$NomineesInfoDataFromJson(Map<String, dynamic> json) {
  return NomineesInfoData()
    ..nomsActive =
        (json['nomsActive'] as List)?.map((e) => e as String)?.toList()
    ..nomsChilled =
        (json['nomsChilled'] as List)?.map((e) => e as String)?.toList()
    ..nomsInactive =
        (json['nomsInactive'] as List)?.map((e) => e as String)?.toList()
    ..nomsOver = (json['nomsOver'] as List)?.map((e) => e as String)?.toList()
    ..nomsWaiting =
        (json['nomsWaiting'] as List)?.map((e) => e as String)?.toList();
}

Map<String, dynamic> _$NomineesInfoDataToJson(NomineesInfoData instance) =>
    <String, dynamic>{
      'nomsActive': instance.nomsActive,
      'nomsChilled': instance.nomsChilled,
      'nomsInactive': instance.nomsInactive,
      'nomsOver': instance.nomsOver,
      'nomsWaiting': instance.nomsWaiting,
    };

LedgerInfoData _$LedgerInfoDataFromJson(Map<String, dynamic> json) {
  return LedgerInfoData()
    ..accountId = json['accountId'] as String
    ..controllerId = json['controllerId'] as String
    ..stashId = json['stashId'] as String
    ..exposure = json['exposure'] as Map<String, dynamic>
    ..stakingLedger = json['stakingLedger'] as Map<String, dynamic>
    ..validatorPrefs = json['validatorPrefs'] as Map<String, dynamic>
    ..redeemable = json['redeemable'];
}

Map<String, dynamic> _$LedgerInfoDataToJson(LedgerInfoData instance) =>
    <String, dynamic>{
      'accountId': instance.accountId,
      'controllerId': instance.controllerId,
      'stashId': instance.stashId,
      'exposure': instance.exposure,
      'stakingLedger': instance.stakingLedger,
      'validatorPrefs': instance.validatorPrefs,
      'redeemable': instance.redeemable,
    };

UnbondingInfoData _$UnbondingInfoDataFromJson(Map<String, dynamic> json) {
  return UnbondingInfoData()
    ..mapped = json['mapped'] as List
    ..total = json['total'];
}

Map<String, dynamic> _$UnbondingInfoDataToJson(UnbondingInfoData instance) =>
    <String, dynamic>{
      'mapped': instance.mapped,
      'total': instance.total,
    };
