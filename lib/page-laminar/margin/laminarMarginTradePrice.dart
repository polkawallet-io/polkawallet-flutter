import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:polka_wallet/utils/format.dart';

class LaminarMarginTradePrice extends StatelessWidget {
  LaminarMarginTradePrice({
    this.decimals,
    this.priceInt,
    this.direction,
    this.highlight = false,
    this.fontSize,
  });

  final int decimals;
  final BigInt priceInt;
  final String direction;
  final bool highlight;
  final double fontSize;

  String _getTradePrice({int lengthFixed = 3, int lengthMax = 5}) {
    return Fmt.priceCeilBigInt(priceInt, decimals,
        lengthFixed: lengthFixed, lengthMax: lengthMax);
  }

  @override
  Widget build(BuildContext context) {
    final TextStyle style = TextStyle(
      fontSize: fontSize ?? 14,
      color: highlight
          ? Theme.of(context).primaryColor
          : Theme.of(context).unselectedWidgetColor,
      decoration: TextDecoration.none,
    );
    final TextStyle styleBold = TextStyle(
      fontSize: (fontSize ?? 14) + 2,
      fontWeight: FontWeight.bold,
      color: highlight
          ? Theme.of(context).primaryColor
          : Theme.of(context).unselectedWidgetColor,
      decoration: TextDecoration.none,
    );

    final String price = _getTradePrice(lengthFixed: 5);

    return priceInt == BigInt.zero
        ? Row(
            children: <Widget>[Text('-', style: style)],
          )
        : Row(
            children: <Widget>[
              Text(price.substring(0, price.length - 3), style: style),
              Text(
                price.substring(price.length - 3, price.length - 1),
                style: styleBold,
              ),
              Text(price.substring(price.length - 1), style: style),
            ],
          );
  }
}
