import 'package:polka_wallet/utils/format.dart';

class TxLoanData extends _TxLoanData {
  static const String actionTypeDeposit = 'deposit';
  static const String actionTypeWithdraw = 'withdraw';
  static const String actionTypeBorrow = 'borrow';
  static const String actionTypePayback = 'payback';
  static TxLoanData fromJson(Map<String, dynamic> json) {
    TxLoanData data = TxLoanData();
    data.hash = json['hash'];
    data.currencyId = json['params'][0];
    data.time = DateTime.fromMillisecondsSinceEpoch(json['time']);
    data.amountCollateral = Fmt.balanceInt(json['params'][1].toString());
    data.amountDebitShare = Fmt.balanceInt(json['params'][2].toString());
    if (data.amountCollateral == BigInt.zero) {
      data.actionType = data.amountDebitShare > BigInt.zero
          ? actionTypeBorrow
          : actionTypePayback;
      data.currencyIdView = 'aUSD';
    } else if (data.amountDebitShare == BigInt.zero) {
      data.actionType = data.amountCollateral > BigInt.zero
          ? actionTypeDeposit
          : actionTypeWithdraw;
      data.currencyIdView = data.currencyId;
    } else {
      data.actionType = 'create';
      data.currencyIdView = 'aUSD';
    }
    return data;
  }
}

abstract class _TxLoanData {
  String hash;
  String currencyId;
  String actionType;
  DateTime time;
  BigInt amountCollateral;
  BigInt amountDebitShare;

  String currencyIdView;
}
