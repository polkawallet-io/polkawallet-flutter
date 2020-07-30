import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:polka_wallet/common/components/infoItem.dart';
import 'package:polka_wallet/common/components/outlinedButtonSmall.dart';
import 'package:polka_wallet/common/components/textTag.dart';
import 'package:polka_wallet/common/consts/settings.dart';
import 'package:polka_wallet/page-laminar/margin/laminarMarginTradePnl.dart';
import 'package:polka_wallet/page-laminar/margin/laminarMarginTradePrice.dart';
import 'package:polka_wallet/store/app.dart';
import 'package:polka_wallet/store/laminar/types/laminarCurrenciesData.dart';
import 'package:polka_wallet/store/laminar/types/laminarMarginData.dart';
import 'package:polka_wallet/utils/format.dart';
import 'package:polka_wallet/utils/i18n/index.dart';

class LaminarMarginPositions extends StatefulWidget {
  LaminarMarginPositions(this.store);
  final AppStore store;

  @override
  _LaminarMarginPositionsState createState() => _LaminarMarginPositionsState();
}

class _LaminarMarginPositionsState extends State<LaminarMarginPositions> {
  int _positionTab = 0;

  @override
  Widget build(BuildContext context) {
    final Map dic = I18n.of(context).laminar;
    return Container(
      color: Theme.of(context).cardColor,
      padding: EdgeInsets.all(16),
      child: Column(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(bottom: 12),
            child: Row(
              children: <Widget>[
                OutlinedButtonSmall(
                  content: dic['margin.position'],
                  active: _positionTab == 0,
                  margin: EdgeInsets.only(right: 16),
                  onPressed: () {
                    if (_positionTab != 0) {
                      setState(() {
                        _positionTab = 0;
                      });
                    }
                  },
                ),
                OutlinedButtonSmall(
                  content: dic['margin.position.closed'],
                  active: _positionTab == 1,
                  onPressed: () {
                    if (_positionTab != 1) {
                      setState(() {
                        _positionTab = 1;
                      });
                    }
                  },
                ),
              ],
            ),
          ),
          LaminarMarginPositionQuery(
            store: widget.store,
            isClosed: _positionTab == 1,
          ),
        ],
      ),
    );
  }
}

class LaminarMarginPositionQuery extends StatelessWidget {
  LaminarMarginPositionQuery({this.isClosed = false, this.store});
  final AppStore store;
  final bool isClosed;

  final String openedPositionQuery = r'''
          subscription positionsSubscription($signer: String!) {
            Events(
              order_by: { phaseIndex: asc }
              where: {
                method: { _eq: "PositionOpened" }
                extrinsic: { result: { _eq: "ExtrinsicSuccess" }, signer: { _eq: $signer } }
              }
            ) {
              args
              block {
                timestamp
              }
              extrinsic {
                hash
              }
            }
          }
        ''';

  final String closedPositionQuery = r'''
          subscription positionsSubscription($signer: String!) {
            Events(
              order_by: { phaseIndex: asc }
              where: {
                method: { _eq: "PositionClosed" }
                extrinsic: { result: { _eq: "ExtrinsicSuccess" }, signer: { _eq: $signer } }
              }
            ) {
              args
              block {
                timestamp
              }
              extrinsic {
                hash
              }
            }
          }
        ''';

  @override
  Widget build(BuildContext context) {
    return Query(
      options: QueryOptions(
        documentNode: gql(openedPositionQuery),
        variables: <String, String>{
          'signer': '5EtWBRw2W8TaxUAW8m47dgykfRJjKN7PgBbuMppXwqCWMtVG',
        },
      ),
      builder: (
        QueryResult result, {
        Future<QueryResult> Function() refetch,
        FetchMore fetchMore,
      }) {
//        print(JsonEncoder.withIndent('  ').convert(result.data));
        return Query(
          options: QueryOptions(
            documentNode: gql(closedPositionQuery),
            variables: <String, String>{
              'signer': '5EtWBRw2W8TaxUAW8m47dgykfRJjKN7PgBbuMppXwqCWMtVG',
            },
          ),
          builder: (
            QueryResult resultClosed, {
            Future<QueryResult> Function() refetch,
            FetchMore fetchMore,
          }) {
            if (result.hasException || resultClosed.hasException) {
              return Text(result.exception.toString());
            }

            if (result.loading || resultClosed.loading) {
              return const Center(
                child: CupertinoActivityIndicator(),
              );
            }
//            print(JsonEncoder.withIndent('  ').convert(resultClosed.data));
            final List list = List.of(result.data['Events']);
            list.retainWhere((e) {
              final int positionId = e['args'][1];
              return List.of(resultClosed.data['Events']).indexWhere((c) {
                    return c['args'][1] == positionId;
                  }) <
                  0;
            });
            return Column(
              children: isClosed
                  ? List.of(resultClosed.data['Events']).map((c) {
                      final position =
                          List.of(result.data['Events']).firstWhere((e) {
                        return e['args'][1] == c['args'][1];
                      });
                      final LaminarMarginPairData pairData =
                          store.laminar.marginTokens.firstWhere((i) {
                        return i.pair.base == position['args'][3]['base'] &&
                            i.pair.quote == position['args'][3]['quote'];
                      });
                      return LaminarMarginPosition(
                        position,
                        pairData,
                        store.laminar.tokenPrices,
                        closed: c,
                        decimals: store.settings.networkState.tokenDecimals,
                      );
                    }).toList()
                  : list.map((e) {
                      final LaminarMarginPairData pairData =
                          store.laminar.marginTokens.firstWhere((i) {
                        return i.pair.base == e['args'][3]['base'] &&
                            i.pair.quote == e['args'][3]['quote'];
                      });
                      return LaminarMarginPosition(
                        e,
                        pairData,
                        store.laminar.tokenPrices,
                        decimals: store.settings.networkState.tokenDecimals,
                      );
                    }).toList(),
            );
          },
        );
      },
    );
  }
}

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

  final Map<String, String> leverageMap = {
    'Two': 'x2',
    'Three': 'x3',
    'Five': 'x5',
    'Ten': 'x10',
    'Twenty': 'x20',
  };

  String getLeverage(String str) {
    final bool isLong = RegExp(r'^Long(.*)$').hasMatch(str);
    return leverageMap[isLong ? str.substring(4) : str.substring(5)];
  }

  @override
  Widget build(BuildContext context) {
    final Map dic = I18n.of(context).laminar;
    final pair = position['args'][3];
    final String direction =
        RegExp(r'^Long(.*)$').hasMatch(position['args'][4]) ? 'long' : 'short';
    final String leverage = getLeverage(position['args'][4]);

//    final String baseToken = store.laminar.tokenPrices[position['args'][3]['base'].toString()].value;
//                final quoteToken = getTokenInfo(pair.quote);

    final String poolId = position['args'][2].toString();

    final BigInt amtInt = BigInt.parse(position['args'][5]);
    final String amt = Fmt.token(
      amtInt,
      decimals: acala_token_decimals,
    );
    final BigInt openPriceInt = BigInt.parse(position['args'][6]);
    final String openPrice = Fmt.token(
      openPriceInt,
      decimals: acala_token_decimals,
      length: 5,
    );
    final BigInt currentPriceInt = LaminarMarginTradePrice(
      decimals: decimals,
      pairData: pairData,
      priceMap: prices,
      direction: direction == 'long' ? 'short' : 'long',
    ).getTradePriceInt();
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
                child: Text('${pairData.pairId} ($leverage)'),
              ),
              isClosed
                  ? Container()
                  : OutlinedButtonSmall(
                      content: 'close',
                      onPressed: () {
                        print('close');
                      },
                    )
            ],
          ),
        ),
        Padding(
          padding: EdgeInsets.only(top: 8),
          child: Row(
            children: <Widget>[
              InfoItem(
                title: dic['margin.amount'],
                content: amt,
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      isClosed ? 'close' : dic['margin.pnl'],
                      style: TextStyle(fontSize: 12),
                    ),
                    LaminarMarginTradePnl(
                      decimals: decimals,
                      amount: amtInt,
                      openPrice: openPriceInt,
                      closePrice: isClosed ? closePriceInt : currentPriceInt,
                    )
                  ],
                ),
              ),
              InfoItem(
                title: isClosed ? 'now price' : dic['margin.price.now'],
                content: Fmt.token(
                  isClosed ? closePriceInt : currentPriceInt,
                  decimals: decimals,
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
