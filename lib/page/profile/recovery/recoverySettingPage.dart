import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:polka_wallet/common/components/BorderedTitle.dart';
import 'package:polka_wallet/common/components/TapTooltip.dart';
import 'package:polka_wallet/common/components/addressIcon.dart';
import 'package:polka_wallet/common/components/infoItem.dart';
import 'package:polka_wallet/common/components/outlinedButtonSmall.dart';
import 'package:polka_wallet/common/components/roundedButton.dart';
import 'package:polka_wallet/common/components/roundedCard.dart';
import 'package:polka_wallet/page/account/txConfirmPage.dart';
import 'package:polka_wallet/page/profile/recovery/createRecoveryPage.dart';
import 'package:polka_wallet/page/staking/actions/stakingDetailPage.dart';
import 'package:polka_wallet/service/substrateApi/api.dart';
import 'package:polka_wallet/store/account/types/accountData.dart';
import 'package:polka_wallet/store/account/types/accountRecoveryInfo.dart';
import 'package:polka_wallet/store/app.dart';
import 'package:polka_wallet/store/settings.dart';
import 'package:polka_wallet/store/staking/types/txData.dart';
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
  List<TxData> _activeRecoveries = [];
  List _activeRecoveriesStatus = [];
  List _proxyStatus = [];
  int _currentBlock = 0;

  Future<void> _fetchData() async {
    /// fetch recovery config
    final config = await webApi.account
        .queryRecoverable(widget.store.account.currentAddress);
    if (config == null) {
      print('no recoverable config');
      return;
    }
    webApi.assets.fetchBalance();

    /// fetch active recoveries from txs
    Map res = await webApi.subScanApi.fetchTxsAsync(
      webApi.subScanApi.moduleRecovery,
      call: 'initiate_recovery',
    );
    List<TxData> txs =
        List.of(res['extrinsics']).map((e) => TxData.fromJson(e)).toList();
    List pubKeys = [];
    txs.retainWhere((e) {
      if (!e.success) return false;
      List params = jsonDecode(e.params);
      String pubKey = params[0]['valueRaw'] ?? params[0]['value_raw'];
      if (pubKeys.contains(pubKey)) {
        return false;
      } else {
        pubKeys.add(pubKey);
        return '0x$pubKey' == widget.store.account.currentAccount.pubKey;
      }
    });
    if (txs.length > 0) {
      List<String> addressesNew = txs.map((e) => e.accountId).toList();

      /// fetch active recovery status
      final status = await Future.wait([
        webApi.evalJavascript('api.derive.chain.bestNumber()'),
        webApi.account.queryActiveRecoveryAttempts(
          widget.store.account.currentAddress,
          addressesNew,
        ),
        webApi.account.queryRecoveryProxies(addressesNew),
      ]);
      setState(() {
        _activeRecoveries = txs;
        _currentBlock = status[0];
        _activeRecoveriesStatus = status[1];
        _proxyStatus = status[2];
      });
    }
  }

  Future<void> _onRemoveRecovery() async {
    final Map dic = I18n.of(context).profile;
    List activeList = _activeRecoveriesStatus.toList();
    activeList.retainWhere((e) => e != null);
    bool couldRemove = activeList.length == 0;
    if (!couldRemove) {
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

  void _closeRecovery(TxData tx) {
    final Map dic = I18n.of(context).profile;
    var args = {
      "title": dic['recovery.close'],
      "txInfo": {
        "module": 'recovery',
        "call": 'closeRecovery',
      },
      "detail": jsonEncode({"rescuer": tx.accountId}),
      "params": [tx.accountId],
      'onFinish': (BuildContext txPageContext, Map res) {
        Navigator.popUntil(
            txPageContext, ModalRoute.withName('/profile/recovery'));
        globalRecoverySettingsRefreshKey.currentState.show();
      }
    };
    Navigator.of(context).pushNamed(TxConfirmPage.route, arguments: args);
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
            List<List> activeList = List<List>();
            _activeRecoveries.asMap().forEach((i, v) {
              // status is null if recovery process was closed
              if (_activeRecoveriesStatus[i] != null) {
                activeList
                    .add([v, _activeRecoveriesStatus[i], _proxyStatus[i]]);
              }
            });

            final int blockDuration =
                widget.store.settings.networkConst['babe']['expectedBlockTime'];
            final String delay =
                Fmt.blockToTime(info.delayPeriod, blockDuration);
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
                              ? Text(dic['recovery.brief'])
                              : _RecoveryInfo(
                                  recoveryInfo: info,
                                  friends: friends,
                                  decimals: decimals,
                                  symbol: symbol,
                                  delay: delay,
                                  onRemove: _onRemoveRecovery,
                                ),
                        ),
                        friends.length > 0
                            ? Padding(
                                padding: EdgeInsets.fromLTRB(16, 8, 0, 16),
                                child: BorderedTitle(
                                  title: dic['recovery.process'],
                                ),
                              )
                            : Container(),
                        friends.length > 0
                            ? Column(
                                children: activeList.length > 0
                                    ? activeList.map((e) {
                                        String start = Fmt.blockToTime(
                                            _currentBlock - e[1]['created'],
                                            blockDuration);
                                        TxData tx = e[0];
                                        bool hasProxy = false;
                                        if (e[2] != null) {
                                          hasProxy = e[2] == info.address;
                                        }
                                        return ActiveRecovery(
                                          tx: tx,
                                          status: e[1],
                                          info: info,
                                          start: start,
                                          delay: delay,
                                          proxy: hasProxy,
                                          networkState: widget
                                              .store.settings.networkState,
                                          action: CupertinoActionSheetAction(
                                            child: Text(dic['recovery.close']),
                                            onPressed: () {
                                              Navigator.of(context).pop();
                                              _closeRecovery(tx);
                                            },
                                          ),
                                        );
                                      }).toList()
                                    : [
                                        Padding(
                                          padding: EdgeInsets.all(16),
                                          child: Text(I18n.of(context)
                                              .home['data.empty']),
                                        )
                                      ],
                              )
                            : Container()
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
                    : Container(),
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
    this.delay,
    this.onRemove,
  });

  final AccountRecoveryInfo recoveryInfo;
  final List<AccountData> friends;
  final int decimals;
  final String symbol;
  final String delay;
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
                delay,
                style: valueStyle,
              )
            ],
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(dic['recovery.deposit'], style: titleStyle),
            Text(
              '${Fmt.token(recoveryInfo.deposit, decimals)} $symbol',
              style: valueStyle,
            )
          ],
        ),
        Divider(height: 32),
        RoundedButton(
          color: Colors.orange,
          text: dic['recovery.remove'],
          onPressed: () => onRemove(),
        ),
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
                child: AddressIcon(e.address, pubKey: e.pubKey, size: 32),
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

class ActiveRecovery extends StatelessWidget {
  ActiveRecovery({
    this.tx,
    this.status,
    this.info,
    this.start,
    this.delay,
    this.action,
    this.isRescuer = false,
    this.proxy = false,
    this.networkState,
  });

  final TxData tx;
  final Map status;
  final AccountRecoveryInfo info;
  final String start;
  final String delay;
  final Widget action;
  final bool isRescuer;
  final bool proxy;
  final NetworkState networkState;

  void _showActions(BuildContext context) {
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) => CupertinoActionSheet(
        actions: [
          action,
          CupertinoActionSheetAction(
            child: Text(I18n.of(context).assets['detail']),
            onPressed: () => Navigator.of(context)
                .popAndPushNamed(StakingDetailPage.route, arguments: tx),
          )
        ],
        cancelButton: CupertinoActionSheetAction(
          child: Text(I18n.of(context).home['cancel']),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final Map dic = I18n.of(context).profile;
    String frindsVouched =
        List.of(status['friends']).map((e) => Fmt.address(e)).join('\n');
    return RoundedCard(
      padding: EdgeInsets.all(16),
      margin: EdgeInsets.fromLTRB(16, 0, 16, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(isRescuer
                      ? proxy
                          ? dic['recovery.recovered']
                          : dic['recovery.init.old']
                      : proxy
                          ? dic['recovery.proxy']
                          : dic['recovery.init.new']),
                  Row(
                    children: [
                      Padding(
                        padding: EdgeInsets.only(right: 8),
                        child: Text(
                          Fmt.address(isRescuer ? info.address : tx.accountId),
                          style: Theme.of(context).textTheme.headline4,
                        ),
                      ),
                      !isRescuer
                          ? TapTooltip(
                              child: Icon(
                                Icons.info,
                                color: Theme.of(context).disabledColor,
                                size: 16,
                              ),
                              message: dic['recovery.close.info'],
                            )
                          : Container()
                    ],
                  )
                ],
              ),
              OutlinedButtonSmall(
                content: dic['recovery.actions'],
                active: true,
                onPressed: () => _showActions(context),
              )
            ],
          ),
          Container(height: 16),
          Row(
            children: [
              InfoItem(
                title: dic['recovery.deposit'],
                content:
                    '${Fmt.balance(status['deposit'].toString(), networkState.tokenDecimals)} ${networkState.tokenSymbol}',
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(dic['recovery.process']),
                    Row(
                      children: [
                        Padding(
                          padding: EdgeInsets.only(right: 8),
                          child: Text(
                            '${List.of(status['friends']).length} / ${info.threshold}',
                            style: Theme.of(context).textTheme.headline4,
                          ),
                        ),
                        TapTooltip(
                          child: Icon(
                            Icons.info,
                            color: Theme.of(context).disabledColor,
                            size: 16,
                          ),
                          message:
                              '\n${dic['recovery.friends.vouched']}\n$frindsVouched\n',
                        )
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          Container(height: 16),
          Row(
            children: [
              InfoItem(
                title: dic['recovery.delay'],
                content: delay,
              ),
              InfoItem(
                title: dic['recovery.time.start'],
                content: start,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
