import 'package:json_annotation/json_annotation.dart';

part 'stakingPoolInfoData.g.dart';

@JsonSerializable()
class StakingPoolInfoData extends _StakingPoolInfoData {
  static StakingPoolInfoData fromJson(Map<String, dynamic> json) =>
      _$StakingPoolInfoDataFromJson(json);
}

abstract class _StakingPoolInfoData {
  String rewardRate;
  List<StakingPoolFreeItemData> freeList;
  double claimFeeRatio;
  double unbondingDuration;
  double communalFreeRatio;
  double unbondingToFreeRatio;
  String liquidTokenIssuance;
  double defaultExchangeRate;
  double maxClaimFee;
  double bondingDuration;
  double currentEra;
  double communalBonded;
  double communalTotal;
  double communalBondedRatio;
  double liquidExchangeRate;
}

@JsonSerializable()
class StakingPoolFreeItemData {
  int era;
  double free;

  static StakingPoolFreeItemData fromJson(Map<String, dynamic> json) =>
      _$StakingPoolFreeItemDataFromJson(json);
}

class HomaUserInfoData extends _HomaUserInfoData {
  static HomaUserInfoData fromJson(Map<String, dynamic> json) {
    HomaUserInfoData data = HomaUserInfoData();
    data.unbonded = BigInt.parse(json['unbonded'].toString());
    data.claims = List.of(json['claims']).map((i) {
      HomaUserInfoClaimItemData item = HomaUserInfoClaimItemData();
      item.era = i['era'];
      item.claimed = BigInt.parse(i['claimed'].toString());
      return item;
    }).toList();
    return data;
  }
}

abstract class _HomaUserInfoData {
  BigInt unbonded;
  List<HomaUserInfoClaimItemData> claims;
}

class HomaUserInfoClaimItemData {
  int era;
  BigInt claimed;
}
