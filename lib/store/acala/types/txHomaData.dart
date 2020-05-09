import 'package:polka_wallet/utils/format.dart';

class TxHomaData extends _TxHomaData {
  static const String actionMint = 'mint';
  static const String actionRedeem = 'redeem';
  static const String actionWithdrawRedemption = 'withdrawRedemption';

  static const String redeemTypeNow = 'Immediately';
  static const String redeemTypeEra = 'Target';
  static const String redeemTypeWait = 'WaitForUnbonding';
  static TxHomaData fromJson(Map<String, dynamic> json) {
    TxHomaData data = TxHomaData();
    data.hash = json['hash'];
    data.action = json['action'];
    data.amountPay =
        Fmt.priceCeilBigInt(Fmt.balanceInt(json['params'][0].toString()));
    data.amountReceive = json['amountReceive'];
    data.time = DateTime.fromMillisecondsSinceEpoch(json['time']);
    return data;
  }
}

abstract class _TxHomaData {
  String hash;
  String action;
  String amountPay;
  String amountReceive;
  DateTime time;
}
