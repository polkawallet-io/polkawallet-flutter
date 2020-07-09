import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CurrencyWithIcon extends StatelessWidget {
  CurrencyWithIcon(
    this.symbol, {
    this.textStyle,
    this.trailing,
    this.mainAxisAlignment,
  });

  final String symbol;
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
          padding: EdgeInsets.only(right: 4),
          child:
              Image.asset('assets/images/assets/${symbol.toUpperCase()}.png'),
        ),
        Expanded(
          flex: 0,
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
