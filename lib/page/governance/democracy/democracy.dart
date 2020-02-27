import 'dart:convert';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:polka_wallet/page/governance/democracy/referendumPanel.dart';
import 'package:polka_wallet/store/app.dart';
import 'package:polka_wallet/store/governance.dart';
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

  bool _isLoading = true;

  Future<void> _fetchReferendums() async {
    setState(() {
      _isLoading = true;
    });
    await store.api.fetchReferendums();
    setState(() {
      _isLoading = false;
    });
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

  void _showSelections(int id, bool yes) {
    final Map dic = I18n.of(context).gov;
    print(yes);

    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) => CupertinoActionSheet(
        title: Text(yes ? 'y' : 'n'),
        actions: List<Widget>.from(_options.map((i) {
          List times = _calcTimes(i);
          String days = i == 0
              ? 'no'
              : '${'locked for'} ${times[1] * 8} days (${times[1]}x)';
          Map options = {'aye': yes, 'conviction': i};
          var args = {
            "title": dic['vote'],
            "detail": jsonEncode({
              "id": id,
              "options": options,
            }),
            "params": {
              "module": 'democracy',
              "call": 'vote',
              "id": id,
              "options": options
            },
            'redirect': '/'
          };
          return CupertinoActionSheetAction(
            child: Text(
              '${times[0]}x balance, $days',
            ),
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context)
                  .pushNamed('/staking/confirm', arguments: args);
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
    _fetchReferendums();
  }

  @override
  Widget build(BuildContext context) {
    final Map dic = I18n.of(context).gov;
    String symbol = store.settings.networkState.tokenSymbol;
    List<ReferendumInfo> list = store.gov.referendums;
    return Observer(
      builder: (_) {
        int bestNumber = store.gov.bestNumber;
        return RefreshIndicator(
          onRefresh: _fetchReferendums,
          child: ListView.builder(
            itemCount: list.length,
            itemBuilder: (BuildContext context, int i) {
              return ReferendumPanel(
                data: list[i],
                bestNumber: bestNumber,
                votes: store.gov.referendumVotes[list[i].index],
                symbol: symbol,
                onVote: (id, yes) => _showSelections(id, yes),
              );
            },
          ),
        );
      },
    );
  }
}
