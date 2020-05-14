// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'stakingPoolInfoData.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

StakingPoolInfoData _$StakingPoolInfoDataFromJson(Map<String, dynamic> json) {
  return StakingPoolInfoData()
    ..rewardRate = json['rewardRate'] as String
    ..priceLDOT = (json['priceLDOT'] as num)?.toDouble()
    ..freeList = (json['freeList'] as List)
        ?.map((e) => e == null
            ? null
            : StakingPoolFreeItemData.fromJson(e as Map<String, dynamic>))
        ?.toList()
    ..claimFeeRatio = (json['claimFeeRatio'] as num)?.toDouble()
    ..unbondingDuration = (json['unbondingDuration'] as num)?.toDouble()
    ..totalBonded = (json['totalBonded'] as num)?.toDouble()
    ..communalFree = (json['communalFree'] as num)?.toDouble()
    ..unbondingToFree = (json['unbondingToFree'] as num)?.toDouble()
    ..nextEraClaimedUnbonded =
        (json['nextEraClaimedUnbonded'] as num)?.toDouble()
    ..liquidTokenIssuance = (json['liquidTokenIssuance'] as num)?.toDouble()
    ..defaultExchangeRate = (json['defaultExchangeRate'] as num)?.toDouble()
    ..maxClaimFee = (json['maxClaimFee'] as num)?.toDouble()
    ..bondingDuration = (json['bondingDuration'] as num)?.toDouble()
    ..currentEra = (json['currentEra'] as num)?.toDouble()
    ..communalBonded = (json['communalBonded'] as num)?.toDouble()
    ..communalTotal = (json['communalTotal'] as num)?.toDouble()
    ..communalBondedRatio = (json['communalBondedRatio'] as num)?.toDouble()
    ..liquidExchangeRate = (json['liquidExchangeRate'] as num)?.toDouble();
}

Map<String, dynamic> _$StakingPoolInfoDataToJson(
        StakingPoolInfoData instance) =>
    <String, dynamic>{
      'rewardRate': instance.rewardRate,
      'priceLDOT': instance.priceLDOT,
      'freeList': instance.freeList,
      'claimFeeRatio': instance.claimFeeRatio,
      'unbondingDuration': instance.unbondingDuration,
      'totalBonded': instance.totalBonded,
      'communalFree': instance.communalFree,
      'unbondingToFree': instance.unbondingToFree,
      'nextEraClaimedUnbonded': instance.nextEraClaimedUnbonded,
      'liquidTokenIssuance': instance.liquidTokenIssuance,
      'defaultExchangeRate': instance.defaultExchangeRate,
      'maxClaimFee': instance.maxClaimFee,
      'bondingDuration': instance.bondingDuration,
      'currentEra': instance.currentEra,
      'communalBonded': instance.communalBonded,
      'communalTotal': instance.communalTotal,
      'communalBondedRatio': instance.communalBondedRatio,
      'liquidExchangeRate': instance.liquidExchangeRate,
    };

StakingPoolFreeItemData _$StakingPoolFreeItemDataFromJson(
    Map<String, dynamic> json) {
  return StakingPoolFreeItemData()
    ..era = json['era'] as int
    ..free = (json['free'] as num)?.toDouble()
    ..claimFeeRatio = (json['claimFeeRatio'] as num)?.toDouble();
}

Map<String, dynamic> _$StakingPoolFreeItemDataToJson(
        StakingPoolFreeItemData instance) =>
    <String, dynamic>{
      'era': instance.era,
      'free': instance.free,
      'claimFeeRatio': instance.claimFeeRatio,
    };
