import 'package:flutter/material.dart';
import 'package:polka_wallet/common/components/topTaps.dart';
import 'package:polka_wallet/page/governance/council.dart';
import 'package:polka_wallet/page/governance/democracy/democracy.dart';
import 'package:polka_wallet/store/app.dart';
import 'package:polka_wallet/utils/i18n/index.dart';

class Governance extends StatefulWidget {
  Governance(this.store);

  final AppStore store;

  @override
  _GovernanceState createState() => _GovernanceState(store);
}

class _GovernanceState extends State<Governance> {
  _GovernanceState(this.store);

  final AppStore store;

  int _tab = 0;

  @override
  Widget build(BuildContext context) {
    var dic = I18n.of(context).gov;
    var tabs = [dic['council'], dic['democracy']];
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Container(
          padding: EdgeInsets.only(top: 20),
          color: Colors.transparent,
          child: Column(
            children: <Widget>[
              TopTabs(
                names: tabs,
                activeTab: _tab,
                onTab: (v) {
                  setState(() {
                    if (_tab != v) {
                      _tab = v;
                    }
                  });
                },
              ),
              Expanded(
                child: _tab == 1 ? Democracy(store) : Council(store),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
