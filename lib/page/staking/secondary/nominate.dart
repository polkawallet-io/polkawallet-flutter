import 'dart:async';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:polka_wallet/store/app.dart';
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

  List<String> _selected = List<String>();
  List<String> _notSelected = List<String>();
  Map<String, bool> _selectedMap = Map<String, bool>();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    setState(() {
      store.staking.validatorsInfo.forEach((i) {
        _notSelected.add(i.accountId);
        _selectedMap[i.accountId] = false;
      });
      store.staking.nominatingList.forEach((i) {
        _selected.add(i.accountId);
        _notSelected.remove(i.accountId);
        _selectedMap[i.accountId] = true;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    var dic = I18n.of(context).staking;

    var list = [];
    list.addAll(_selected);
    list.addAll(_notSelected);
    List<Widget> ls = list.map((i) {
      // don't route to validator detail page here,
      // it will reset _selected list state.
      return ListTile(
        leading: Image.asset('assets/images/assets/Assets_nav_0.png'),
        title: Text(Fmt.address(i)),
        trailing: CupertinoSwitch(
          value: _selectedMap[i],
          onChanged: (bool value) {
            setState(() {
              _selectedMap[i] = value;
            });
            Timer(Duration(milliseconds: 500), () {
              setState(() {
                if (value) {
                  _selected.add(i);
                  _notSelected.remove(i);
                } else {
                  _selected.remove(i);
                  _notSelected.add(i);
                }
              });
            });
          },
        ),
      );
    }).toList();
    return Scaffold(
      appBar: AppBar(
        title: Text(dic['action.nominate']),
        centerTitle: true,
      ),
      body: Builder(builder: (BuildContext context) {
        return Column(
          children: <Widget>[
            Expanded(
              child: ListView(
                children: ls,
              ),
            ),
            Row(
              children: <Widget>[
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(16, 8, 16, 16),
                    child: RaisedButton(
                      color: Colors.pink,
                      padding: EdgeInsets.all(16),
                      child: Text(
                        I18n.of(context).home['submit.tx'],
                        style: TextStyle(color: Colors.white),
                      ),
                      onPressed: _selected.length == 0
                          ? null
                          : () {
                              List<String> targets = List<String>();
                              targets.addAll(_selected);
                              var args = {
                                "title": dic['action.nominate'],
                                "detail": jsonEncode({
                                  "targets": _selected.join(','),
                                }),
                                "params": {
                                  "module": 'staking',
                                  "call": 'nominate',
                                  "targets": targets,
                                },
                                'redirect': '/'
                              };
                              Navigator.of(context).pushNamed(
                                  '/staking/confirm',
                                  arguments: args);
                            },
                    ),
                  ),
                ),
              ],
            )
          ],
        );
      }),
    );
  }
}
