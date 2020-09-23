import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:polka_wallet/common/components/roundedButton.dart';
import 'package:polka_wallet/page/governance/council/council.dart';
import 'package:polka_wallet/store/app.dart';
import 'package:polka_wallet/utils/format.dart';
import 'package:polka_wallet/utils/i18n/index.dart';

class CandidateListPage extends StatefulWidget {
  CandidateListPage(this.store);
  static final String route = '/gov/candidates';
  final AppStore store;
  @override
  _CandidateList createState() => _CandidateList(store);
}

class _CandidateList extends State<CandidateListPage> {
  _CandidateList(this.store);
  final AppStore store;

  final List<List> _selected = List<List>();
  final List<List> _notSelected = List<List>();
  Map<String, bool> _selectedMap = Map<String, bool>();

  String _filter = '';

  @override
  void initState() {
    super.initState();

    setState(() {
      store.gov.council.members.forEach((i) {
        _notSelected.add(i);
        _selectedMap[i[0]] = false;
      });
      store.gov.council.runnersUp.forEach((i) {
        _notSelected.add(i);
        _selectedMap[i[0]] = false;
      });
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    List args = ModalRoute.of(context).settings.arguments;
    if (args.length > 0) {
      List<List> ls = List<List>.from(args);
      setState(() {
        _selected.addAll(ls);
        _notSelected
            .removeWhere((i) => ls.indexWhere((arg) => arg[0] == i[0]) > -1);
        ls.forEach((i) {
          _selectedMap[i[0]] = true;
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    var dic = I18n.of(context).gov;
    final int decimals = store.settings.networkState.tokenDecimals;
    final String symbol = store.settings.networkState.tokenSymbol;

    List<List> list = [];
    list.addAll(_selected);
    // filter the _notSelected list
    List<List> retained = List.of(_notSelected);
    retained = Fmt.filterCandidateList(
        retained, _filter, store.account.addressIndexMap);
    list.addAll(retained);

    return Scaffold(
      appBar: AppBar(
        title: Text(dic['candidate']),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Container(
              color: Theme.of(context).cardColor,
              padding: EdgeInsets.all(16),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: CupertinoTextField(
                      padding: EdgeInsets.fromLTRB(16, 6, 16, 6),
                      placeholder: I18n.of(context).staking['filter'],
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(24)),
                        border: Border.all(
                            width: 0.5, color: Theme.of(context).dividerColor),
                      ),
                      onChanged: (value) {
                        setState(() {
                          _filter = value.trim();
                        });
                      },
                    ),
                  )
                ],
              ),
            ),
            Expanded(
              child: ListView(
                children: list.map(
                  (i) {
                    Map accInfo = store.account.addressIndexMap[i[0]];
                    return CandidateItem(
                      accInfo: accInfo,
                      balance: i,
                      tokenSymbol: symbol,
                      decimals: decimals,
                      trailing: CupertinoSwitch(
                        value: _selectedMap[i[0]],
                        onChanged: (value) {
                          setState(() {
                            _selectedMap[i[0]] = value;
                          });
                          Timer(Duration(milliseconds: 300), () {
                            setState(() {
                              if (value) {
                                _selected.add(i);
                                _notSelected
                                    .removeWhere((item) => item[0] == i[0]);
                              } else {
                                _selected
                                    .removeWhere((item) => item[0] == i[0]);
                                _notSelected.add(i);
                              }
                            });
                          });
                        },
                      ),
                    );
                  },
                ).toList(),
              ),
            ),
            Container(
              padding: EdgeInsets.all(16),
              child: RoundedButton(
                text: I18n.of(context).home['ok'],
                onPressed: () => Navigator.of(context).pop(_selected),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
