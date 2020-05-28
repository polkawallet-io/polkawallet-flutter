import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:polka_wallet/common/components/addressIcon.dart';
import 'package:polka_wallet/common/components/roundedButton.dart';
import 'package:polka_wallet/common/components/roundedCard.dart';
import 'package:polka_wallet/page/account/txConfirmPage.dart';
import 'package:polka_wallet/page/profile/account/createRecoveryPage.dart';
import 'package:polka_wallet/service/polkascan.dart';
import 'package:polka_wallet/service/substrateApi/api.dart';
import 'package:polka_wallet/store/account/types/accountData.dart';
import 'package:polka_wallet/store/account/types/accountRecoveryInfo.dart';
import 'package:polka_wallet/store/app.dart';
import 'package:polka_wallet/utils/UI.dart';
import 'package:polka_wallet/utils/format.dart';
import 'package:polka_wallet/utils/i18n/index.dart';

class RecoverySettingPage extends StatefulWidget {
  RecoverySettingPage(this.store);
  static final String route = '/profile/recovery';
  final AppStore store;

  @override
  _RecoverySettingPage createState() => _RecoverySettingPage();
}

class _RecoverySettingPage extends State<RecoverySettingPage> {
  List _activeRecoveries = [];

  Future<void> _fetchData() async {
    await webApi.account.queryRecoverable();
    Map res = await PolkaScanApi.fetchRecoveryAttempts();
    List txs = List.of(res['extrinsics']);
    txs.retainWhere((e) {
      List params = jsonDecode(e['params']);
      return params[0]['value'] == widget.store.account.currentAccount.pubKey;
    });
    print('_activeRecoveries');
    print(txs);
    if (txs.length > 0) {
      setState(() {
        _activeRecoveries = txs;
      });
    }
  }

  Future<void> _onRemoveRecovery() async {
    final Map dic = I18n.of(context).profile;
    bool couldRemove = true;
    if (couldRemove) {
      showCupertinoDialog(
        context: context,
        builder: (BuildContext context) {
          return CupertinoAlertDialog(
            title: Container(),
            content: Text(dic['recovery.remove.warn']),
            actions: <Widget>[
              CupertinoButton(
                child: Text(I18n.of(context).home['ok']),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    } else {
      var args = {
        "title": dic['recovery.remove'],
        "txInfo": {
          "module": 'recovery',
          "call": 'removeRecovery',
        },
        "detail": '{}',
        "params": [],
        'onFinish': (BuildContext txPageContext, Map res) {
          Navigator.popUntil(
              txPageContext, ModalRoute.withName('/profile/recovery'));
          globalRecoverySettingsRefreshKey.currentState.show();
        }
      };
      Navigator.of(context).pushNamed(TxConfirmPage.route, arguments: args);
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      globalRecoverySettingsRefreshKey.currentState.show();
    });
  }

  @override
  Widget build(BuildContext context) {
    final Map dic = I18n.of(context).profile;
    return Scaffold(
      appBar: AppBar(title: Text(dic['recovery']), centerTitle: true),
      body: SafeArea(
        child: Observer(
          builder: (_) {
            final int decimals =
                widget.store.settings.networkState.tokenDecimals;
            final String symbol =
                widget.store.settings.networkState.tokenSymbol;
            AccountRecoveryInfo info = widget.store.account.recoveryInfo;
            List<AccountData> friends = [];
            if (info.friends != null) {
              friends.addAll(info.friends.map((e) {
                int friendIndex = widget.store.settings.contactList
                    .indexWhere((c) => c.address == e);
                if (friendIndex >= 0) {
                  return widget.store.settings.contactList[friendIndex];
                }
                AccountData res = AccountData();
                res.address = e;
                return res;
              }));
            }
            return Column(
              children: [
                Expanded(
                  child: RefreshIndicator(
                    key: globalRecoverySettingsRefreshKey,
                    onRefresh: _fetchData,
                    child: ListView(
                      children: [
                        RoundedCard(
                          margin: EdgeInsets.all(16),
                          padding: EdgeInsets.all(16),
                          child: friends.length == 0
                              ? Text('status')
                              : _RecoveryInfo(
                                  recoveryInfo: info,
                                  friends: friends,
                                  decimals: decimals,
                                  symbol: symbol,
                                  blockDuration:
                                      widget.store.settings.networkConst['babe']
                                          ['expectedBlockTime'],
                                  onRemove: _onRemoveRecovery,
                                ),
                        )
                      ],
                    ),
                  ),
                ),
                info.friends == null
                    ? Padding(
                        padding: EdgeInsets.all(16),
                        child: RoundedButton(
                          text: dic['recovery.create'],
                          onPressed: () {
                            Navigator.of(context).pushNamed(
                              CreateRecoveryPage.route,
                              arguments: friends,
                            );
                          },
                        ),
                      )
                    : Container()
              ],
            );
          },
        ),
      ),
    );
  }
}

class _RecoveryInfo extends StatelessWidget {
  _RecoveryInfo({
    this.friends,
    this.recoveryInfo,
    this.decimals,
    this.symbol,
    this.blockDuration,
    this.onRemove,
  });

  final AccountRecoveryInfo recoveryInfo;
  final List<AccountData> friends;
  final int decimals;
  final String symbol;
  final int blockDuration;
  final Function onRemove;

  @override
  Widget build(BuildContext context) {
    final Map dic = I18n.of(context).profile;
    TextStyle titleStyle = TextStyle(fontSize: 16);
    TextStyle valueStyle = Theme.of(context).textTheme.headline4;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(bottom: 16),
          child: Text(dic['recovery.friends'], style: titleStyle),
        ),
        RecoveryFriendList(friends: friends),
        Padding(
          padding: EdgeInsets.only(bottom: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(dic['recovery.threshold'], style: titleStyle),
              Text(
                '${recoveryInfo.threshold} / ${friends.length}',
                style: valueStyle,
              )
            ],
          ),
        ),
        Padding(
          padding: EdgeInsets.only(bottom: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(dic['recovery.delay'], style: titleStyle),
              Text(
                Fmt.blockToTime(recoveryInfo.delayPeriod, blockDuration),
                style: valueStyle,
              )
            ],
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('deposit', style: titleStyle),
            Text(
              '${Fmt.token(recoveryInfo.deposit, decimals: decimals)} $symbol',
              style: valueStyle,
            )
          ],
        ),
        Divider(height: 32),
        Row(
          children: [
            Expanded(
              child: RoundedButton(
                color: Colors.orange,
                text: 'remove',
                onPressed: () => onRemove(),
              ),
            ),
            Container(width: 16),
            Expanded(
              child: RoundedButton(
                color: Theme.of(context).primaryColor,
                text: 'modify',
                onPressed: () {
                  Navigator.of(context).pushNamed(
                    CreateRecoveryPage.route,
                    arguments: friends,
                  );
                },
              ),
            )
          ],
        )
      ],
    );
  }
}

class RecoveryFriendList extends StatelessWidget {
  RecoveryFriendList({this.friends});

  final List<AccountData> friends;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: friends.map((e) {
        return Padding(
          padding: EdgeInsets.only(bottom: 16),
          child: Row(
            children: [
              Container(
                width: 32,
                margin: EdgeInsets.only(right: 8),
                child: AddressIcon(e.address, size: 32),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  e.name != null && e.name.isNotEmpty
                      ? Text(e.name)
                      : Container(),
                  Text(
                    Fmt.address(e.address),
                    style: TextStyle(
                      color: Theme.of(context).unselectedWidgetColor,
                      fontSize: 13,
                    ),
                  ),
                ],
              )
            ],
          ),
        );
      }).toList(),
    );
  }
}
