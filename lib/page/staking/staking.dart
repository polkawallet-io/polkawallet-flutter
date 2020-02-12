import 'package:flutter/material.dart';
import 'package:polka_wallet/page/staking/actions.dart';
import 'package:polka_wallet/page/staking/overview.dart';
import 'package:polka_wallet/service/api.dart';

import 'package:polka_wallet/store/staking.dart';
import 'package:polka_wallet/utils/i18n/index.dart';

class Staking extends StatefulWidget {
  Staking(this.api, this.store);

  final Api api;
  final StakingStore store;

  @override
  _StakingState createState() => _StakingState(api, store);
}

class _StakingState extends State<Staking> {
  _StakingState(this.api, this.store);

  final Api api;
  final StakingStore store;

  int _tab = 0;

  Future<void> _fetchControllers() async {
    var res = await api.evalJavascript('api.derive.staking.controllers()');
    store.setOverview({"intentions": res[0]});
  }

  Future<void> _fetchElectedInfo() async {
    var res = await api.evalJavascript('api.derive.staking.electedInfo()');
    store.setOverview({"elected": res});
  }

  Future<void> _fetchOverviewInfo() async {
    var data = await Future.wait([
      api.evalJavascript('api.derive.staking.overview()'),
      api.evalJavascript('api.derive.session.info()'),
    ]);
    var overview = data[0];
    overview['session'] = data[1];
    print(overview.keys.join(','));
    store.setOverview(overview);
    print('overview set');
//    overview.keys.forEach((key) => print(store.overview[key]));
    _fetchControllers();
    _fetchElectedInfo();
  }

  List<Widget> _buildTabs() {
    var dic = I18n.of(context).staking;
    var tabs = [dic['actions'], dic['overview']];
    return tabs.map(
      (title) {
        var index = tabs.indexOf(title);
        return GestureDetector(
          child: Column(
            children: <Widget>[
              Container(
                width: 160,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      title,
                      style: TextStyle(fontSize: 18, color: Colors.white),
                    )
                  ],
                ),
              ),
              Container(
                height: 16,
                width: 32,
                decoration: BoxDecoration(
                  border: Border(
                      bottom: BorderSide(
                          width: _tab == index ? 3 : 0, color: Colors.white)),
                ),
              )
            ],
          ),
          onTap: () {
            if (_tab != index) {
              if (index == 1) {
                _fetchOverviewInfo();
//                _fetchControllers();
              }
              setState(() {
                _tab = index;
              });
            }
          },
        );
      },
    ).toList();
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: Colors.transparent,
        body: Container(
          color: Colors.transparent,
          child: Column(
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: _buildTabs(),
              ),
              Expanded(
                child:
                    _tab == 1 ? StakingOverview(api, store) : StakingActions(),
              ),
            ],
          ),
        ),
      );
}
