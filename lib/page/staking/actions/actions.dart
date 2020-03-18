import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:polka_wallet/page/account/import/importAccountPage.dart';
import 'package:polka_wallet/page/staking/actions/bondExtraPage.dart';
import 'package:polka_wallet/page/staking/actions/bondPage.dart';
import 'package:polka_wallet/page/staking/actions/setControllerPage.dart';
import 'package:polka_wallet/page/staking/actions/payoutPage.dart';
import 'package:polka_wallet/page/staking/actions/redeemPage.dart';
import 'package:polka_wallet/page/staking/actions/setPayeePage.dart';
import 'package:polka_wallet/page/staking/actions/stakingDetailPage.dart';
import 'package:polka_wallet/page/staking/actions/unbondPage.dart';
import 'package:polka_wallet/service/substrateApi/api.dart';
import 'package:polka_wallet/common/components/BorderedTitle.dart';
import 'package:polka_wallet/common/components/addressIcon.dart';
import 'package:polka_wallet/common/components/outlinedCircle.dart';
import 'package:polka_wallet/common/components/roundedCard.dart';
import 'package:polka_wallet/store/account.dart';
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

  Future<void> _updateStakingTxs() async {
    if (store.settings.loading) {
      return;
    }
    await webApi.staking.updateStaking(_txsPage);
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
//    webApi.staking.fetchAccountRewards(address);
  }

  void _changeCurrentAccount(AccountData acc) {
    store.account.setCurrentAccount(acc);
    // refresh user's staking & gov info
    store.gov.clearSate();
    globalBondingRefreshKey.currentState.show();
  }

  List<Widget> _buildTxList() {
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
            Navigator.of(context)
                .pushNamed(StakingDetailPage.route, arguments: i);
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
    String stashId = store.staking.ledger['stashId'];
    if (hasData) {
      stashId = store.staking.ledger['stakingLedger']['stash'];
      if (payee == null) {
        payee = store.staking.ledger['stakingLedger']['payee'];
      }
    }
    String controllerId = store.staking.ledger['controllerId'] ??
        store.staking.ledger['accountId'];
    bool isStash = store.staking.ledger['accountId'] == stashId;
    String account02 = isStash ? controllerId : stashId;
    String account02PubKey;
    store.account.pubKeyAddressMap.forEach((k, v) {
      if (v == account02) {
        account02PubKey = k;
      }
    });
    AccountData acc02;
    int acc02Index = store.account.optionalAccounts
        .indexWhere((i) => i.pubKey == account02PubKey);
    if (acc02Index >= 0) {
      acc02 = store.account.optionalAccounts[acc02Index];
    }

    int balance = Fmt.balanceInt(store.assets.balance);
    int bonded = 0;
    int unlocking = 0;
    int redeemable = 0;
    if (hasData) {
      List unlockingList = store.staking.ledger['stakingLedger']['unlocking'];
      unlockingList.forEach((i) => unlocking += i['value']);
      bonded = store.staking.ledger['stakingLedger']['active'];
      redeemable = store.staking.ledger['redeemable'];
      unlocking -= redeemable;
    }
    int available = balance - bonded - unlocking;
    int rewards = store.staking.accountRewardTotal;

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
                child: AddressIcon(store.account.currentAddress),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      store.account.currentAccount.name,
                      style: Theme.of(context).textTheme.display4,
                    ),
                    Text(accIndex ?? Fmt.address(store.account.currentAddress))
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
              bonded: bonded,
              unlocking: unlocking,
              redeemable: redeemable,
              available: available,
              payee: payee,
              rewards: rewards),
          Divider(),
          StakingActionsPanel(
              isStash: isStash, bonded: bonded, controller: acc02),
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

    return Container(
      padding: EdgeInsets.only(top: 8, bottom: 8),
      child: controllerId != null && stashId != null
          ? Row(
              children: <Widget>[
                Container(
                  margin: EdgeInsets.only(left: 4, right: 20),
                  child:
                      AddressIcon(isStash ? controllerId : stashId, size: 32),
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
                            fontSize: 14,
                            color: Theme.of(context).unselectedWidgetColor),
                      ),
                    ],
                  ),
                ),
                GestureDetector(
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

class StakingInfoPanel extends StatelessWidget {
  StakingInfoPanel({
    this.hasData,
    this.isStash,
    this.bonded,
    this.unlocking,
    this.redeemable,
    this.available,
    this.payee,
    this.rewards,
  });

  final bool hasData;
  final bool isStash;
  final int bonded;
  final int unlocking;
  final int redeemable;
  final int available;
  final String payee;
  final int rewards;

  @override
  Widget build(BuildContext context) {
    final Map<String, String> dic = I18n.of(context).staking;
    Color actionButtonColor = Theme.of(context).primaryColor;

    return Column(
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
                  Text(dic['bond.redeemable']),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        Fmt.token(redeemable),
                        style: Theme.of(context).textTheme.display4,
                      ),
                      !isStash && redeemable > 0
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
                  Text(dic['payout']),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      rewards != null
                          ? Text(
                              Fmt.token(rewards),
                              style: Theme.of(context).textTheme.display4,
                            )
                          : CupertinoActivityIndicator(),
                      !isStash && rewards != null && rewards > 0
                          ? GestureDetector(
                              child: Container(
                                padding: EdgeInsets.only(left: 4),
                                child: Icon(
                                  Icons.file_download,
                                  size: 16,
                                  color: actionButtonColor,
                                ),
                              ),
                              onTap: () {
                                Navigator.of(context)
                                    .pushNamed(PayoutPage.route);
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
      ],
    );
  }
}

class StakingActionsPanel extends StatelessWidget {
  StakingActionsPanel({this.isStash, this.bonded, this.controller});

  final bool isStash;
  final int bonded;
  final AccountData controller;

  @override
  Widget build(BuildContext context) {
    final Map<String, String> dic = I18n.of(context).staking;

    num actionButtonWidth = MediaQuery.of(context).size.width / 4;
    Color actionButtonColor = Theme.of(context).primaryColor;
    Color disabledColor = Theme.of(context).unselectedWidgetColor;

    String bondButtonString;
    bool unbondDisabled = false;
    Function onBondTap = () => null;
    bool setPayeeDisabled = true;
    Function onSetPayeeTap = () => null;
    bool setControllerDisabled = true;
    Function onSetControllerTap = () => null;
    if (isStash) {
      if (bonded > 0) {
        bondButtonString = dic['action.bondExtra'];
        onBondTap = () => Navigator.of(context).pushNamed(BondExtraPage.route);

        setControllerDisabled = false;
        onSetControllerTap = () => Navigator.of(context)
            .pushNamed(SetControllerPage.route, arguments: controller);
      } else {
        bondButtonString = dic['action.bond'];
        onBondTap = () => Navigator.of(context).pushNamed(BondPage.route);
      }
    } else {
      bondButtonString = dic['action.unbond'];
      if (bonded > 0) {
        onBondTap = () => Navigator.of(context).pushNamed(UnBondPage.route);

        setPayeeDisabled = false;
        onSetPayeeTap =
            () => Navigator.of(context).pushNamed(SetPayeePage.route);
      } else {
        unbondDisabled = true;
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
                    icon: isStash ? Icons.add : Icons.remove,
                    color: unbondDisabled ? disabledColor : actionButtonColor,
                  ),
                  Text(
                    bondButtonString,
                    style: TextStyle(
                      color: unbondDisabled ? disabledColor : actionButtonColor,
                      fontSize: 14,
                    ),
                  )
                ],
              ),
              onTap: onBondTap,
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
                        fontSize: 14),
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
                        fontSize: 14),
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
