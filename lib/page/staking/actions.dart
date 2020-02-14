import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:polka_wallet/store/app.dart';
import 'package:polka_wallet/utils/format.dart';
import 'package:polka_wallet/utils/i18n/index.dart';

class StakingActions extends StatefulWidget {
  StakingActions(this.store);
  final AppStore store;
  @override
  _StakingActions createState() => _StakingActions(store);
}

class _StakingActions extends State<StakingActions>
    with SingleTickerProviderStateMixin {
  _StakingActions(this.store);

  final AppStore store;

  TabController _tabController;

  int _txsPage = 1;
  bool _txsLoading = true;

  Future<void> _updateStakingTxs() async {
    setState(() {
      _txsLoading = true;
    });
    var ls = await store.api.updateStaking(_txsPage);
    print('stakings fetched');
    print(ls.length);

    setState(() {
      _txsLoading = false;
    });
  }

  Future<void> _updateStakingInfo() async {
    if (store.settings.loading) {
      return;
    }
    String acc = '["${store.account.currentAccount.address}"]';
    var res =
        await store.api.evalJavascript('api.query.staking.ledger.multi($acc)');
    store.staking.setLedger({"ledger": res[0]});
  }

  List<Widget> _buildListView() {
    final Map<String, String> dic = I18n.of(context).staking;

    final List<Tab> _myTabs = <Tab>[
      Tab(text: dic['txs']),
      Tab(text: dic['nominating']),
    ];

    List list = <Widget>[
      _buildActionCard(),
      Container(
        color: Colors.white,
        child: TabBar(
          labelColor: Colors.black87,
          labelStyle: TextStyle(fontSize: 18),
          controller: _tabController,
          tabs: _myTabs,
          onTap: (i) {
            store.assets.setTxsFilter(i);
          },
        ),
      ),
    ];
    if (_txsLoading) {
      list.add(Padding(
        padding: EdgeInsets.all(16),
        child: CupertinoActivityIndicator(),
      ));
    }
    return list;
  }

  Widget _buildActionCard() {
    String symbol = store.settings.networkState.tokenSymbol;
    String balance = store.assets.balance.split('T')[0];
    String bonded = Fmt.token(store.staking.ledger['ledger']['active'], 12);
    double avaliable = double.parse(balance) - double.parse(bonded);
    return Container(
      margin: EdgeInsets.fromLTRB(16, 8, 16, 16),
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
          borderRadius: const BorderRadius.all(const Radius.circular(8)),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 16.0, // has the effect of softening the shadow
              spreadRadius: 4.0, // has the effect of extending the shadow
              offset: Offset(
                2.0, // horizontal, move right 10
                2.0, // vertical, move down 10
              ),
            )
          ]),
      child: Column(
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              Padding(
                padding: EdgeInsets.only(left: 24, top: 8, right: 24),
                child: Image.asset('assets/images/staking/set.png'),
              ),
              Column(
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.only(bottom: 6),
                    child: Image.asset('assets/images/assets/Assets_nav_0.png'),
                  ),
                  Text(
                    'Controller',
                    style: Theme.of(context).textTheme.display4,
                  )
                ],
              ),
              Column(
                children: <Widget>[
                  Container(
                    padding: EdgeInsets.all(2),
                    width: 32,
                    child: Image.asset('assets/images/assets/Assets_nav_0.png'),
                  ),
                  Text(
                    'stash',
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.black54),
                  ),
                  Text(
                    Fmt.address(store.staking.ledger['ledger']['stash'],
                        len: 4),
                    style: TextStyle(fontSize: 12, color: Colors.black54),
                  ),
                ],
              )
            ],
          ),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
            Column(children: <Widget>[
              Padding(
                padding: EdgeInsets.all(12),
                child: Text(
                  Fmt.address(store.account.currentAccount.address),
                  style: TextStyle(color: Colors.black54),
                ),
              ),
            ]),
          ]),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[
                  Text('balance:'),
                  Text('avaliable:'),
                  Text(
                    'bonded:',
                    style: TextStyle(color: Colors.green),
                  )
                ],
              ),
              Container(
                padding: EdgeInsets.all(8),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text('$balance $symbol'),
                  Text('${avaliable.toString()} $symbol'),
                  Text(
                    '$bonded $symbol',
                    style: TextStyle(color: Colors.green),
                  )
                ],
              )
            ],
          )
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _updateStakingInfo();
    _updateStakingTxs();
    _tabController = TabController(vsync: this, length: 2);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Observer(
      builder: (_) {
        bool hasData = store.staking.ledger['ledger'] != null;
        return RefreshIndicator(
          onRefresh: _updateStakingInfo,
          child: hasData
              ? ListView(
                  children: _buildListView(),
                )
              : CupertinoActivityIndicator(),
        );
      },
    );
  }
}
