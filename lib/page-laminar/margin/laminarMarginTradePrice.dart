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

  String getTradePrice(
      {BigInt priceInt, int lengthFixed = 3, int lengthMax = 5}) {
    BigInt price = getTradePriceInt(priceInt: priceInt ?? _getPriceInt());

    return Fmt.priceCeilBigInt(price,
        decimals: decimals, lengthFixed: lengthFixed, lengthMax: lengthMax);
  }

  BigInt getTradePriceInt({BigInt priceInt}) {
    final BigInt spreadAsk = Fmt.balanceInt(pairData.askSpread.toString());
    final BigInt spreadBid = Fmt.balanceInt(pairData.bidSpread.toString());
    BigInt price = priceInt ?? _getPriceInt();

    return direction == 'long' ? price + spreadAsk : price - spreadBid;
  }

  BigInt _getPriceInt() {
    final BigInt priceBase = _getTokenPrice(pairData.pair.base);
    final BigInt priceQuote = _getTokenPrice(pairData.pair.quote);
    BigInt priceInt = BigInt.zero;
    if (priceBase != BigInt.zero && priceQuote != BigInt.zero) {
      priceInt = priceBase * laminarIntDivisor ~/ priceQuote;
    }

    return priceInt;
  }

  BigInt _getTokenPrice(String symbol) {
    if (symbol == acala_stable_coin) {
      return laminarIntDivisor;
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

    final BigInt priceInt = _getPriceInt();
    final String price = getTradePrice(priceInt: priceInt, lengthFixed: 5);

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
