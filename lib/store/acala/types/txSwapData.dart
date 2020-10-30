import 'package:polka_wallet/utils/format.dart';

class TxSwapData extends _TxSwapData {
  static TxSwapData fromJson(Map<String, dynamic> json, int decimals) {
    TxSwapData data = TxSwapData();
    data.hash = json['hash'];
    final tokenPair = [
      json['params'][0][0]['Token'],
      json['params'][0][List.of(json['params'][0]).length - 1]['Token']
    ];
    final isExactInput = json['mode'] == 0;

    data.tokenPay = tokenPair[0];
    data.tokenReceive = tokenPair[1];
    data.amountPay = Fmt.priceCeilBigInt(
        Fmt.balanceInt(json['params'][isExactInput ? 1 : 2]), decimals);
    data.amountReceive = Fmt.priceFloorBigInt(
        Fmt.balanceInt(json['params'][isExactInput ? 2 : 1]), decimals);
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
