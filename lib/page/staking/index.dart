import 'package:flutter/material.dart';
import 'package:polka_wallet/common/components/topTaps.dart';
import 'package:polka_wallet/page/staking/actions/actions.dart';
import 'package:polka_wallet/page/staking/validators/overview.dart';
import 'package:polka_wallet/store/app.dart';
import 'package:polka_wallet/utils/i18n/index.dart';

class Staking extends StatefulWidget {
  Staking(this.store);

  final AppStore store;

  @override
  _StakingState createState() => _StakingState(store);
}

class _StakingState extends State<Staking> {
  _StakingState(this.store);

  final AppStore store;

  int _tab = 0;

  @override
  Widget build(BuildContext context) {
    var dic = I18n.of(context).staking;
    var tabs = [dic['actions'], dic['validators']];

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
                  if (_tab != v) {
                    setState(() {
                      _tab = v;
                    });
                  }
                },
              ),
              Expanded(
                child: _tab == 1
                    ? StakingOverviewPage(store)
                    : StakingActions(store),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
