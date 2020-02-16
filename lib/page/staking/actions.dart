import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:polka_wallet/store/app.dart';
import 'package:polka_wallet/store/assets.dart';
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
  int _tab = 0;

  int _txsPage = 1;
  bool _ledgerLoading = true;
  bool _txsLoading = true;

  Future<void> _updateStakingTxs() async {
    setState(() {
      _txsLoading = true;
    });
    await store.api.updateStaking(_txsPage);
    setState(() {
      _txsLoading = false;
    });
  }

  Future<void> _updateStakingInfo() async {
    if (store.settings.loading) {
      return;
    }
    setState(() {
      _ledgerLoading = true;
    });
    String acc = '["${store.account.currentAccount.address}"]';
    var res =
        await store.api.evalJavascript('api.query.staking.ledger.multi($acc)');
    store.staking.setLedger({"ledger": res[0]});
    setState(() {
      _ledgerLoading = false;
    });
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
            setState(() {
              _tab = i;
            });
          },
        ),
      ),
    ];
    if (_tab == 0) {
      list.addAll(_buildTxList());
    }
    if (_tab == 1) {
      list.addAll(_buildNominatingList());
    }
    if (_txsLoading) {
      list.add(Padding(
        padding: EdgeInsets.all(16),
        child: CupertinoActivityIndicator(),
      ));
    }
    return list;
  }

  List<Widget> _buildTxList() {
    return store.staking.txs.map((i) {
      String call = i['attributes']['call_id'];
      String value = '';
      bool success = i['detail']['success'] > 0;
      switch (call) {
        case 'bond':
          value = Fmt.token(i['detail']['params'][1]['value']);
          break;
        case 'bond_extra':
        case 'unbond':
          value = Fmt.token(i['detail']['params'][0]['value']);
          break;
      }
      BlockData block = store.assets.blockMap[i['attributes']['block_id']];
      String time = 'time';
      if (block != null) {
        time = block.time.toString().split('.')[0];
      }
      return Container(
        color: Theme.of(context).cardColor,
        child: ListTile(
          leading: Padding(
            padding: EdgeInsets.only(top: 4),
            child: success
                ? Image.asset('assets/images/staking/ok.png')
                : Image.asset('assets/images/staking/error.png'),
          ),
          title: Text(call),
          subtitle: Text(time),
          trailing: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                value,
                style: Theme.of(context).textTheme.display4,
              ),
              success
                  ? Text(
                      'Success',
                      style: TextStyle(color: Colors.green),
                    )
                  : Text(
                      'Failed',
                      style: TextStyle(color: Colors.pink),
                    )
            ],
          ),
          onTap: () {
            Navigator.of(context).pushNamed('/staking/tx', arguments: i);
          },
        ),
      );
    }).toList();
  }

  List<Widget> _buildNominatingList() {
    String symbol = store.settings.networkState.tokenSymbol;
//    String address = store.account.currentAccount.address;
    String address = 'E4ukkmqUZv1noW1sq7uqEB2UVfzFjMEM73cVSp8roRtx14n';
    return store.staking.nominatingList.map((validator) {
      var me = validator.nominators.firstWhere((i) => i['who'] == address);
      return Container(
        color: Theme.of(context).cardColor,
        child: ListTile(
          leading: Image.asset('assets/images/assets/Assets_nav_0.png'),
          title: Text('${Fmt.token(me['value'])} $symbol'),
          subtitle: Text(Fmt.address(validator.accountId)),
          trailing: Container(
            width: 120,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text('commission'),
                Text(validator.commission)
              ],
            ),
          ),
          onTap: () => Navigator.of(context)
              .pushNamed('/staking/validator', arguments: validator),
        ),
      );
    }).toList();
  }

  Widget _buildActionCard() {
    var dic = I18n.of(context).staking;
    String symbol = store.settings.networkState.tokenSymbol;
    bool hasData = store.staking.ledger['ledger'] != null;
    double stashWidgetWidth = MediaQuery.of(context).size.width / 4;
    Widget stashAcc = Container(width: stashWidgetWidth);
    if (hasData) {
      stashAcc = Container(
        width: stashWidgetWidth,
        child: Column(
          children: <Widget>[
            Container(
              padding: EdgeInsets.all(2),
              width: 32,
              child: Image.asset('assets/images/assets/Assets_nav_0.png'),
            ),
            Text(
              dic['stash'],
              style:
                  TextStyle(fontWeight: FontWeight.bold, color: Colors.black54),
            ),
            Text(
              Fmt.address(store.staking.ledger['ledger']['stash'], pad: 4),
              style: TextStyle(fontSize: 12, color: Colors.black54),
            ),
          ],
        ),
      );
    }

    int balance = Fmt.balanceInt(store.assets.balance);
    int bonded = hasData ? store.staking.ledger['ledger']['active'] : 0;
    int available = balance - bonded;
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
              Container(
                width: stashWidgetWidth,
                height: 36,
                child: Image.asset('assets/images/staking/set.png'),
              ),
              Column(
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.only(bottom: 6),
                    child: Image.asset('assets/images/assets/Assets_nav_0.png'),
                  ),
                  Text(
                    dic['controller'],
                    style: Theme.of(context).textTheme.display4,
                  )
                ],
              ),
              stashAcc
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
                  Text(dic['balance']),
                  Text(dic['available']),
                  bonded > 0
                      ? Text(
                          dic['bonded'],
                          style: TextStyle(color: Colors.green),
                        )
                      : Container()
                ],
              ),
              Container(
                padding: EdgeInsets.all(8),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text('${Fmt.balance(balance.toString())} $symbol'),
                  Text('${Fmt.balance(available.toString())} $symbol'),
                  bonded > 0
                      ? Text(
                          '${Fmt.balance(bonded.toString())} $symbol',
                          style: TextStyle(color: Colors.green),
                        )
                      : Container()
                ],
              )
            ],
          ),
          Row(
            children: <Widget>[
              Expanded(
                child: RaisedButton(
                  color: Colors.green,
                  child: Text(
                    'stake',
                    style: Theme.of(context).textTheme.button,
                  ),
                  onPressed: () => print('stake'),
                ),
              ),
              Container(
                width: 16,
              ),
              Expanded(
                child: RaisedButton(
                  color: Colors.pink,
                  child: Text(
                    'stake2',
                    style: Theme.of(context).textTheme.button,
                  ),
                  onPressed: () => print('stake2'),
                ),
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
        return RefreshIndicator(
          onRefresh: _updateStakingInfo,
          child: _ledgerLoading
              ? CupertinoActivityIndicator()
              : ListView(
                  children: _buildListView(),
                ),
        );
      },
    );
  }
}
