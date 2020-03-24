import 'dart:convert';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:polka_wallet/page/account/txConfirmPage.dart';
import 'package:polka_wallet/service/substrateApi/api.dart';
import 'package:polka_wallet/page/governance/democracy/referendumPanel.dart';
import 'package:polka_wallet/store/app.dart';
import 'package:polka_wallet/store/governance.dart';
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

  final _options = [0, 1, 2, 3, 4, 5, 6];

  Future<void> _fetchReferendums() async {
    if (store.settings.loading) {
      return;
    }
    webApi.gov.updateDemocracyVotes(store.account.currentAddress);
    await webApi.gov.fetchReferendums();
  }

  List<num> _calcTimes(int value) {
    double amountX = 0.1;
    int timeX = 0;
    if (value > 0) {
      amountX = value * 1.0;
      timeX = pow(2, value - 1);
    }
    return [amountX, timeX];
  }

  void _onVote(int id, bool yes) {
    final Map dic = I18n.of(context).gov;
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) => CupertinoActionSheet(
        title: Text(yes ? dic['yes.text'] : dic['no.text']),
        actions: List<Widget>.from(_options.map((i) {
          Map options = {'aye': yes, 'conviction': i};
          var args = {
            "title": dic['vote.proposal'],
            "txInfo": {
              "module": 'democracy',
              "call": 'vote',
            },
            "detail": jsonEncode({
              "id": id,
              "options": options,
            }),
            "params": [
              // "id"
              id,
              // "options"
              options
            ],
            'onFinish': (BuildContext txPageContext) {
              Navigator.popUntil(txPageContext, ModalRoute.withName('/'));
              globalDemocracyRefreshKey.currentState.show();
            }
          };
          List times = _calcTimes(i);
          String days = i == 0
              ? dic['locked.no']
              : '${dic['locked']} ${times[1] * 8} ${dic['day']} (${times[1]}x)';
          return CupertinoActionSheetAction(
            child: Text(
              '${times[0]}x ${dic['balance']}, $days',
            ),
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context)
                  .pushNamed(TxConfirmPage.route, arguments: args);
            },
          );
        })),
        cancelButton: CupertinoActionSheetAction(
          child: Text(I18n.of(context).home['cancel']),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    webApi.subscribeBestNumber();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (store.gov.referendums == null) {
        globalDemocracyRefreshKey.currentState.show();
      }
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
                      child: Text(
                        I18n.of(context).home['data.empty'],
                        style: Theme.of(context).textTheme.display4,
                      ),
                    )
                  : ListView.builder(
                      itemCount: list.length,
                      itemBuilder: (BuildContext context, int i) {
                        return ReferendumPanel(
                          data: list[i],
                          bestNumber: bestNumber,
                          votes: list[i].votes,
                          symbol: symbol,
                          voted: store.gov.votedMap[list[i].index],
                        );
                      },
                    ),
        );
      },
    );
  }
}
