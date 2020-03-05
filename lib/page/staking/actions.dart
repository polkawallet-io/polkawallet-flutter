import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:polka_wallet/service/substrateApi/api.dart';
import 'package:polka_wallet/common/components/BorderedTitle.dart';
import 'package:polka_wallet/common/components/addressIcon.dart';
import 'package:polka_wallet/common/components/outlinedCircle.dart';
import 'package:polka_wallet/common/components/roundedCard.dart';
import 'package:polka_wallet/store/app.dart';
import 'package:polka_wallet/store/assets.dart';
import 'package:polka_wallet/utils/UI.dart';
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

  int _txsPage = 1;

  bool _txsLoading = true;

  Future<void> _updateStakingTxs() async {
    if (store.settings.loading) {
      return;
    }
    setState(() {
      _txsLoading = true;
    });
    await webApi.staking.updateStaking(_txsPage);
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
    String address = store.account.currentAddress;
    await Future.wait([
      webApi.assets.fetchBalance(address),
      webApi.staking.fetchAccountStaking(address),
    ]);
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
    if (store.staking.txs.length == 0) {
      return <Widget>[
        Container(
          color: Theme.of(context).cardColor,
          padding: EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                I18n.of(context).home['data.empty'],
                style: TextStyle(color: Colors.black54),
              )
            ],
          ),
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

  Widget _buildActionCard() {
    var dic = I18n.of(context).staking;
    String symbol = store.settings.networkState.tokenSymbol;
    bool hasData = store.staking.ledger['stakingLedger'] != null;
    String accIndex;
    Map accInfo = store.account.accountIndexMap[store.account.currentAddress];
    if (accInfo != null) {
      accIndex = accInfo['accountIndex'];
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

    num actionButtonWidth = MediaQuery.of(context).size.width / 4;
    Color actionButtonColor = Theme.of(context).primaryColor;
    Color disabledColor = Theme.of(context).disabledColor;

    return RoundedCard(
      margin: EdgeInsets.fromLTRB(16, 12, 16, 24),
      padding: EdgeInsets.all(16),
      child: Column(
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Container(
                margin: EdgeInsets.only(right: 16),
                child: AddressIcon(
                  address: store.account.currentAddress,
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      store.account.currentAccount.name,
                      style: Theme.of(context).textTheme.display4,
                    ),
                    Text(accIndex != null
                        ? accIndex
                        : Fmt.address(store.account.currentAddress))
                  ],
                ),
              ),
              Container(
                width: 80,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      '${Fmt.balance(balance.toString())}',
                      style: Theme.of(context).textTheme.display4,
                    ),
                    Text(
                      dic['balance'],
                    ),
                  ],
                ),
              )
            ],
          ),
          Container(height: 8),
          Divider(),
          Row(
            children: <Widget>[
              InfoItem(
                title: dic['available'],
                content: Fmt.balance(available.toString()),
                crossAxisAlignment: CrossAxisAlignment.center,
              ),
              InfoItem(
                title: dic['bonded'],
                content: Fmt.balance(bonded.toString()),
                crossAxisAlignment: CrossAxisAlignment.center,
              ),
            ],
          ),
          Container(
            height: 16,
          ),
          Row(
            children: <Widget>[
              InfoItem(
                title: dic['unlocking'],
                content: Fmt.token(unlocking),
                crossAxisAlignment: CrossAxisAlignment.center,
              ),
              InfoItem(
                title: dic['bond.reward'],
                content: payee,
                crossAxisAlignment: CrossAxisAlignment.center,
              ),
            ],
          ),
          Divider(),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(
                child: Container(
                  width: actionButtonWidth,
                  child: GestureDetector(
                    child: Column(
                      children: <Widget>[
                        OutlinedCircle(
                          icon: Icons.add,
                          color: actionButtonColor,
                        ),
                        Text(
                          bonded > 0
                              ? dic['action.bondExtra']
                              : dic['action.bond'],
                          style: TextStyle(color: actionButtonColor),
                        )
                      ],
                    ),
                    onTap: () => Navigator.of(context).pushNamed(
                        bonded > 0 ? '/staking/bondExtra' : '/staking/bond'),
                  ),
                ),
              ),
              Expanded(
                child: Container(
                  width: actionButtonWidth,
                  child: bonded > 0
                      ? GestureDetector(
                          child: Column(
                            children: <Widget>[
                              OutlinedCircle(
                                icon: Icons.remove,
                                color: actionButtonColor,
                              ),
                              Text(
                                dic['action.unbond'],
                                style: TextStyle(color: actionButtonColor),
                              )
                            ],
                          ),
                          onTap: () => Navigator.of(context)
                              .pushNamed('/staking/unbond'),
                        )
                      : Column(
                          children: <Widget>[
                            OutlinedCircle(
                              icon: Icons.remove,
                              color: disabledColor,
                            ),
                            Text(
                              dic['action.unbond'],
                              style: TextStyle(color: disabledColor),
                            )
                          ],
                        ),
                ),
              ),
              Expanded(
                child: Container(
                  width: actionButtonWidth,
                  child: bonded > 0
                      ? GestureDetector(
                          child: Column(
                            children: <Widget>[
                              OutlinedCircle(
                                icon: Icons.repeat,
                                color: actionButtonColor,
                              ),
                              Text(
                                dic['action.reward'],
                                style: TextStyle(color: actionButtonColor),
                              )
                            ],
                          ),
                          onTap: () =>
                              Navigator.of(context).pushNamed('/staking/payee'),
                        )
                      : Column(
                          children: <Widget>[
                            OutlinedCircle(
                              icon: Icons.repeat,
                              color: disabledColor,
                            ),
                            Text(
                              dic['action.reward'],
                              style: TextStyle(color: disabledColor),
                            )
                          ],
                        ),
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

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (store.staking.ledger['stakingLedger'] == null) {
        globalBondingRefreshKey.currentState.show();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final Map<String, String> dic = I18n.of(context).staking;

    return Observer(
      builder: (_) {
        List<Widget> list = <Widget>[
          _buildActionCard(),
          Container(
            color: Theme.of(context).cardColor,
            padding: EdgeInsets.all(16),
            child: BorderedTitle(title: dic['txs']),
          ),
        ];
        list.addAll(_buildTxList());
        return RefreshIndicator(
          key: globalBondingRefreshKey,
          onRefresh: () async {
            _updateStakingTxs();
            await _updateStakingInfo();
          },
          child: ListView(
            children: list,
          ),
        );
      },
    );
  }
}

class InfoItem extends StatelessWidget {
  InfoItem({this.title, this.content, this.crossAxisAlignment});
  final String title;
  final String content;
  final CrossAxisAlignment crossAxisAlignment;
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: crossAxisAlignment ?? CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            title,
          ),
          Text(
            content ?? '-',
            style: Theme.of(context).textTheme.display4,
          )
        ],
      ),
    );
  }
}
