import 'package:encointer_wallet/utils/format.dart';
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
    bool hasIcon = true;
    return Row(
      mainAxisAlignment: mainAxisAlignment ?? MainAxisAlignment.start,
      children: <Widget>[
        Container(
          width: 32,
          height: 32,
          padding: EdgeInsets.only(right: 4),
          child: hasIcon
              ? Image.asset('assets/images/assets/${symbol.toUpperCase()}.png')
              : CircleAvatar(
                  child: Text(symbol.substring(0, 2)),
                ),
        ),
        Expanded(
          flex: 0,
          child: Text(
            Fmt.tokenView(symbol),
            style: textStyle,
          ),
        ),
        trailing ?? Container()
      ],
    );
  }
}
