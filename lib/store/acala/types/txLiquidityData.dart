import 'package:polka_wallet/common/consts/settings.dart';
import 'package:polka_wallet/utils/format.dart';

class TxDexLiquidityData extends _TxDexLiquidityData {
  static const String actionDeposit = 'deposit';
  static const String actionWithdraw = 'withdraw';
  static const String actionReward = 'reward';
  static TxDexLiquidityData fromJson(Map<String, dynamic> json, int decimals) {
    TxDexLiquidityData data = TxDexLiquidityData();
    data.hash = json['hash'];
    data.action = json['action'];
    data.currencyId = json['params'][0];
    switch (data.action) {
      case actionDeposit:
        data.amountToken = Fmt.balanceInt(json['params'][1]);
        data.amountStableCoin = Fmt.balanceInt(json['params'][2]);
        break;
      case actionWithdraw:
        data.amountShare = Fmt.balanceInt(json['params'][1]);
        break;
      case actionReward:
        data.amountStableCoin = Fmt.tokenInt(json['reward'], decimals);
        break;
    }
    data.time = DateTime.fromMillisecondsSinceEpoch(json['time']);
    return data;
  }
}

abstract class _TxDexLiquidityData {
  String hash;
  String currencyId;
  String action;
  BigInt amountToken;
  BigInt amountStableCoin;
  BigInt amountShare;
  DateTime time;
}
