import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CurrencyWithIcon extends StatelessWidget {
  CurrencyWithIcon(
    this.symbol, {
    this.textStyle,
    this.textWidth,
    this.trailing,
    this.mainAxisAlignment,
  });

  final String symbol;
  final double textWidth;
  final TextStyle textStyle;
  final MainAxisAlignment mainAxisAlignment;
  final Widget trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: mainAxisAlignment ?? MainAxisAlignment.start,
      children: <Widget>[
        Container(
          width: 32,
          padding: EdgeInsets.only(right: 8),
          child: Image.asset('assets/images/assets/$symbol.png'),
        ),
        Container(
          width: textWidth ?? 60,
          child: Text(
            symbol,
            style: textStyle,
          ),
        ),
        trailing ?? Container()
      ],
    );
  }
}
