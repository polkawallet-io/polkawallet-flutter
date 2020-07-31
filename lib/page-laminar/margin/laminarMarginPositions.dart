import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:polka_wallet/common/components/outlinedButtonSmall.dart';
import 'package:polka_wallet/page-laminar/margin/laminarMarginPositionItem.dart';
import 'package:polka_wallet/store/app.dart';
import 'package:polka_wallet/store/laminar/types/laminarMarginData.dart';
import 'package:polka_wallet/utils/i18n/index.dart';

class LaminarMarginPositions extends StatefulWidget {
  LaminarMarginPositions(this.store);

  final AppStore store;

  @override
  _LaminarMarginPositionsState createState() => _LaminarMarginPositionsState();
}

class _LaminarMarginPositionsState extends State<LaminarMarginPositions> {
  int _positionTab = 0;

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

  void _changeTab(int tab, Future<QueryResult> Function() refetch,
      Future<QueryResult> Function() refetchClosed) {
    if (_positionTab != tab) {
      refetch();
      refetchClosed();
      setState(() {
        _positionTab = tab;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final Map dic = I18n.of(context).laminar;
    return Query(
      options: QueryOptions(
        documentNode: gql(openedPositionQuery),
        variables: <String, String>{
          'signer': widget.store.account.currentAddress,
        },
      ),
      builder: (
        QueryResult result, {
        Future<QueryResult> Function() refetch,
        FetchMore fetchMore,
      }) {
//        print(JsonEncoder.withIndent('  ').convert(result.data));
        final Future<QueryResult> Function() refreshOpened = refetch;
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

            if (result.loading ||
                resultClosed.loading ||
                widget.store.laminar.marginTokens.length == 0) {
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
              children: <Widget>[
                Container(
                  color: Theme.of(context).cardColor,
                  padding: EdgeInsets.fromLTRB(16, 16, 16, 0),
                  child: Column(
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          OutlinedButtonSmall(
                            content: dic['margin.position'],
                            active: _positionTab == 0,
                            margin: EdgeInsets.only(right: 16),
                            onPressed: () =>
                                _changeTab(0, refreshOpened, refetch),
                          ),
                          OutlinedButtonSmall(
                            content: dic['margin.position.closed'],
                            active: _positionTab == 1,
                            onPressed: () =>
                                _changeTab(1, refreshOpened, refetch),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    children: _positionTab == 1
                        ? List.of(resultClosed.data['Events']).map((c) {
                            final position =
                                List.of(result.data['Events']).firstWhere((e) {
                              return e['args'][1] == c['args'][1];
                            });
                            final LaminarMarginPairData pairData = widget
                                .store.laminar.marginTokens
                                .firstWhere((i) {
                              return i.pair.base ==
                                      position['args'][3]['base'] &&
                                  i.pair.quote == position['args'][3]['quote'];
                            });
                            return LaminarMarginPosition(
                              position,
                              pairData,
                              widget.store.laminar.tokenPrices,
                              closed: c,
                              decimals: widget
                                  .store.settings.networkState.tokenDecimals,
                            );
                          }).toList()
                        : list.map((e) {
                            final LaminarMarginPairData pairData = widget
                                .store.laminar.marginTokens
                                .firstWhere((i) {
                              return i.pair.base == e['args'][3]['base'] &&
                                  i.pair.quote == e['args'][3]['quote'];
                            });
                            return LaminarMarginPosition(
                              e,
                              pairData,
                              widget.store.laminar.tokenPrices,
                              decimals: widget
                                  .store.settings.networkState.tokenDecimals,
                            );
                          }).toList(),
                  ),
                )
              ],
            );
          },
        );
      },
    );
  }
}
