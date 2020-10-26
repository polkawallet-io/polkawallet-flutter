import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:polka_wallet/common/components/infoItem.dart';
import 'package:polka_wallet/common/components/roundedButton.dart';
import 'package:polka_wallet/common/components/roundedCard.dart';
import 'package:polka_wallet/common/consts/settings.dart';
import 'package:polka_wallet/page-acala/earn/addLiquidityPage.dart';
import 'package:polka_wallet/page-acala/earn/earnHistoryPage.dart';
import 'package:polka_wallet/page-acala/earn/withdrawLiquidityPage.dart';
import 'package:polka_wallet/page-acala/loan/loanPage.dart';
import 'package:polka_wallet/page/account/txConfirmPage.dart';
import 'package:polka_wallet/service/substrateApi/api.dart';
import 'package:polka_wallet/store/acala/types/dexPoolInfoData.dart';
import 'package:polka_wallet/store/acala/types/txLiquidityData.dart';
import 'package:polka_wallet/store/app.dart';
import 'package:polka_wallet/utils/UI.dart';
import 'package:polka_wallet/utils/format.dart';
import 'package:polka_wallet/utils/i18n/index.dart';

class EarnPage extends StatefulWidget {
  EarnPage(this.store);

  static const String route = '/acala/earn';
  final AppStore store;

  @override
  _EarnPageState createState() => _EarnPageState(store);
}

class _EarnPageState extends State<EarnPage> {
  _EarnPageState(this.store);

  final AppStore store;

  String _tab = 'ACA-aUSD';

  Future<void> _fetchData() async {
    webApi.acala.fetchDexLiquidityPoolSwapRatio(_tab);
    await webApi.acala.fetchDexPoolInfo(_tab);
  }

  void _onStake() {
    print('stake');
    // final args = {
    //   "title": I18n.of(context).acala['earn.get'],
    //   "txInfo": {
    //     "module": 'incentives',
    //     "call": 'depositDexShare',
    //   },
    //   "detail": jsonEncode({
    //     "poolId": _tab,
    //     "amount": '$incentiveReward $symbol',
    //   }),
    //   "params": [],
    //   "rawParam": '[{DexIncentive: {DEXShare: $pool}}]',
    //   "onFinish": (BuildContext txPageContext, Map res) {
    //     res['action'] = TxDexLiquidityData.actionRewardIncentive;
    //     res['params'] = [symbol, incentiveReward, ''];
    //     store.acala.setDexLiquidityTxs([res]);
    //     Navigator.popUntil(txPageContext, ModalRoute.withName(EarnPage.route));
    //     globalDexLiquidityRefreshKey.currentState.show();
    //   }
    // };
  }

  void _onUnstake() {
    print('unstake');
  }

  Future<void> _onWithdrawReward(LPRewardData reward) async {
    final decimals = store.settings.networkState.tokenDecimals;
    final symbol = store.settings.networkState.tokenSymbol;
    final incentiveReward = Fmt.token(reward.incentive, decimals);
    final savingReward = Fmt.token(reward.saving, decimals);
    final pool =
        jsonEncode(_tab.split('-').map((e) => e.toUpperCase()).toList());

    Map args;
    if (reward.saving > BigInt.zero && reward.incentive > BigInt.zero) {
      final params = [
        'api.tx.incentives.claimRewards({DexIncentive: {DEXShare: $pool}})',
        'api.tx.incentives.claimRewards({DexSaving: {DEXShare: $pool}})',
      ];
      args = {
        "title": I18n.of(context).acala['earn.get'],
        "txInfo": {
          "module": 'utility',
          "call": 'batch',
        },
        "detail": jsonEncode({
          "poolId": _tab,
          "incentiveReward": '$incentiveReward $symbol',
          "savingReward": '$savingReward $acala_stable_coin_view',
        }),
        "params": [],
        "rawParam": '[[${params.join(',')}]]',
        "onFinish": (BuildContext txPageContext, Map res) {
          final tx1 = {
            'hash': res['hash'],
            'time': res['time'],
            'action': TxDexLiquidityData.actionRewardIncentive,
            'params': [symbol, incentiveReward, '']
          };
          final tx2 = {
            'hash': res['hash'],
            'time': res['time'],
            'action': TxDexLiquidityData.actionRewardSaving,
            'params': [symbol, '', savingReward]
          };
          store.acala.setDexLiquidityTxs([tx1, tx2]);
          Navigator.popUntil(
              txPageContext, ModalRoute.withName(EarnPage.route));
          globalDexLiquidityRefreshKey.currentState.show();
        }
      };
    } else if (reward.incentive > BigInt.zero) {
      args = {
        "title": I18n.of(context).acala['earn.get'],
        "txInfo": {
          "module": 'incentives',
          "call": 'claimRewards',
        },
        "detail": jsonEncode({
          "poolId": _tab,
          "incentiveReward": '$incentiveReward $symbol',
        }),
        "params": [],
        "rawParam": '[{DexIncentive: {DEXShare: $pool}}]',
        "onFinish": (BuildContext txPageContext, Map res) {
          res['action'] = TxDexLiquidityData.actionRewardIncentive;
          res['params'] = [symbol, incentiveReward, ''];
          store.acala.setDexLiquidityTxs([res]);
          Navigator.popUntil(
              txPageContext, ModalRoute.withName(EarnPage.route));
          globalDexLiquidityRefreshKey.currentState.show();
        }
      };
    } else if (reward.saving > BigInt.zero) {
      args = {
        "title": I18n.of(context).acala['earn.get'],
        "txInfo": {
          "module": 'incentives',
          "call": 'claimRewards',
        },
        "detail": jsonEncode({
          "poolId": _tab,
          "savingReward": '$savingReward $acala_stable_coin_view',
        }),
        "params": [],
        "rawParam": '[{DexSaving: {DEXShare: $pool}}]',
        "onFinish": (BuildContext txPageContext, Map res) {
          res['action'] = TxDexLiquidityData.actionRewardSaving;
          res['params'] = [symbol, '', savingReward];
          store.acala.setDexLiquidityTxs([res]);
          Navigator.popUntil(
              txPageContext, ModalRoute.withName(EarnPage.route));
          globalDexLiquidityRefreshKey.currentState.show();
        }
      };
    }
    Navigator.of(context).pushNamed(TxConfirmPage.route, arguments: args);
  }

  @override
  void initState() {
    super.initState();
    webApi.acala.fetchDexLiquidityPoolRewards();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      globalDexLiquidityRefreshKey.currentState.show();
    });
  }

  @override
  Widget build(BuildContext context) {
    final Map dic = I18n.of(context).acala;
    final int decimals = store.settings.networkState.tokenDecimals;
    return Scaffold(
      backgroundColor: Theme.of(context).cardColor,
      appBar: AppBar(
        title: Text(dic['earn.title']),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.history),
            onPressed: () => Navigator.of(context)
                .pushNamed(EarnHistoryPage.route, arguments: _tab),
          )
        ],
      ),
      body: Observer(
        builder: (_) {
          BigInt shareTotal = BigInt.zero;
          BigInt share = BigInt.zero;
          double userShare = 0;

          String lpAmountString = '~';

          DexPoolInfoData poolInfo = store.acala.dexPoolInfoMap[_tab];
          if (poolInfo != null) {
            shareTotal = poolInfo.sharesTotal;
            share = poolInfo.shares;
            userShare = share / shareTotal;

            final lpAmount =
                Fmt.bigIntToDouble(poolInfo.amountToken, decimals) *
                    poolInfo.proportion;
            print(poolInfo.amountToken);
            print(poolInfo.amountStableCoin);
            print(poolInfo.proportion);
            print(lpAmount);
            final lpAmount2 =
                Fmt.bigIntToDouble(poolInfo.amountStableCoin, decimals) *
                    poolInfo.proportion;
            print(lpAmount2);
            final pair = _tab.split('-');
            lpAmountString = '$lpAmount ${pair[0]} + $lpAmount2 ${pair[1]}';
          }

          Color cardColor = Theme.of(context).cardColor;
          Color primaryColor = Theme.of(context).primaryColor;

          return SafeArea(
            child: RefreshIndicator(
              key: globalDexLiquidityRefreshKey,
              onRefresh: _fetchData,
              child: Column(
                children: <Widget>[
                  CurrencySelector(
                    token: _tab,
                    decimals: decimals,
                    tokenOptions: store.acala.dexPools
                        .map((e) => e.map((e) => e.symbol).join('-'))
                        .toList(),
                    onSelect: (res) {
                      setState(() {
                        _tab = res;
                      });
                      globalDexLiquidityRefreshKey.currentState.show();
                    },
                  ),
                  Expanded(
                    child: ListView(
                      children: <Widget>[
                        _SystemCard(
                          reward: store.acala.swapPoolRewards[_tab],
                          fee: store.acala.swapFee,
                          token: _tab,
                          total: Fmt.bigIntToDouble(
                                  poolInfo?.sharesTotal ?? BigInt.zero,
                                  decimals)
                              .toStringAsFixed(3),
                          userStaked: Fmt.bigIntToDouble(
                                  poolInfo?.shares ?? BigInt.zero, decimals)
                              .toStringAsFixed(3),
                          actions: Row(
                            children: [
                              Expanded(
                                child: RoundedButton(
                                  text: 'stake',
                                  onPressed: _onStake,
                                ),
                              ),
                              (poolInfo?.shares ?? BigInt.zero) > BigInt.zero
                                  ? Container(width: 16)
                                  : Container(),
                              (poolInfo?.shares ?? BigInt.zero) > BigInt.zero
                                  ? Expanded(
                                      child: RoundedButton(
                                        text: 'unstake',
                                        onPressed: _onUnstake,
                                      ),
                                    )
                                  : Container()
                            ],
                          ),
                        ),
                        _UserCard(
                          share: userShare,
                          poolInfo: poolInfo,
                          decimals: decimals,
                          lpAmountString: lpAmountString,
                          token: _tab,
                          onWithdrawReward: () =>
                              _onWithdrawReward(poolInfo.reward),
                        )
                      ],
                    ),
                  ),
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: Container(
                          color: Colors.blue,
                          child: FlatButton(
                              padding: EdgeInsets.only(top: 16, bottom: 16),
                              child: Text(
                                dic['earn.deposit'],
                                style: TextStyle(color: cardColor),
                              ),
                              onPressed: () {
                                Navigator.of(context).pushNamed(
                                  AddLiquidityPage.route,
                                  arguments: _tab,
                                );
                              }),
                        ),
                      ),
                      share > BigInt.zero
                          ? Expanded(
                              child: Container(
                                color: primaryColor,
                                child: FlatButton(
                                  padding: EdgeInsets.only(top: 16, bottom: 16),
                                  child: Text(
                                    dic['earn.withdraw'],
                                    style: TextStyle(color: cardColor),
                                  ),
                                  onPressed: () =>
                                      Navigator.of(context).pushNamed(
                                    WithdrawLiquidityPage.route,
                                    arguments: _tab,
                                  ),
                                ),
                              ),
                            )
                          : Container(),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _SystemCard extends StatelessWidget {
  _SystemCard({
    this.reward,
    this.fee,
    this.token,
    this.total,
    this.userStaked,
    this.actions,
  });
  final double reward;
  final double fee;
  final String token;
  final String total;
  final String userStaked;
  final Widget actions;
  @override
  Widget build(BuildContext context) {
    final Map dic = I18n.of(context).acala;
    final Color primary = Theme.of(context).primaryColor;
    final TextStyle primaryText = TextStyle(
      fontSize: 22,
      fontWeight: FontWeight.bold,
      color: primary,
    );
    print(total);
    return RoundedCard(
      margin: EdgeInsets.all(16),
      padding: EdgeInsets.all(16),
      child: Column(
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              Column(
                children: <Widget>[
                  Text(dic['earn.pool']),
                  Padding(
                    padding: EdgeInsets.only(top: 8, bottom: 8),
                    child: Text(total, style: primaryText),
                  ),
                ],
              ),
              Column(
                children: <Widget>[
                  Text('staked'),
                  Padding(
                    padding: EdgeInsets.only(top: 8, bottom: 8),
                    child: Text(userStaked, style: primaryText),
                  ),
                ],
              )
            ],
          ),
          Divider(height: 24),
          Row(
            children: <Widget>[
              InfoItem(
                crossAxisAlignment: CrossAxisAlignment.center,
                title: dic['earn.reward.year'],
                content: Fmt.ratio(reward),
              ),
              InfoItem(
                crossAxisAlignment: CrossAxisAlignment.center,
                title: dic['earn.fee'],
                content: Fmt.ratio(fee),
              ),
            ],
          ),
          Divider(height: 24),
          actions
        ],
      ),
    );
  }
}

class _UserCard extends StatelessWidget {
  _UserCard({
    this.share,
    this.poolInfo,
    this.decimals,
    this.token,
    this.lpAmountString,
    this.onWithdrawReward,
  });
  final double share;
  final DexPoolInfoData poolInfo;
  final int decimals;
  final String token;
  final String lpAmountString;
  final Function onWithdrawReward;
  @override
  Widget build(BuildContext context) {
    final Map dic = I18n.of(context).acala;
    final reward = poolInfo?.reward?.incentive ?? BigInt.zero;
    final rewardSaving = poolInfo?.reward?.saving ?? BigInt.zero;
    final Color primary = Theme.of(context).primaryColor;
    final TextStyle primaryText = TextStyle(
      fontSize: 22,
      fontWeight: FontWeight.bold,
      color: primary,
    );
    return RoundedCard(
      margin: EdgeInsets.fromLTRB(16, 0, 16, 24),
      padding: EdgeInsets.all(16),
      child: Stack(
        alignment: AlignmentDirectional.topEnd,
        children: <Widget>[
          Column(
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  Column(
                    children: <Widget>[
                      Text('incentive (ACA)'),
                      Padding(
                        padding: EdgeInsets.only(top: 8, bottom: 8),
                        child: Text(
                            Fmt.bigIntToDouble(reward, decimals)
                                .toStringAsFixed(3),
                            style: primaryText),
                      ),
                    ],
                  ),
                  Column(
                    children: <Widget>[
                      Text('saving (aUSD)'),
                      Padding(
                        padding: EdgeInsets.only(top: 8, bottom: 8),
                        child: Text(
                            Fmt.bigIntToDouble(rewardSaving, decimals)
                                .toStringAsFixed(2),
                            style: primaryText),
                      ),
                    ],
                  )
                ],
              ),
              Padding(
                padding: EdgeInsets.only(top: 8),
                child: Text(
                  '${Fmt.tokenView(token)} = $lpAmountString',
                  style: TextStyle(fontSize: 12),
                ),
              ),
              Divider(height: 24),
              Row(
                children: [
                  Expanded(
                    child: RoundedButton(
                      text: 'harvest',
                      onPressed:
                          reward > BigInt.zero || rewardSaving > BigInt.zero
                              ? onWithdrawReward
                              : null,
                    ),
                  )
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
