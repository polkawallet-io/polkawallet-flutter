import 'package:polka_wallet/utils/format.dart';

class DexPoolInfoData extends _DexPoolInfoData {
  static DexPoolInfoData fromJson(Map<String, dynamic> json) {
    DexPoolInfoData data = DexPoolInfoData();
    data.token = json['token'];
    data.amountToken = Fmt.balanceInt(json['pool'][0].toString());
    data.amountStableCoin = Fmt.balanceInt(json['pool'][1].toString());
    data.sharesTotal = Fmt.balanceInt(json['sharesTotal'].toString());
    data.shares = Fmt.balanceInt(json['shares'].toString());
    data.proportion = double.parse(json['proportion'].toString());
    data.reward = LPRewardData(
      Fmt.balanceInt(json['reward']['incentive'].toString()),
      Fmt.balanceInt(json['reward']['saving'].toString()),
    );
    data.issuance = Fmt.balanceInt(json['issuance'].toString());
    return data;
  }
}

abstract class _DexPoolInfoData {
  String token;
  BigInt amountToken;
  BigInt amountStableCoin;
  BigInt sharesTotal;
  BigInt shares;
  LPRewardData reward;
  double proportion;
  BigInt issuance;
}

class LPRewardData {
  LPRewardData(this.incentive, this.saving);
  BigInt incentive;
  BigInt saving;
}
