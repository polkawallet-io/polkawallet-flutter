class TxSwapData extends _TxSwapData {
  static TxSwapData fromJson(Map<String, dynamic> json) {
    TxSwapData data = TxSwapData();
    data.hash = json['hash'];
    data.tokenPay = json['method']['args'][0];
    data.tokenReceive = json['method']['args'][2];
    data.amountPay = (json['method']['args'][1] as String).split(' ')[0];
    data.amountReceive = (json['method']['args'][3] as String).split(' ')[0];
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
