import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:polka_wallet/common/consts/settings.dart';
import 'package:polka_wallet/utils/format.dart';

class LaminarMarginTradePnl extends StatelessWidget {
  LaminarMarginTradePnl({
    this.decimals,
    this.amount,
    this.openPrice,
    this.closePrice,
  });

  final int decimals;
  final BigInt amount;
  final BigInt openPrice;
  final BigInt closePrice;

  @override
  Widget build(BuildContext context) {
    final BigInt delta = closePrice - openPrice;
    final String pnl = Fmt.token(
        (closePrice - openPrice) * amount ~/ laminarIntDivisor,
        decimals: decimals);

    return Text(delta > BigInt.zero ? '+$pnl' : pnl,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: delta > BigInt.zero ? Colors.green : Colors.red,
        ));
  }
}
