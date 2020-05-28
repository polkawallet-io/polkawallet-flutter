import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:polka_wallet/common/components/infoItem.dart';
import 'package:polka_wallet/common/components/listTail.dart';
import 'package:polka_wallet/page/account/import/importAccountPage.dart';
import 'package:polka_wallet/page/staking/actions/bondExtraPage.dart';
import 'package:polka_wallet/page/staking/actions/bondPage.dart';
import 'package:polka_wallet/page/staking/actions/setControllerPage.dart';
import 'package:polka_wallet/page/staking/actions/payoutPage.dart';
import 'package:polka_wallet/page/staking/actions/redeemPage.dart';
import 'package:polka_wallet/page/staking/actions/setPayeePage.dart';
import 'package:polka_wallet/page/staking/actions/stakingDetailPage.dart';
import 'package:polka_wallet/page/staking/actions/unbondPage.dart';
import 'package:polka_wallet/service/polkascan.dart';
import 'package:polka_wallet/service/substrateApi/api.dart';
import 'package:polka_wallet/common/components/BorderedTitle.dart';
import 'package:polka_wallet/common/components/addressIcon.dart';
import 'package:polka_wallet/common/components/outlinedCircle.dart';
import 'package:polka_wallet/common/components/roundedCard.dart';
import 'package:polka_wallet/store/account/types/accountData.dart';
import 'package:polka_wallet/store/app.dart';
import 'package:polka_wallet/utils/UI.dart';
import 'package:polka_wallet/utils/format.dart';
import 'package:polka_wallet/utils/i18n/index.dart';

// TODO: txs list rendered in UI thread issue
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

  int _txsPage = 0;
  bool _isLastPage = false;
  ScrollController _scrollController;

  Future<void> _updateStakingTxs() async {
    if (store.settings.loading) {
      return;
    }
    Map res = await webApi.staking.updateStaking(_txsPage);
    if (mounted && res['extrinsics'] == null ||
        res['extrinsics'].length < tx_list_page_size) {
      setState(() {
        _isLastPage = true;
      });
    }
  }

  Future<void> _updateStakingInfo() async {
    if (store.settings.loading) {
      return;
    }
    String pubKey = store.account.currentAccount.pubKey;
    await Future.wait([
      webApi.assets.fetchBalance(pubKey),
      webApi.staking.fetchAccountStaking(pubKey),
    ]);
  }

  void _changeCurrentAccount(AccountData acc) {
    store.account.setCurrentAccount(acc);
    // refresh user's assets info
    store.assets.loadAccountCache();
    // refresh user's staking info
    store.staking.loadAccountCache();
    globalBondingRefreshKey.currentState.show();
  }

  List<Widget> _buildTxList() {
    List<Widget> res = [];
    res.addAll(store.staking.txs.map((i) {
      return Container(
        color: Theme.of(context).cardColor,
        child: ListTile(
          leading: Padding(
            padding: EdgeInsets.only(top: 4),
            child: i.success
                ? Image.asset('assets/images/staking/ok.png')
                : Image.asset('assets/images/staking/error.png'),
          ),
          title: Text(i.call),
          subtitle: Text(
              DateTime.fromMillisecondsSinceEpoch(i.blockTimestamp * 1000)
                  .toIso8601String()),
          trailing: i.success
              ? Text(
                  'Success',
                  style: TextStyle(color: Colors.green),
                )
              : Text(
                  'Failed',
                  style: TextStyle(color: Colors.pink),
                ),
          onTap: () {
            Navigator.of(context)
                .pushNamed(StakingDetailPage.route, arguments: i);
          },
        ),
      );
    }));

    res.add(ListTail(
      isLoading: store.staking.txsLoading,
      isEmpty: store.staking.txs.length == 0,
    ));

    return res;
  }

  Widget _buildActionCard() {
    var dic = I18n.of(context).staking;
    bool hasData = store.staking.ledger['stakingLedger'] != null;

    String controllerId = store.staking.ledger['controllerId'] ??
        store.staking.ledger['accountId'];
    String payee = store.staking.ledger['rewardDestination'];
    String stashId = store.staking.ledger['stashId'] ?? controllerId;
    if (hasData) {
      stashId = store.staking.ledger['stakingLedger']['stash'];
      if (payee == null) {
        payee = store.staking.ledger['stakingLedger']['payee'];
      }
    }
    bool isStash = store.staking.ledger['accountId'] == stashId;
    bool controllerEqualStash = controllerId == stashId;
    String account02 = isStash ? controllerId : stashId;
    String account02PubKey;
    store.account.pubKeyAddressMap[store.settings.endpoint.ss58]
        .forEach((k, v) {
      if (v == account02) {
        account02PubKey = k;
      }
    });
    AccountData acc02;
    int acc02Index = store.account.accountList
        .indexWhere((i) => i.pubKey == account02PubKey);
    if (acc02Index >= 0) {
      acc02 = store.account.accountList[acc02Index];
    }

    String symbol = store.settings.networkState.tokenSymbol;

    BigInt balance = store.assets.balances[symbol].total;
    BigInt bonded = BigInt.zero;
    BigInt redeemable = BigInt.zero;
    if (hasData) {
      bonded = BigInt.parse(
          store.staking.ledger['stakingLedger']['active'].toString());
      redeemable = BigInt.parse(store.staking.ledger['redeemable'].toString());
    }
    BigInt unlocking = store.staking.accountUnlockingTotal;
    unlocking -= redeemable;

    BigInt available = isStash ? balance - bonded - unlocking : balance;

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
                  '',
                  pubKey: store.account.currentAccount.pubKey,
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      Fmt.accountName(context, store.account.currentAccount),
                      style: Theme.of(context).textTheme.headline4,
                    ),
                    Text(Fmt.address(store.account.currentAddress))
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
                      style: Theme.of(context).textTheme.headline4,
                    ),
                    Text(
                      dic['balance'],
                      style: TextStyle(fontSize: 13),
                    ),
                  ],
                ),
              )
            ],
          ),
          RowAccount02(
            acc02: acc02,
            isStash: isStash,
            controllerId: controllerId,
            stashId: stashId,
            onChangeAccount: _changeCurrentAccount,
          ),
          Divider(),
          StakingInfoPanel(
            hasData: hasData,
            isStash: isStash,
            controllerEqualStash: controllerEqualStash,
            bonded: bonded,
            unlocking: unlocking,
            redeemable: redeemable,
            available: available,
            payee: payee,
            networkLoading: store.settings.loading,
          ),
          Divider(),
          StakingActionsPanel(
            isStash: isStash,
            bonded: bonded,
            controller: acc02,
            controllerEqualStash: controllerEqualStash,
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();

    _scrollController = ScrollController();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent) {
        setState(() {
          if (!_isLastPage) {
            _txsPage += 1;
            _updateStakingTxs();
          }
        });
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      globalBondingRefreshKey.currentState.show();
    });
  }

  @override
  Widget build(BuildContext context) {
    final Map<String, String> dic = I18n.of(context).staking;

    return Observer(
      builder: (_) {
        if (store.settings.loading) {
          return CupertinoActivityIndicator();
        }
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
            controller: _scrollController,
            children: list,
          ),
        );
      },
    );
  }
}

class RowAccount02 extends StatelessWidget {
  RowAccount02(
      {this.acc02,
      this.isStash,
      this.controllerId,
      this.stashId,
      this.onChangeAccount});

  final AccountData acc02;
  final bool isStash;
  final String controllerId;
  final String stashId;
  final Function onChangeAccount;

  Future<void> _importController(BuildContext context) async {
    await Navigator.of(context).pushNamed(ImportAccountPage.route);
    globalBondingRefreshKey.currentState.show();
  }

  void _showActions(BuildContext context) {
    var dic = I18n.of(context).staking;

    String actionAccountTitle = isStash ? dic['controller'] : dic['stash'];
    String importAccountText = '${dic['action.import']}$actionAccountTitle';
    String changeAccountText =
        dic['action.use'] + actionAccountTitle + dic['action.operate'];

    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) => CupertinoActionSheet(
        actions: <Widget>[
          acc02 == null
              ? CupertinoActionSheetAction(
                  child: Text(importAccountText),
                  onPressed: () {
                    Navigator.of(context).pop();
                    // go to account import page
                    _importController(context);
                  },
                )
              : CupertinoActionSheetAction(
                  child: Text(
                    importAccountText,
                    style: TextStyle(
                        color: Theme.of(context).unselectedWidgetColor),
                  ),
                  onPressed: () => null,
                ),
          acc02 != null
              ? CupertinoActionSheetAction(
                  child: Text(
                    changeAccountText,
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                    onChangeAccount(acc02);
                  },
                )
              : CupertinoActionSheetAction(
                  child: Text(
                    changeAccountText,
                    style: TextStyle(
                        color: Theme.of(context).unselectedWidgetColor),
                  ),
                  onPressed: () => null,
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
    final Map<String, String> dic = I18n.of(context).staking;

    bool controllerEqualStash = controllerId == stashId;

    return Container(
      padding: EdgeInsets.only(top: 8, bottom: 8),
      child: controllerId != null && stashId != null
          ? Row(
              children: <Widget>[
                Container(
                  margin: EdgeInsets.only(left: 4, right: 20),
                  child: acc02 != null
                      ? AddressIcon('', pubKey: acc02.pubKey, size: 32)
                      : AddressIcon(isStash ? controllerId : stashId, size: 32),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        isStash ? dic['controller'] : dic['stash'],
                        style: TextStyle(
                            fontSize: 14,
                            color: Theme.of(context).unselectedWidgetColor),
                      ),
                      Text(
                        Fmt.address(isStash ? controllerId : stashId),
                        style: TextStyle(
                            fontSize: 13,
                            color: Theme.of(context).unselectedWidgetColor),
                      ),
                    ],
                  ),
                ),
                controllerEqualStash
                    ? Container()
                    : GestureDetector(
                        child: Container(
                          width: 80,
                          height: 18,
                          child: Image.asset('assets/images/staking/set.png'),
                        ),
                        onTap: () => _showActions(context),
                      )
              ],
            )
          : null,
    );
  }
}

class StakingInfoPanel extends StatelessWidget {
  StakingInfoPanel({
    this.hasData,
    this.isStash,
    this.controllerEqualStash,
    this.bonded,
    this.unlocking,
    this.redeemable,
    this.available,
    this.payee,
    this.networkLoading,
  });

  final bool hasData;
  final bool isStash;
  final bool controllerEqualStash;
  final BigInt bonded;
  final BigInt unlocking;
  final BigInt redeemable;
  final BigInt available;
  final String payee;
  final bool networkLoading;

  @override
  Widget build(BuildContext context) {
    final Map<String, String> dic = I18n.of(context).staking;
    Color actionButtonColor = Theme.of(context).primaryColor;

    return Padding(
      padding: EdgeInsets.only(top: 4, bottom: 4),
      child: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              InfoItem(
                title: dic['bonded'],
                content: Fmt.token(bonded),
                crossAxisAlignment: CrossAxisAlignment.center,
              ),
              InfoItem(
                title: dic['bond.unlocking'],
                content: Fmt.token(unlocking),
                crossAxisAlignment: CrossAxisAlignment.center,
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Text(dic['bond.redeemable'],
                        style: TextStyle(fontSize: 12)),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          Fmt.token(redeemable),
                          style: Theme.of(context).textTheme.headline4,
                        ),
                        !isStash && redeemable > BigInt.zero
                            ? GestureDetector(
                                child: Container(
                                  padding: EdgeInsets.only(left: 4),
                                  child: Icon(
                                    Icons.lock_open,
                                    size: 16,
                                    color: actionButtonColor,
                                  ),
                                ),
                                onTap: () {
                                  Navigator.of(context)
                                      .pushNamed(RedeemPage.route);
                                },
                              )
                            : Container()
                      ],
                    )
                  ],
                ),
              ),
            ],
          ),
          Container(
            height: 16,
          ),
          Row(
            children: <Widget>[
              InfoItem(
                title: dic['available'],
                content: Fmt.token(available),
                crossAxisAlignment: CrossAxisAlignment.center,
              ),
              InfoItem(
                title: dic['bond.reward'],
                content: payee,
                crossAxisAlignment: CrossAxisAlignment.center,
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Text(dic['payout'], style: TextStyle(fontSize: 12)),
                    GestureDetector(
                      child: Container(
                        padding: EdgeInsets.all(1),
                        child: Icon(
                          Icons.card_giftcard,
                          size: 18,
                          color: actionButtonColor,
                        ),
                      ),
                      onTap: () {
                        if (!networkLoading) {
                          Navigator.of(context).pushNamed(PayoutPage.route);
                        }
                      },
                    )
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class StakingActionsPanel extends StatelessWidget {
  StakingActionsPanel({
    this.isStash,
    this.controllerEqualStash,
    this.bonded,
    this.controller,
  });

  final bool isStash;
  final bool controllerEqualStash;
  final BigInt bonded;
  final AccountData controller;

  @override
  Widget build(BuildContext context) {
    final Map<String, String> dic = I18n.of(context).staking;

    num actionButtonWidth = (MediaQuery.of(context).size.width - 64) / 3;
    Color actionButtonColor = Theme.of(context).primaryColor;
    Color disabledColor = Theme.of(context).unselectedWidgetColor;

    String bondButtonString = dic['action.bondAdjust'];
    bool setPayeeDisabled = true;
    Function onSetPayeeTap = () => null;
    bool setControllerDisabled = true;
    Function onSetControllerTap = () => null;
    if (isStash) {
      if (bonded > BigInt.zero) {
        setControllerDisabled = false;
        onSetControllerTap = () => Navigator.of(context)
            .pushNamed(SetControllerPage.route, arguments: controller);

        if (controllerEqualStash) {
          setPayeeDisabled = false;
          onSetPayeeTap =
              () => Navigator.of(context).pushNamed(SetPayeePage.route);
        }
      } else {
        bondButtonString = dic['action.bond'];
      }
    } else {
      if (bonded > BigInt.zero) {
        setPayeeDisabled = false;
        onSetPayeeTap =
            () => Navigator.of(context).pushNamed(SetPayeePage.route);
      }
    }

    return Row(
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
                    bondButtonString,
                    style: TextStyle(
                      color: actionButtonColor,
                      fontSize: 11,
                    ),
                  )
                ],
              ),
              onTap: () {
                if (isStash && bonded == BigInt.zero) {
                  Navigator.of(context).pushNamed(BondPage.route);
                  return;
                }
                showCupertinoModalPopup(
                  context: context,
                  builder: (BuildContext context) => CupertinoActionSheet(
                    actions: <Widget>[
                      CupertinoActionSheetAction(
                        child: Text(dic['action.bondExtra']),
                        onPressed: () {
                          Navigator.of(context).pop();
                          Navigator.of(context).pushNamed(BondExtraPage.route);
                        },
                      ),
                      CupertinoActionSheetAction(
                        child: Text(dic['action.unbond']),
                        onPressed: () {
                          Navigator.of(context).pop();
                          Navigator.of(context).pushNamed(UnBondPage.route);
                        },
                      ),
                    ],
                    cancelButton: CupertinoActionSheetAction(
                      child: Text(I18n.of(context).home['cancel']),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        Expanded(
          child: Container(
            width: actionButtonWidth,
            child: GestureDetector(
              child: Column(
                children: <Widget>[
                  OutlinedCircle(
                    icon: Icons.repeat,
                    color: setPayeeDisabled ? disabledColor : actionButtonColor,
                  ),
                  Text(
                    dic['action.reward'],
                    style: TextStyle(
                        color: setPayeeDisabled
                            ? disabledColor
                            : actionButtonColor,
                        fontSize: 11),
                  )
                ],
              ),
              onTap: onSetPayeeTap,
            ),
          ),
        ),
        Expanded(
          child: Container(
            width: actionButtonWidth,
            child: GestureDetector(
              child: Column(
                children: <Widget>[
                  OutlinedCircle(
                    icon: Icons.repeat,
                    color: setControllerDisabled
                        ? disabledColor
                        : actionButtonColor,
                  ),
                  Text(
                    dic['action.control'],
                    style: TextStyle(
                        color: setControllerDisabled
                            ? disabledColor
                            : actionButtonColor,
                        fontSize: 11),
                  )
                ],
              ),
              onTap: onSetControllerTap,
            ),
          ),
        )
      ],
    );
  }
}
