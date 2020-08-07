import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:polka_wallet/common/components/listTail.dart';
import 'package:polka_wallet/page/account/txConfirmPage.dart';
import 'package:polka_wallet/service/substrateApi/api.dart';
import 'package:polka_wallet/page/governance/democracy/referendumPanel.dart';
import 'package:polka_wallet/store/app.dart';
import 'package:polka_wallet/store/gov/types/referendumInfoData.dart';
import 'package:polka_wallet/utils/UI.dart';
import 'package:polka_wallet/utils/format.dart';
import 'package:polka_wallet/utils/i18n/index.dart';

class Democracy extends StatefulWidget {
  Democracy(this.store);

  final AppStore store;
  @override
  _DemocracyState createState() => _DemocracyState(store);
}

class _DemocracyState extends State<Democracy> {
  _DemocracyState(this.store);

  final AppStore store;

  Future<void> _fetchReferendums() async {
    if (store.settings.loading) {
      return;
    }
    webApi.gov.getReferendumVoteConvictions();
    await webApi.gov.fetchReferendums();
  }

  Future<void> _submitCancelVote(int id) async {
    var govDic = I18n.of(context).gov;
    var args = {
      "title": govDic['vote.remove'],
      "txInfo": {
        "module": 'democracy',
        "call": 'removeVote',
      },
      "detail": jsonEncode({"id": id}),
      "params": [id],
      'onFinish': (BuildContext txPageContext, Map res) {
        Navigator.popUntil(txPageContext, ModalRoute.withName('/'));
        globalDemocracyRefreshKey.currentState.show();
      }
    };
    Navigator.of(context).pushNamed(TxConfirmPage.route, arguments: args);
  }

  @override
  void initState() {
    super.initState();
    if (!store.settings.loading) {
      webApi.subscribeBestNumber((data) {
        store.gov.setBestNumber(data as int);
      });
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      globalDemocracyRefreshKey.currentState.show();
    });
  }

  @override
  void dispose() {
    webApi.unsubscribeBestNumber();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Observer(
      builder: (_) {
        final int decimals = store.settings.networkState.tokenDecimals;
        final String symbol = store.settings.networkState.tokenSymbol;
        final String tokenView = Fmt.tokenView(
          symbol,
          decimalsDot: decimals,
          network: store.settings.endpoint.info,
        );
        List<ReferendumInfo> list = store.gov.referendums;
        int bestNumber = store.gov.bestNumber;
        return RefreshIndicator(
          key: globalDemocracyRefreshKey,
          onRefresh: _fetchReferendums,
          child: list == null || list.length == 0
              ? Center(child: ListTail(isEmpty: true, isLoading: false))
              : ListView.builder(
                  itemCount: list.length + 1,
                  itemBuilder: (BuildContext context, int i) {
                    return i == list.length
                        ? Center(
                            child: ListTail(
                            isEmpty: false,
                            isLoading: false,
                          ))
                        : ReferendumPanel(
                            data: list[i],
                            bestNumber: bestNumber,
                            symbol: tokenView,
                            onCancelVote: _submitCancelVote,
                            blockDuration: store.settings.networkConst['babe']
                                ['expectedBlockTime'],
                          );
                  },
                ),
        );
      },
    );
  }
}
