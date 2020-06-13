import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:polka_wallet/page/account/txConfirmPage.dart';
import 'package:polka_wallet/service/substrateApi/api.dart';
import 'package:polka_wallet/page/governance/democracy/referendumPanel.dart';
import 'package:polka_wallet/store/app.dart';
import 'package:polka_wallet/store/gov/types/referendumInfoData.dart';
import 'package:polka_wallet/utils/UI.dart';
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

  final String _bestNumberSubscribeChannel = 'BestNumber';

  Future<void> _fetchReferendums() async {
    if (store.settings.loading) {
      return;
    }
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
      webApi.subscribeMessage(
          'chain', 'bestNumber', [], _bestNumberSubscribeChannel, (data) {
        store.gov.setBestNumber(data as int);
      });
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      globalDemocracyRefreshKey.currentState.show();
    });
  }

  @override
  void dispose() {
    webApi.unsubscribeMessage(_bestNumberSubscribeChannel);

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Observer(
      builder: (_) {
        String symbol = store.settings.networkState.tokenSymbol;
        List<ReferendumInfo> list = store.gov.referendums;
        int bestNumber = store.gov.bestNumber;
        return RefreshIndicator(
          key: globalDemocracyRefreshKey,
          onRefresh: _fetchReferendums,
          child: list == null
              ? Container()
              : list.length == 0
                  ? Container(
                      height: 80,
                      padding: EdgeInsets.all(24),
                      child: Text(I18n.of(context).home['data.empty']),
                    )
                  : ListView.builder(
                      itemCount: list.length,
                      itemBuilder: (BuildContext context, int i) {
                        return ReferendumPanel(
                          data: list[i],
                          bestNumber: bestNumber,
                          symbol: symbol,
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
