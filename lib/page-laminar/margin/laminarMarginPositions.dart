import 'dart:async';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:polka_wallet/common/components/listTail.dart';
import 'package:polka_wallet/common/components/outlinedButtonSmall.dart';
import 'package:polka_wallet/page-laminar/margin/laminarMarginPage.dart';
import 'package:polka_wallet/page-laminar/margin/laminarMarginPositionItem.dart';
import 'package:polka_wallet/store/app.dart';
import 'package:polka_wallet/store/laminar/types/laminarCurrenciesData.dart';
import 'package:polka_wallet/store/laminar/types/laminarMarginData.dart';
import 'package:polka_wallet/utils/i18n/index.dart';

class LaminarMarginPageWrapper extends StatefulWidget {
  LaminarMarginPageWrapper(this.store);

  static const String route = '/laminar/margin';
  final AppStore store;

  @override
  _LaminarMarginPageWrapperState createState() =>
      _LaminarMarginPageWrapperState();
}

class _LaminarMarginPageWrapperState extends State<LaminarMarginPageWrapper> {
  int _positionTab = 0;

  final String openedPositionQuery = r'''
          subscription positionsSubscription($signer: String!) {
            Events(
              order_by: { phaseIndex: desc }
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
          subscription positionsSubscription($signer: jsonb!) {
            Events(
              order_by: { phaseIndex: desc }
              where: {
                method: { _eq: "PositionClosed" }
                args: { _contains: $signer }
                extrinsic: { result: { _eq: "ExtrinsicSuccess" } }
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

  LaminarMarginPairData _getPairData(Map position) {
    final int pairIndex = widget.store.laminar.marginTokens.indexWhere((i) {
      return i.poolId == position['args'][2].toString() &&
          i.pair.base == position['args'][3]['base'] &&
          i.pair.quote == position['args'][3]['quote'];
    });
    if (pairIndex < 0) {
      return null;
    }
    return widget.store.laminar.marginTokens[pairIndex];
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
              'signer': widget.store.account.currentAddress,
            },
          ),
          builder: (
            QueryResult resultClosed, {
            Future<QueryResult> Function() refetch,
            FetchMore fetchMore,
          }) {
            return Observer(
              builder: (_) {
                final Map<String, LaminarPriceData> priceMap =
                    widget.store.laminar.tokenPrices;
                Widget render;
                if (result.hasException || resultClosed.hasException) {
                  render = Text(result.exception.toString());
                } else if (result.loading ||
                    resultClosed.loading ||
                    widget.store.laminar.marginTokens.length == 0) {
                  render = const Center(
                    child: CupertinoActivityIndicator(),
                  );
                } else {
//            print(JsonEncoder.withIndent('  ').convert(resultClosed.data));
                  final List listAll = List.of(result.data['Events']);
                  final List list = List.of(result.data['Events']);
                  list.retainWhere((e) {
                    final int positionId = e['args'][1];
                    return List.of(resultClosed.data['Events']).indexWhere((c) {
                          return c['args'][1] == positionId;
                        }) <
                        0;
                  });
                  final List listClosed = List.of(resultClosed.data['Events']);
                  render = Column(
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
                              ? listAll.length == 0 || listClosed.length == 0
                                  ? <Widget>[
                                      ListTail(
                                        isEmpty: true,
                                        isLoading: false,
                                      )
                                    ]
                                  : listClosed.reversed.map((c) {
                                      final positionIndex =
                                          listAll.indexWhere((e) {
                                        return e['args'][1] == c['args'][1];
                                      });
                                      if (positionIndex < 0) {
                                        return Container();
                                      }
                                      final position = listAll[positionIndex];
                                      final LaminarMarginPairData pairData =
                                          _getPairData(position);
                                      return LaminarMarginPosition(
                                        position,
                                        pairData,
                                        priceMap,
                                        closed: c,
                                        decimals: widget.store.settings
                                            .networkState.tokenDecimals,
                                      );
                                    }).toList()
                              : list.length == 0
                                  ? <Widget>[
                                      ListTail(
                                        isEmpty: true,
                                        isLoading: false,
                                      )
                                    ]
                                  : list.map((e) {
                                      final LaminarMarginPairData pairData =
                                          _getPairData(e);
                                      return LaminarMarginPosition(
                                        e,
                                        pairData,
                                        priceMap,
                                        decimals: widget.store.settings
                                            .networkState.tokenDecimals,
                                      );
                                    }).toList(),
                        ),
                      )
                    ],
                  );
                }
                return LaminarMarginPage(
                  widget.store,
                  onRefresh: () {
                    Timer(Duration(seconds: 5), () {
                      refreshOpened();
                      refetch();
                    });
                  },
                  child: render,
                );
              },
            );
          },
        );
      },
    );
  }
}
