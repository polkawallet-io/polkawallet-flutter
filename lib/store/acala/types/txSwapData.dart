import 'package:polka_wallet/utils/format.dart';

class TxSwapData extends _TxSwapData {
  static TxSwapData fromJson(Map<String, dynamic> json, int decimals) {
    TxSwapData data = TxSwapData();
    data.hash = json['hash'];
    data.tokenPay = json['params'][0];
    data.tokenReceive = json['params'][2];
    data.amountPay = Fmt.priceCeilBigInt(
        Fmt.balanceInt(json['params'][1].toString()), decimals);
    data.amountReceive = Fmt.priceFloorBigInt(
        Fmt.balanceInt(json['params'][3].toString()), decimals);
    data.time = DateTime.fromMillisecondsSinceEpoch(json['time']);
    return data;
  }
}

abstract class _TxSwapData {
  String hash;
  String tokenPay;
  String tokenReceive;
  String amountPay;
  String amountReceive;
  DateTime time;
}
