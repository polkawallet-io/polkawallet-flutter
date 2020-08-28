import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:polka_wallet/common/consts/settings.dart';
import 'package:polka_wallet/store/app.dart';
import 'package:polka_wallet/utils/format.dart';

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
    final String networkToken =
        globalAppStore.settings.networkState.tokenSymbol;
    final int decimals = globalAppStore.settings.networkState.tokenDecimals;
    final bool isLaminar =
        globalAppStore.settings.endpoint.info == networkEndpointLaminar.info;
    bool hasIcon = true;
    if (isLaminar &&
        (symbol != networkToken &&
            symbol != acala_stable_coin &&
            symbol != acala_stable_coin_view)) {
      hasIcon = false;
    }
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
