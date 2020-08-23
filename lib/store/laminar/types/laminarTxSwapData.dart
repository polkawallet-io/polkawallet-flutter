import 'package:polka_wallet/utils/format.dart';

class LaminarTxSwapData extends _LaminarTxSwapData {
  static LaminarTxSwapData fromJson(Map<String, dynamic> json, int decimals) {
    LaminarTxSwapData data = LaminarTxSwapData();
    data.hash = json['hash'];
    data.call = json['call'];
    data.tokenId = json['params'][1];
    data.amountPay = Fmt.priceCeilBigInt(
        Fmt.balanceInt(json['params'][2].toString()), decimals);
    data.time = DateTime.fromMillisecondsSinceEpoch(json['time']);
    return data;
  }
}

abstract class _LaminarTxSwapData {
  String hash;
  String call;
  String tokenId;
  String amountPay;
  DateTime time;
}
