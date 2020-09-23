import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:polka_wallet/common/consts/settings.dart';
import 'package:polka_wallet/store/laminar/types/laminarMarginData.dart';
import 'package:polka_wallet/utils/format.dart';

class LaminarMarginTradePnl extends StatelessWidget {
  LaminarMarginTradePnl({
    this.decimals,
    this.amount,
    this.rawPriceQuote,
    this.openPrice,
    this.closePrice,
    this.isShort = false,
    this.pairData,
  });

  final int decimals;
  final BigInt amount;
  final BigInt rawPriceQuote;
  final BigInt openPrice;
  final BigInt closePrice;
  final bool isShort;
  final LaminarMarginPairData pairData;

  @override
  Widget build(BuildContext context) {
    final BigInt delta =
        isShort ? openPrice - closePrice : closePrice - openPrice;
    BigInt pnlInt = delta * amount ~/ laminarIntDivisor;
    if (pairData.pair.quote != acala_stable_coin) {
      pnlInt = pnlInt * rawPriceQuote ~/ laminarIntDivisor;
    }
    final String pnl = Fmt.token(pnlInt, decimals);

    return Text(delta > BigInt.zero ? '+$pnl' : pnl,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: delta > BigInt.zero ? Colors.green : Colors.red,
        ));
  }
}
