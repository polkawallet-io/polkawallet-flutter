// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ownStashInfo.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OwnStashInfoData _$OwnStashInfoDataFromJson(Map<String, dynamic> json) {
  return OwnStashInfoData()
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
        : NomineesInfoData.fromJson(json['inactives'] as Map<String, dynamic>);
}

Map<String, dynamic> _$OwnStashInfoDataToJson(OwnStashInfoData instance) =>
    <String, dynamic>{
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
