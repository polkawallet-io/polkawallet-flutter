import 'package:polka_wallet/utils/format.dart';

class TxDexLiquidityData extends _TxDexLiquidityData {
  static TxDexLiquidityData fromJson(Map<String, dynamic> json) {
    TxDexLiquidityData data = TxDexLiquidityData();
    data.hash = json['hash'];
    data.currencyId = json['method']['args'][0];
//    data.amountToken = Fmt.balanceInt(json['method']['args'][1]);
//    data.amountStableCoin = Fmt.balanceInt(json['method']['args'][2]);
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
