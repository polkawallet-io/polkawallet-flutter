import 'dart:async';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:polka_wallet/common/components/roundedButton.dart';
import 'package:polka_wallet/common/components/validatorListFilter.dart';
import 'package:polka_wallet/store/app.dart';
import 'package:polka_wallet/store/staking.dart';
import 'package:polka_wallet/utils/format.dart';
import 'package:polka_wallet/utils/i18n/index.dart';

class Nominate extends StatefulWidget {
  Nominate(this.store);
  final AppStore store;
  @override
  _NominateState createState() => _NominateState(store);
}

class _NominateState extends State<Nominate> {
  _NominateState(this.store);
  final AppStore store;

  final List<ValidatorData> _selected = List<ValidatorData>();
  final List<ValidatorData> _notSelected = List<ValidatorData>();
  Map<String, bool> _selectedMap = Map<String, bool>();

  String _filter = '';
  int _sort = 0;

  void _chill() {
    var dic = I18n.of(context).staking;
    var args = {
      "title": dic['action.chill'],
      "detail": 'chill',
      "params": {
        "module": 'staking',
        "call": 'chill',
      },
      'redirect': '/'
    };
    Navigator.of(context).pushNamed('/staking/confirm', arguments: args);
  }

  void _setNominee() {
    var dic = I18n.of(context).staking;
    List<String> targets = _selected.map((i) => i.accountId).toList();

    var args = {
      "title": dic['action.nominate'],
      "detail": jsonEncode({
        "targets": targets.join(', '),
      }),
      "params": {
        "module": 'staking',
        "call": 'nominate',
        "targets": targets,
      },
      'redirect': '/'
    };
    Navigator.of(context).pushNamed('/staking/confirm', arguments: args);
  }

  Widget _buildListItem(BuildContext context, int i, List<ValidatorData> list) {
    Map accInfo = store.account.accountIndexMap[list[i].accountId];

    return ListTile(
      leading: Image.asset('assets/images/assets/Assets_nav_0.png'),
      title: Text(accInfo != null
          ? accInfo['identity']['display'] != null
              ? accInfo['identity']['display'].toString().toUpperCase()
              : accInfo['accountIndex']
          : Fmt.address(list[i].accountId, pad: 6)),
      subtitle: Text(
          '${I18n.of(context).staking['total']}: ${Fmt.token(list[i].total)}'),
      trailing: CupertinoSwitch(
        value: _selectedMap[list[i].accountId],
        onChanged: (bool value) {
          setState(() {
            _selectedMap[list[i].accountId] = value;
          });
          Timer(Duration(milliseconds: 500), () {
            setState(() {
              if (value) {
                _selected.add(list[i]);
                _notSelected
                    .removeWhere((item) => item.accountId == list[i].accountId);
              } else {
                _selected
                    .removeWhere((item) => item.accountId == list[i].accountId);
                _notSelected.add(list[i]);
              }
            });
          });
        },
      ),
      onTap: () => Navigator.of(context)
          .pushNamed('/staking/validator', arguments: list[i]),
    );
  }

  @override
  void initState() {
    super.initState();

    setState(() {
      store.staking.validatorsInfo.forEach((i) {
        _notSelected.add(i);
        _selectedMap[i.accountId] = false;
      });
      store.staking.nominatingList.forEach((i) {
        _selected.add(i);
        _notSelected.removeWhere((item) => item.accountId == i.accountId);
        _selectedMap[i.accountId] = true;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    var dic = I18n.of(context).staking;

    List<ValidatorData> list = [];
    list.addAll(_selected);
    // filter the _notSelected list
    List<ValidatorData> retained = List.of(_notSelected);
    retained = Fmt.filterValidatorList(
        retained, _filter, store.account.accountIndexMap);
    // and sort it
    retained.sort((a, b) => Fmt.sortValidatorList(a, b, _sort));
    list.addAll(retained);

    return Scaffold(
      appBar: AppBar(
        title: Text(dic['action.nominate']),
        centerTitle: true,
      ),
      body: Builder(builder: (BuildContext context) {
        return Container(
          color: Theme.of(context).cardColor,
          child: Column(
            children: <Widget>[
              Padding(
                padding: EdgeInsets.only(top: 8, bottom: 8),
                child: ValidatorListFilter(
                  onFilterChange: (v) {
                    if (_filter != v) {
                      setState(() {
                        _filter = v;
                      });
                    }
                  },
                  onSortChange: (v) {
                    if (_sort != v) {
                      setState(() {
                        _sort = v;
                      });
                    }
                  },
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: list.length,
                  itemBuilder: (BuildContext context, int i) {
                    return _buildListItem(context, i, list);
                  },
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(16, 8, 16, 32),
                child: RoundedButton(
                  text: I18n.of(context).home['submit.tx'],
                  onPressed: _selected.length == 0 ? _chill : _setNominee,
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}
