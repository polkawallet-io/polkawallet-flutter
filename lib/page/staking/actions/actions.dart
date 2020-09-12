import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:polka_wallet/common/components/TapTooltip.dart';
import 'package:polka_wallet/common/components/infoItem.dart';
import 'package:polka_wallet/common/components/listTail.dart';
import 'package:polka_wallet/page/account/import/importAccountPage.dart';
import 'package:polka_wallet/page/staking/actions/bondExtraPage.dart';
import 'package:polka_wallet/page/staking/actions/bondPage.dart';
import 'package:polka_wallet/page/staking/actions/rewardDetailPage.dart';
import 'package:polka_wallet/page/staking/actions/setControllerPage.dart';
import 'package:polka_wallet/page/staking/actions/payoutPage.dart';
import 'package:polka_wallet/page/staking/actions/redeemPage.dart';
import 'package:polka_wallet/page/staking/actions/setPayeePage.dart';
import 'package:polka_wallet/page/staking/actions/stakingDetailPage.dart';
import 'package:polka_wallet/page/staking/actions/unbondPage.dart';
import 'package:polka_wallet/service/subscan.dart';
import 'package:polka_wallet/service/substrateApi/api.dart';
import 'package:polka_wallet/common/components/addressIcon.dart';
import 'package:polka_wallet/common/components/outlinedCircle.dart';
import 'package:polka_wallet/common/components/roundedCard.dart';
import 'package:polka_wallet/store/account/types/accountData.dart';
import 'package:polka_wallet/store/app.dart';
import 'package:polka_wallet/store/assets/types/balancesInfo.dart';
import 'package:polka_wallet/store/staking/types/ownStashInfo.dart';
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

  bool _loading = false;
  bool _rewardLoading = false;

  TabController _tabController;
  int _tab = 0;

  int _txsPage = 0;
  bool _isLastPage = false;
  ScrollController _scrollController;

  Future<void> _updateStakingTxs() async {
    if (store.settings.loading || _loading) {
      return;
    }
    setState(() {
      _loading = true;
    });
    Map res = await webApi.staking.updateStaking(_txsPage);
    if (mounted) {
      setState(() {
        _loading = false;
      });

      if (res['extrinsics'] == null ||
          res['extrinsics'].length < tx_list_page_size) {
        setState(() {
          _isLastPage = true;
        });
      }
    }
  }

  Future<void> _updateStakingRewardTxs() async {
    if (store.settings.loading) {
      return;
    }
    setState(() {
      _rewardLoading = true;
    });
    await webApi.staking.updateStakingRewards();
    if (mounted) {
      setState(() {
        _rewardLoading = false;
      });
    }
  }

  Future<void> _updateStakingInfo() async {
    if (store.settings.loading) {
      return;
    }
    _tab == 0 ? _updateStakingTxs() : _updateStakingRewardTxs();
    await Future.wait([
      webApi.assets.fetchBalance(),
      webApi.staking.fetchAccountStaking(),
    ]);
  }

  void _changeCurrentAccount(AccountData acc) {
    webApi.account.changeCurrentAccount(pubKey: acc.pubKey);
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
          subtitle: Text(Fmt.dateTime(
              DateTime.fromMillisecondsSinceEpoch(i.blockTimestamp * 1000))),
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

  List<Widget> _buildRewardsList() {
    final int decimals = store.settings.networkState.tokenDecimals;
    final String symbol = store.settings.networkState.tokenSymbol;

    List<Widget> res = [];
    res.addAll(store.staking.txsRewards.map((i) {
      return Container(
        color: Theme.of(context).cardColor,
        child: ListTile(
          leading: Padding(
            padding: EdgeInsets.only(top: 4),
            child: i.eventId == 'Reward'
                ? SvgPicture.asset('assets/images/staking/reward.svg',
                    width: 32)
                : SvgPicture.asset('assets/images/staking/slash.svg',
                    width: 32),
          ),
          title: Text(i.eventId),
          subtitle: Text(Fmt.dateTime(
              DateTime.fromMillisecondsSinceEpoch(i.blockTimestamp * 1000))),
          trailing: Text('${Fmt.balance(i.amount, decimals)} $symbol'),
          onTap: () {
            Navigator.of(context)
                .pushNamed(RewardDetailPage.route, arguments: i);
          },
        ),
      );
    }));

    res.add(ListTail(
      isLoading: _rewardLoading,
      isEmpty: store.staking.txsRewards.length == 0,
    ));

    return res;
  }

  Widget _buildActionCard() {
    var dic = I18n.of(context).staking;
    final bool hasData = store.staking.ownStashInfo != null;

    bool isStash = true;
    bool isController = true;
    bool isSelfControl = true;
    String account02PubKey = store.account.currentAccountPubKey;
    if (hasData) {
      isStash = store.staking.ownStashInfo.isOwnStash;
      isController = store.staking.ownStashInfo.isOwnController;
      isSelfControl = isStash && isController;

      store.account.pubKeyAddressMap[store.settings.endpoint.ss58]
          .forEach((k, v) {
        if (store.staking.ownStashInfo.isOwnStash &&
            v == store.staking.ownStashInfo.controllerId) {
          account02PubKey = k;
          return;
        }
        if (store.staking.ownStashInfo.isOwnController &&
            v == store.staking.ownStashInfo.stashId) {
          account02PubKey = k;
          return;
        }
      });
    }
    AccountData acc02;
    int acc02Index = store.account.accountListAll
        .indexWhere((i) => i.pubKey == account02PubKey);
    if (acc02Index >= 0) {
      acc02 = store.account.accountListAll[acc02Index];
    }

    final symbol = store.settings.networkState.tokenSymbol;
    final decimals = store.settings.networkState.tokenDecimals;

    final BalancesInfo info = store.assets.balances[symbol];
    BigInt bonded = BigInt.zero;
    BigInt redeemable = BigInt.zero;
    if (hasData && store.staking.ownStashInfo.stakingLedger != null) {
      bonded = BigInt.parse(
          store.staking.ownStashInfo.stakingLedger['active'].toString());
      redeemable = BigInt.parse(
          store.staking.ownStashInfo.account.redeemable.toString());
    }
    BigInt unlocking = store.staking.accountUnlockingTotal;
    unlocking -= redeemable;

    return RoundedCard(
      margin: EdgeInsets.fromLTRB(16, 12, 16, 24),
      padding: EdgeInsets.all(16),
      child: !hasData
          ? Container(
              padding: EdgeInsets.only(top: 80, bottom: 80),
              child: CupertinoActivityIndicator(),
            )
          : Column(
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
                            Fmt.accountName(
                                context, store.account.currentAccount),
                            style: Theme.of(context).textTheme.headline4,
                          ),
                          Text(Fmt.address(store.account.currentAddress))
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Text(
                            '${Fmt.priceFloorBigInt(info.total, decimals, lengthMax: 3)}',
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
                  accountId: store.staking.ownStashInfo.account.accountId ??
                      store.account.currentAddress,
                  isController: isController,
                  isSelfControl: isSelfControl,
                  stashInfo: store.staking.ownStashInfo,
                  onChangeAccount: _changeCurrentAccount,
                  store: store,
                ),
                Divider(),
                StakingInfoPanel(
                  hasData: hasData,
                  isController: isController,
                  accountId: store.account.currentAddress,
                  stashInfo: store.staking.ownStashInfo,
                  decimals: decimals,
                  blockDuration: store.settings.networkConst['babe']
                      ['expectedBlockTime'],
                  bonded: bonded,
                  unlocking: unlocking,
                  redeemable: redeemable,
                  available: info.transferable,
                  networkLoading: store.settings.loading,
                ),
                Divider(),
                StakingActionsPanel(
                  isStash: isStash,
                  isController: isController,
                  stashInfo: store.staking.ownStashInfo,
                  bonded: bonded,
                  controller: acc02,
                ),
              ],
            ),
    );
  }

  @override
  void initState() {
    super.initState();

    _tabController = TabController(vsync: this, length: 2);

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
      if (store.staking.ownStashInfo == null) {
        if (globalBondingRefreshKey.currentState != null) {
          globalBondingRefreshKey.currentState.show();
        }
      } else {
        _updateStakingInfo();
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
            padding: EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: TabBar(
              labelColor: Colors.black87,
              labelStyle: TextStyle(fontSize: 18),
              controller: _tabController,
              tabs: <Tab>[
                Tab(
                  text: dic['txs'],
                ),
                Tab(
                  text: dic['txs.reward'],
                ),
              ],
              onTap: (i) {
                i == 0 ? _updateStakingTxs() : _updateStakingRewardTxs();
                setState(() {
                  _tab = i;
                });
              },
            ),
          ),
        ];
        list.addAll(_tab == 0 ? _buildTxList() : _buildRewardsList());
        return RefreshIndicator(
          key: globalBondingRefreshKey,
          onRefresh: _updateStakingInfo,
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
  RowAccount02({
    this.acc02,
    this.accountId,
    this.isController,
    this.isSelfControl,
    this.stashInfo,
    this.onChangeAccount,
    this.store,
  });

  /// 1. if acc02 != null, then we have acc02 in accountListAll.
  ///    if acc02 == null, we can remind user to import it.
  /// 2. if current account is controller, and it's not self-controlled,
  ///    we display a stashId as address02, or we display a controllerId.
  final AccountData acc02;
  final String accountId;
  final bool isController;
  final bool isSelfControl;
  final OwnStashInfoData stashInfo;
  final Function onChangeAccount;
  final AppStore store;

  Future<void> _importController(BuildContext context) async {
    await Navigator.of(context).pushNamed(ImportAccountPage.route);
    globalBondingRefreshKey.currentState.show();
  }

  void _showActions(BuildContext context) {
    var dic = I18n.of(context).staking;
    String actionAccountTitle =
        isController && !isSelfControl ? dic['stash'] : dic['controller'];
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
    final stashId = stashInfo.stashId ?? accountId;
    final controllerId = stashInfo.controllerId ?? accountId;
    final String address02 =
        isController && !isSelfControl ? stashId : controllerId;
    print(isController);
    return Container(
      padding: EdgeInsets.only(top: 8, bottom: 8),
      child: stashInfo != null
          ? Row(
              children: <Widget>[
                Container(
                  margin: EdgeInsets.only(left: 4, right: 20),
                  child: acc02 != null
                      ? AddressIcon(acc02.address,
                          pubKey: acc02.pubKey, size: 32)
                      : AddressIcon(address02, size: 32),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        isController && !isSelfControl
                            ? dic['stash']
                            : dic['controller'],
                        style: TextStyle(
                            fontSize: 14,
                            color: Theme.of(context).unselectedWidgetColor),
                      ),
                      Text(
                        Fmt.address(acc02 != null
                            ? Fmt.addressOfAccount(acc02, store)
                            : address02),
                        style: TextStyle(
                            fontSize: 13,
                            color: Theme.of(context).unselectedWidgetColor),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: controllerId == stashId
                      ? Container()
                      : GestureDetector(
                          child: Container(
                            width: 80,
                            height: 18,
                            child: Image.asset('assets/images/staking/set.png'),
                          ),
                          onTap: () => _showActions(context),
                        ),
                )
              ],
            )
          : Container(),
    );
  }
}

class StakingInfoPanel extends StatelessWidget {
  StakingInfoPanel({
    this.hasData,
    this.isController,
    this.accountId,
    this.stashInfo,
    this.decimals,
    this.blockDuration,
    this.bonded,
    this.unlocking,
    this.redeemable,
    this.available,
    this.networkLoading,
  });

  final bool hasData;
  final bool isController;
  final String accountId;
  final OwnStashInfoData stashInfo;
  final int decimals;
  final int blockDuration;
  final BigInt bonded;
  final BigInt unlocking;
  final BigInt redeemable;
  final BigInt available;
  final bool networkLoading;

  @override
  Widget build(BuildContext context) {
    final Map<String, String> dic = I18n.of(context).staking;
    final Map<String, String> dicGov = I18n.of(context).gov;
    Color actionButtonColor = Theme.of(context).primaryColor;
    final unlockDetail = List.of(stashInfo.unbondings['mapped'])
        .map((e) {
          return '${dic['bond.unlocking']}:  ${Fmt.balance(e[0], decimals)}\n'
              '${dicGov['remain']}:  ${Fmt.blockToTime(e[1], blockDuration)}';
        })
        .toList()
        .join('\n\n');
    return Padding(
      padding: EdgeInsets.only(top: 4, bottom: 4),
      child: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              InfoItem(
                title: dic['bonded'],
                content: Fmt.priceFloorBigInt(bonded, decimals, lengthMax: 3),
                crossAxisAlignment: CrossAxisAlignment.center,
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Text(dic['bond.unlocking'], style: TextStyle(fontSize: 12)),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        unlocking > BigInt.zero
                            ? TapTooltip(
                                child: Padding(
                                  padding: EdgeInsets.only(right: 2),
                                  child: Icon(
                                    Icons.access_time,
                                    size: 16,
                                    color: actionButtonColor,
                                  ),
                                ),
                                message: '\n$unlockDetail\n',
                              )
                            : Container(),
                        Text(
                          Fmt.priceFloorBigInt(unlocking, decimals,
                              lengthMax: 3),
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).unselectedWidgetColor,
                          ),
                        )
                      ],
                    )
                  ],
                ),
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
                          Fmt.priceFloorBigInt(
                            redeemable,
                            decimals,
                            lengthMax: 3,
                          ),
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).unselectedWidgetColor,
                          ),
                        ),
                        isController && redeemable > BigInt.zero
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
                content:
                    Fmt.priceFloorBigInt(available, decimals, lengthMax: 3),
                crossAxisAlignment: CrossAxisAlignment.center,
              ),
              InfoItem(
                title: dic['bond.reward'],
                content: stashInfo.destination,
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
                          size: 16,
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
    this.isController,
    this.stashInfo,
    this.bonded,
    this.controller,
  });

  final bool isStash;
  final bool isController;
  final OwnStashInfoData stashInfo;
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
      if (stashInfo.controllerId != null) {
        setControllerDisabled = false;
        onSetControllerTap = () => Navigator.of(context)
            .pushNamed(SetControllerPage.route, arguments: controller);

        if (stashInfo.isOwnController) {
          setPayeeDisabled = false;
          onSetPayeeTap = () => Navigator.of(context).pushNamed(
                SetPayeePage.route,
                arguments: stashInfo.destinationId,
              );
        }
      } else {
        bondButtonString = dic['action.bond'];
      }
    } else {
      if (bonded > BigInt.zero) {
        setPayeeDisabled = false;
        onSetPayeeTap = () => Navigator.of(context).pushNamed(
              SetPayeePage.route,
              arguments: stashInfo.destinationId,
            );
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
                /// if stake clear, we can go to bond page.
                /// 1. it has no controller
                /// 2. it's stash is itself(it's not controller of another acc)
                if (stashInfo.controllerId == null && isStash) {
                  Navigator.of(context).pushNamed(BondPage.route);
                  return;
                }
                showCupertinoModalPopup(
                  context: context,
                  builder: (BuildContext context) => CupertinoActionSheet(
                    actions: <Widget>[
                      /// disable bondExtra button if account is not stash
                      CupertinoActionSheetAction(
                        child: Text(
                          dic['action.bondExtra'],
                          style: TextStyle(
                            color: !isStash ? disabledColor : actionButtonColor,
                          ),
                        ),
                        onPressed: !isStash
                            ? () => {}
                            : () {
                                Navigator.of(context).pop();
                                Navigator.of(context)
                                    .pushNamed(BondExtraPage.route);
                              },
                      ),

                      /// disable unbond button if account is not controller
                      CupertinoActionSheetAction(
                        child: Text(
                          dic['action.unbond'],
                          style: TextStyle(
                            color: !isController
                                ? disabledColor
                                : actionButtonColor,
                          ),
                        ),
                        onPressed: !isController
                            ? () => {}
                            : () {
                                Navigator.of(context).pop();
                                Navigator.of(context)
                                    .pushNamed(UnBondPage.route);
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
