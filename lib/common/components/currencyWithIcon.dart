import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:polka_wallet/common/consts/settings.dart';
import 'package:polka_wallet/store/app.dart';
import 'package:polka_wallet/utils/format.dart';

class CurrencyWithIcon extends StatelessWidget {
  CurrencyWithIcon(
    this.symbol, {
    this.showLP = true,
    this.textStyle,
    this.trailing,
    this.mainAxisAlignment,
  });

  final bool showLP;
  final String symbol;
  final TextStyle textStyle;
  final MainAxisAlignment mainAxisAlignment;
  final Widget trailing;

  @override
  Widget build(BuildContext context) {
    final String networkToken =
        globalAppStore.settings.networkState.tokenSymbol;
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
          width: symbol.contains('-') ? 48 : 32,
          height: 32,
          padding: EdgeInsets.only(right: 4),
          child: hasIcon
              ? TokenIcon(symbol)
              : CircleAvatar(
                  child: Text(symbol.substring(0, 2)),
                ),
        ),
        Expanded(
          flex: 0,
          child: Text(
            showLP ? Fmt.tokenView(symbol) : symbol,
            style: textStyle,
          ),
        ),
        trailing ?? Container()
      ],
    );
  }
}

class TokenIcon extends StatelessWidget {
  TokenIcon(this.symbol);
  final String symbol;
  @override
  Widget build(BuildContext context) {
    if (symbol.contains('-')) {
      final pair = symbol.split('-');
      return Stack(
        children: [
          Container(
            margin: EdgeInsets.only(left: 16),
            child: Image.asset(
                'assets/images/assets/${pair[1].toUpperCase()}.png'),
          ),
          SizedBox(
            width: 29,
            child: Image.asset(
                'assets/images/assets/${pair[0].toUpperCase()}.png'),
          )
        ],
      );
    }
    return Image.asset('assets/images/assets/${symbol.toUpperCase()}.png');
  }
}
