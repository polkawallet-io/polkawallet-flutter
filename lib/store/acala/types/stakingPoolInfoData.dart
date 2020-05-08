import 'package:json_annotation/json_annotation.dart';

part 'stakingPoolInfoData.g.dart';

@JsonSerializable()
class StakingPoolInfoData extends _StakingPoolInfoData {
  static StakingPoolInfoData fromJson(Map<String, dynamic> json) =>
      _$StakingPoolInfoDataFromJson(json);
}

abstract class _StakingPoolInfoData {
  String rewardRate;
  double priceLDOT;
  List<double> freeList;
  double unbondingDuration;
  double totalBonded;
  double communalFree;
  double unbondingToFree;
  double nextEraClaimedUnbonded;
  double liquidTokenIssuance;
  double defaultExchangeRate;
  double maxClaimFee;
  double bondingDuration;
  double currentEra;
  double communalBonded;
  double communalTotal;
  double communalBondedRatio;
  double liquidExchangeRate;
}
