import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:polka_wallet/common/components/infoItem.dart';
import 'package:polka_wallet/common/components/outlinedButtonSmall.dart';
import 'package:polka_wallet/common/components/textTag.dart';
import 'package:polka_wallet/common/consts/settings.dart';
import 'package:polka_wallet/page-laminar/margin/laminarMarginPage.dart';
import 'package:polka_wallet/page-laminar/margin/laminarMarginTradePnl.dart';
import 'package:polka_wallet/page/account/txConfirmPage.dart';
import 'package:polka_wallet/service/substrateApi/api.dart';
import 'package:polka_wallet/store/laminar/types/laminarCurrenciesData.dart';
import 'package:polka_wallet/store/laminar/types/laminarMarginData.dart';
import 'package:polka_wallet/utils/UI.dart';
import 'package:polka_wallet/utils/format.dart';
import 'package:polka_wallet/utils/i18n/index.dart';

class LaminarMarginPosition extends StatelessWidget {
  LaminarMarginPosition(
    this.position,
    this.pairData,
    this.prices, {
    this.closed,
    this.decimals,
  });

  final LaminarMarginPairData pairData;
  final Map<String, LaminarPriceData> prices;
  final Map position;
  final Map closed;
  final int decimals;

  String getLeverage(String str) {
    final bool isLong = RegExp(r'^Long(.*)$').hasMatch(str);
    return laminar_leverage_map[isLong ? str.substring(4) : str.substring(5)];
  }

  Future<void> _onClose(
    BuildContext context,
    int positionId,
    String direction,
  ) async {
    var args = {
      "title": I18n.of(context).laminar['margin.close'],
      "txInfo": {
        "module": 'marginProtocol',
        "call": 'closePosition',
      },
      "detail": jsonEncode({"positionId": positionId}),
      "params": [
        // params.poolId
        positionId,
        // params.price
        direction == 'long'
            ? '0'
            : Fmt.tokenInt('100000000', decimals).toString(),
      ],
      "onFinish": (BuildContext txPageContext, Map res) {
//          print(res);
        Navigator.popUntil(
            txPageContext, ModalRoute.withName(LaminarMarginPage.route));
        globalMarginRefreshKey.currentState.show();
      }
    };
    Navigator.of(context).pushNamed(TxConfirmPage.route, arguments: args);
  }

  @override
  Widget build(BuildContext context) {
    if (pairData == null) return Container();

    final Map dic = I18n.of(context).laminar;
    final String direction =
        RegExp(r'^Long(.*)$').hasMatch(position['args'][4]) ? 'long' : 'short';
    final String leverage = getLeverage(position['args'][4]);
    final int positionId = position['args'][1];

    final BigInt amtInt = BigInt.parse(position['args'][5]);
    final String amt = Fmt.token(
      amtInt,
      decimals,
    );
    final BigInt rawPriceQuote =
        Fmt.balanceInt(prices[pairData.pair.quote]?.value);
    final BigInt openPriceInt = BigInt.parse(position['args'][6]);
    final String openPrice = Fmt.token(
      openPriceInt,
      decimals,
      length: 5,
    );
    final BigInt currentPriceInt = webApi.laminar.getTradePriceInt(
      prices: prices,
      pairData: pairData,
      direction: direction == 'long' ? 'short' : 'long',
    );
    final bool isClosed = closed != null;
    final BigInt closePriceInt =
        isClosed ? BigInt.parse(closed['args'][3]) : BigInt.zero;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Container(
          height: 36,
          child: Row(
            children: <Widget>[
              TextTag(
                direction,
                color: direction == 'long' ? Colors.green : Colors.red,
                fontSize: 12,
                padding: EdgeInsets.fromLTRB(8, 4, 8, 4),
                margin: EdgeInsets.only(right: 8),
              ),
              Expanded(
                child: Text('${pairData.pairId} ($leverage) #$positionId'),
              ),
              isClosed
                  ? Container()
                  : OutlinedButtonSmall(
                      content: dic['margin.close'],
                      onPressed: () => _onClose(context, positionId, direction),
                    )
            ],
          ),
        ),
        Padding(
          padding: EdgeInsets.only(top: 8),
          child: Row(
            children: <Widget>[
              InfoItem(
                title: '${dic['margin.amount']}(${pairData.pair.base})',
                content: amt,
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      isClosed ? dic['margin.pnl.close'] : dic['margin.pnl'],
                      style: TextStyle(fontSize: 12),
                    ),
                    LaminarMarginTradePnl(
                      pairData: pairData,
                      decimals: decimals,
                      amount: amtInt,
                      rawPriceQuote: rawPriceQuote,
                      openPrice: openPriceInt,
                      closePrice: isClosed ? closePriceInt : currentPriceInt,
                      isShort: direction != 'long',
                    )
                  ],
                ),
              ),
              InfoItem(
                title: isClosed
                    ? dic['margin.price.close']
                    : dic['margin.price.now'],
                content: Fmt.token(
                  isClosed ? closePriceInt : currentPriceInt,
                  decimals,
                  length: 5,
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: EdgeInsets.only(top: 8),
          child: Row(
            children: <Widget>[
              InfoItem(
                title: 'TxHash',
                content: Fmt.address(position['extrinsic']['hash'], pad: 4),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      dic['margin.time'],
                      style: TextStyle(fontSize: 12),
                    ),
                    Text(DateTime.fromMillisecondsSinceEpoch(
                            position['block']['timestamp'])
                        .toString()
                        .split('.')[0]),
                  ],
                ),
              ),
              InfoItem(
                title: dic['margin.price.open'],
                content: openPrice,
              ),
            ],
          ),
        ),
        Divider(height: 24),
      ],
    );
  }
}
