import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:polka_wallet/page/governance/council.dart';
import 'package:polka_wallet/store/app.dart';
import 'package:polka_wallet/utils/format.dart';
import 'package:polka_wallet/utils/i18n/index.dart';

class CandidateList extends StatefulWidget {
  CandidateList(this.store);
  final AppStore store;
  @override
  _CandidateList createState() => _CandidateList(store);
}

class _CandidateList extends State<CandidateList> {
  _CandidateList(this.store);
  final AppStore store;

  final List<List<String>> _selected = List<List<String>>();
  final List<List<String>> _notSelected = List<List<String>>();
  Map<String, bool> _selectedMap = Map<String, bool>();

  String _filter = '';
  int _sort = 0;

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
  Widget build(BuildContext context) {
    var dic = I18n.of(context).gov;

    List<List<String>> list = [];
    list.addAll(_selected);
    // filter the _notSelected list
    List<List<String>> retained = List.of(_notSelected);
    retained = Fmt.filterCandidateList(
        retained, _filter, store.account.accountIndexMap);
    list.addAll(retained);

    return Scaffold(
      appBar: AppBar(
        title: Text(dic['candidate']),
        centerTitle: true,
      ),
      body: ListView.builder(
          itemCount: list.length,
          itemBuilder: (BuildContext context, int i) {
            Map accInfo = store.account.accountIndexMap[list[i][0]];
            return CandidateItem(
              accInfo: accInfo,
              balance: list[i],
              tokenSymbol: store.settings.networkState.tokenSymbol,
            );
          }),
    );
  }
}
