import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:polka_wallet/common/consts/settings.dart';
import 'package:polka_wallet/store/laminar/types/laminarCurrenciesData.dart';
import 'package:polka_wallet/store/laminar/types/laminarMarginData.dart';
import 'package:polka_wallet/utils/format.dart';

class LaminarMarginTradePrice extends StatelessWidget {
  LaminarMarginTradePrice({
    this.decimals,
    this.pairData,
    this.priceMap,
    this.direction,
    this.highlight = false,
  });

  final int decimals;
  final LaminarMarginPairData pairData;
  final Map<String, LaminarPriceData> priceMap;
  final String direction;
  final bool highlight;

  String getPrice({BigInt priceInt}) {
    final BigInt spreadAsk = Fmt.balanceInt(pairData.askSpread.toString());
    final BigInt spreadBid = Fmt.balanceInt(pairData.bidSpread.toString());
    BigInt price = priceInt ?? getPriceInt();

    return direction == 'long'
        ? Fmt.priceCeilBigInt(price + spreadAsk,
            decimals: decimals, lengthFixed: 5)
        : Fmt.priceCeilBigInt(price - spreadBid,
            decimals: decimals, lengthFixed: 5);
  }

  BigInt getPriceInt() {
    final BigInt priceBase = _getTokenPrice(pairData.pair.base);
    final BigInt priceQuote = _getTokenPrice(pairData.pair.quote);
    BigInt priceInt = BigInt.zero;
    if (priceBase != BigInt.zero && priceQuote != BigInt.zero) {
      priceInt = priceBase * BigInt.parse('1000000000000000000') ~/ priceQuote;
    }

    return priceInt;
  }

  BigInt _getTokenPrice(String symbol) {
    if (symbol == acala_stable_coin) {
      return BigInt.parse('1000000000000000000');
    }
    final LaminarPriceData priceData = priceMap[symbol];
    if (priceData == null) {
      return BigInt.zero;
    }
    return Fmt.balanceInt(priceData.value ?? '0');
  }

  @override
  Widget build(BuildContext context) {
    final TextStyle style = TextStyle(
      fontSize: 14,
      color: highlight
          ? Theme.of(context).primaryColor
          : Theme.of(context).unselectedWidgetColor,
      decoration: TextDecoration.none,
    );
    final TextStyle styleBold = TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.bold,
      color: highlight
          ? Theme.of(context).primaryColor
          : Theme.of(context).unselectedWidgetColor,
      decoration: TextDecoration.none,
    );

    final BigInt priceInt = getPriceInt();
    final String price = getPrice(priceInt: priceInt);

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
