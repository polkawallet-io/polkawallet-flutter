import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:polka_wallet/common/components/roundedButton.dart';
import 'package:polka_wallet/common/components/roundedCard.dart';
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
    if (store.settings.loading) {
      return;
    }
    setState(() {
      _txsLoading = true;
    });
    await store.api.updateStaking(_txsPage);
    if (context != null) {
      setState(() {
        _txsLoading = false;
      });
    }
  }

  Future<void> _updateStakingInfo() async {
    if (store.settings.loading) {
      return;
    }
    setState(() {
      _ledgerLoading = true;
    });
    await Future.wait([
      store.api.fetchBalance(),
      store.api.fetchAccountStaking(),
    ]);
    if (context != null) {
      setState(() {
        _ledgerLoading = false;
      });
    }
  }

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

  void _showActions() {
    var dic = I18n.of(context).staking;
    bool hasData = store.staking.ledger['stakingLedger'] != null;
    List<Widget> actions = <Widget>[];
    if (hasData) {
      actions.add(CupertinoActionSheetAction(
        child: Text(dic['action.bondExtra']),
        onPressed: () => Navigator.of(context).pushNamed('/staking/bondExtra'),
      ));
      if (store.staking.ledger['stakingLedger']['active'] > 0) {
        actions.add(CupertinoActionSheetAction(
          child: Text(dic['action.unbond']),
          onPressed: () => Navigator.of(context).pushNamed('/staking/unbond'),
        ));
      }
      if (store.staking.nominatingList.length > 0) {
        actions.add(CupertinoActionSheetAction(
          child: Text(dic['action.nominee']),
          onPressed: () => Navigator.of(context).pushNamed('/staking/nominate'),
        ));
      }
      actions.add(CupertinoActionSheetAction(
        child: Text(dic['action.reward']),
        onPressed: () => Navigator.of(context).pushNamed('/staking/payee'),
      ));
    }
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) => CupertinoActionSheet(
        actions: actions,
        cancelButton: CupertinoActionSheetAction(
          child: Text(I18n.of(context).home['cancel']),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
    );
  }

  List<Widget> _buildTxList() {
    if (_txsLoading) {
      return <Widget>[
        Padding(
          padding: EdgeInsets.all(16),
          child: CupertinoActivityIndicator(),
        )
      ];
    }
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
    bool hasData = store.staking.ledger['stakingLedger'] != null;
    if (_ledgerLoading) {
      return <Widget>[
        Padding(
          padding: EdgeInsets.all(16),
          child: CupertinoActivityIndicator(),
        )
      ];
    }
    if (!hasData) {
      return <Widget>[Container()];
    }
    String symbol = store.settings.networkState.tokenSymbol;
    String address = store.account.currentAccount.address;
//    String address = 'E4ukkmqUZv1noW1sq7uqEB2UVfzFjMEM73cVSp8roRtx14n';
    return List<Widget>.from(store.staking.ledger['nominators'].map((id) {
      var validator =
          store.staking.validatorsInfo.firstWhere((i) => i.accountId == id);
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
          onTap: () {
            store.api.queryValidatorRewards(validator.accountId);
            Navigator.of(context)
                .pushNamed('/staking/validator', arguments: validator);
          },
        ),
      );
    }).toList());
  }

  Widget _buildActionCard() {
    var dic = I18n.of(context).staking;
    String symbol = store.settings.networkState.tokenSymbol;
    bool hasData = store.staking.ledger['stakingLedger'] != null;
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
              Fmt.address(store.staking.ledger['stakingLedger']['stash'],
                  pad: 4),
              style: TextStyle(fontSize: 12, color: Colors.black54),
            ),
          ],
        ),
      );
    }

    String payee = store.staking.ledger['rewardDestination'];

    int balance = Fmt.balanceInt(store.assets.balance);
    int bonded = 0;
    int unlocking = 0;
    if (hasData) {
      List unlockingList = store.staking.ledger['stakingLedger']['unlocking'];
      unlockingList.forEach((i) => unlocking += i['value']);
      bonded = store.staking.ledger['stakingLedger']['active'];
    }
    int available = balance - bonded - unlocking;

    Widget actionButton = Container();
    if (bonded == 0) {
      actionButton = Padding(
        padding: EdgeInsets.only(top: 16),
        child: RoundedButton(
          text: dic['action.bond'],
          color: Colors.pinkAccent,
          onPressed: () => Navigator.of(context).pushNamed('/staking/bond'),
        ),
      );
    } else {
      // if (bonded > 0)
      if (store.staking.ledger['nominators'].length == 0) {
        // if user is not nominating
        actionButton = Padding(
          padding: EdgeInsets.only(top: 16),
          child: RoundedButton(
            text: dic['action.nominate'],
            color: Colors.pinkAccent,
            onPressed: store.staking.validatorsInfo.length == 0
                ? null
                : () => Navigator.of(context).pushNamed('/staking/nominate'),
          ),
        );
      } else {
        actionButton = Padding(
          padding: EdgeInsets.only(top: 16),
          child: RoundedButton(
            text: dic['action.chill'],
            color: Colors.pinkAccent,
            onPressed: _chill,
          ),
        );
      }
    }
    return RoundedCard(
      margin: EdgeInsets.fromLTRB(16, 8, 16, 16),
      padding: EdgeInsets.all(24),
      child: Column(
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              Container(
                width: stashWidgetWidth,
                height: 36,
                child: IconButton(
                  icon: Image.asset('assets/images/staking/set.png'),
                  onPressed: _showActions,
                ),
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(dic['balance']),
                  Text(dic['available']),
                  unlocking > 0 ? Text(dic['unlocking']) : Container(),
                  payee != null ? Text(dic['bond.reward']) : Container(),
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
                  unlocking > 0
                      ? Text('${Fmt.token(unlocking)} $symbol')
                      : Container(),
                  payee != null ? Text(payee) : Container(),
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
          actionButton
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
    final Map<String, String> dic = I18n.of(context).staking;

    final List<Tab> _myTabs = <Tab>[
      Tab(text: dic['txs']),
      Tab(text: dic['nominating']),
    ];

    return Observer(
      builder: (_) {
        List<Widget> list = <Widget>[
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
        bool hasData = store.staking.ledger['stakingLedger'] != null;
        return RefreshIndicator(
          onRefresh: () async {
            _updateStakingTxs();
            await _updateStakingInfo();
          },
          child: !hasData && _ledgerLoading
              ? CupertinoActivityIndicator()
              : ListView(
                  children: list,
                ),
        );
      },
    );
  }
}
