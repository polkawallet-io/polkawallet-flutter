import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:polka_wallet/common/components/infoItem.dart';
import 'package:polka_wallet/common/components/roundedButton.dart';
import 'package:polka_wallet/common/components/roundedCard.dart';
import 'package:polka_wallet/common/consts/settings.dart';
import 'package:polka_wallet/page-acala/earn/LPStakePage.dart';
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

  String _tab = 'aUSD-DOT';

  Future<void> _fetchData() async {
    await Future.wait([
      webApi.acala.fetchDexLiquidityPoolRewards(),
      webApi.assets.fetchBalance(),
      webApi.acala.fetchDexPoolInfo(_tab),
    ]);
  }

  Future<void> _onStake() async {
    Navigator.of(context).pushNamed(
      LPStakePage.route,
      arguments: LPStakePageParams(_tab, LPStakePage.actionStake),
    );
  }

  Future<void> _onUnStake() async {
    Navigator.of(context).pushNamed(
      LPStakePage.route,
      arguments: LPStakePageParams(_tab, LPStakePage.actionUnStake),
    );
  }

  Future<void> _onWithdrawReward(LPRewardData reward) async {
    final decimals = store.settings.networkState.tokenDecimals;
    final symbol = store.settings.networkState.tokenSymbol;
    final incentiveReward = Fmt.token(reward.incentive, decimals);
    final savingReward = Fmt.token(reward.saving, decimals);
    final pool =
        jsonEncode(_tab.split('-').map((e) => e.toUpperCase()).toList());

    var args;
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
          BigInt issuance = BigInt.zero;
          BigInt shareTotal = BigInt.zero;
          BigInt share = BigInt.zero;
          double stakeShare = 0;
          double poolShare = 0;
          double reward = 0;
          double rewardSaving = 0;

          String lpAmountString = '~';

          DexPoolInfoData poolInfo = store.acala.dexPoolInfoMap[_tab];
          if (poolInfo != null) {
            issuance = poolInfo.issuance;
            shareTotal = poolInfo.sharesTotal;
            share = poolInfo.shares;
            stakeShare = share / shareTotal;
            poolShare = share / issuance;

            final lpAmount =
                Fmt.bigIntToDouble(poolInfo.amountToken, decimals) * poolShare;
            final lpAmount2 =
                Fmt.bigIntToDouble(poolInfo.amountStableCoin, decimals) *
                    poolShare;
            final pair = _tab.split('-');
            lpAmountString =
                '${lpAmount.toStringAsFixed(3)} ${pair[0]} + ${lpAmount2.toStringAsFixed(3)} ${pair[1]}';
            reward = (store.acala.swapPoolRewards[_tab] ?? 0) * stakeShare;
            rewardSaving =
                (store.acala.swapPoolSavingRewards[_tab] ?? 0) * stakeShare;
          }

          final balanceIndex = store.acala.lpTokens
              .indexWhere((e) => e.currencyId.join('-') == _tab.toUpperCase());
          BigInt balance = BigInt.zero;
          if (balanceIndex >= 0) {
            balance = Fmt.balanceInt(store.acala.lpTokens[balanceIndex].free);
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
                          token: _tab,
                          total: Fmt.bigIntToDouble(
                              poolInfo?.sharesTotal ?? BigInt.zero, decimals),
                          userStaked: Fmt.bigIntToDouble(
                              poolInfo?.shares ?? BigInt.zero, decimals),
                          lpAmountString: lpAmountString,
                          actions: Row(
                            children: [
                              Expanded(
                                child: RoundedButton(
                                  color: Colors.blue,
                                  text: dic['earn.stake'],
                                  onPressed:
                                      balance > BigInt.zero ? _onStake : null,
                                ),
                              ),
                              (poolInfo?.shares ?? BigInt.zero) > BigInt.zero
                                  ? Container(width: 16)
                                  : Container(),
                              (poolInfo?.shares ?? BigInt.zero) > BigInt.zero
                                  ? Expanded(
                                      child: RoundedButton(
                                        text: dic['earn.unStake'],
                                        onPressed: _onUnStake,
                                      ),
                                    )
                                  : Container()
                            ],
                          ),
                        ),
                        _UserCard(
                          share: stakeShare,
                          poolInfo: poolInfo,
                          decimals: decimals,
                          token: _tab,
                          rewardEstimate: reward,
                          rewardSavingEstimate: rewardSaving,
                          fee: store.acala.swapFee,
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
                      balance > BigInt.zero
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
    this.token,
    this.total,
    this.userStaked,
    this.lpAmountString,
    this.actions,
  });
  final String token;
  final double total;
  final double userStaked;
  final String lpAmountString;
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
    return RoundedCard(
      margin: EdgeInsets.all(16),
      padding: EdgeInsets.all(16),
      child: Column(
        children: <Widget>[
          Column(
            children: <Widget>[
              Text('${dic['earn.staked']} ${Fmt.tokenView(token)}'),
              Padding(
                padding: EdgeInsets.only(top: 16, bottom: 8),
                child: Text(userStaked.toStringAsFixed(3), style: primaryText),
              ),
            ],
          ),
          Padding(
            padding: EdgeInsets.only(bottom: 16),
            child: Text(
              '≈ $lpAmountString',
              style: TextStyle(fontSize: 12),
            ),
          ),
          Row(
            children: <Widget>[
              InfoItem(
                crossAxisAlignment: CrossAxisAlignment.center,
                title: dic['earn.pool'],
                content: total.toStringAsFixed(3),
              ),
              InfoItem(
                crossAxisAlignment: CrossAxisAlignment.center,
                title: dic['earn.share'],
                content: Fmt.ratio(userStaked / total),
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
    this.rewardEstimate,
    this.rewardSavingEstimate,
    this.fee,
    this.onWithdrawReward,
  });
  final double share;
  final DexPoolInfoData poolInfo;
  final int decimals;
  final String token;
  final double rewardEstimate;
  final double rewardSavingEstimate;
  final double fee;
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

    final canClaim = reward > BigInt.zero || rewardSaving > BigInt.zero;

    return RoundedCard(
      margin: EdgeInsets.fromLTRB(16, 0, 16, 24),
      padding: EdgeInsets.all(16),
      child: Stack(
        alignment: AlignmentDirectional.topEnd,
        children: <Widget>[
          Column(
            children: <Widget>[
              Padding(
                padding: EdgeInsets.only(bottom: 16),
                child: Text(dic['earn.reward']),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  Column(
                    children: <Widget>[
                      Text('${dic['earn.incentive']} (ACA)'),
                      Padding(
                        padding: EdgeInsets.only(top: 8, bottom: 8),
                        child: Text(
                            Fmt.bigIntToDouble(
                                    reward < BigInt.zero ? BigInt.zero : reward,
                                    decimals)
                                .toStringAsFixed(3),
                            style: primaryText),
                      ),
                    ],
                  ),
                  Column(
                    children: <Widget>[
                      Text('${dic['earn.saving']} (aUSD)'),
                      Padding(
                        padding: EdgeInsets.only(top: 8, bottom: 8),
                        child: Text(
                            Fmt.bigIntToDouble(
                                    rewardSaving < BigInt.zero
                                        ? BigInt.zero
                                        : rewardSaving,
                                    decimals)
                                .toStringAsFixed(2),
                            style: primaryText),
                      ),
                    ],
                  )
                ],
              ),
              Padding(
                padding: EdgeInsets.only(bottom: 4),
                child: Text(
                  '${dic['earn.incentive']} ≈ ${Fmt.priceFloor(rewardEstimate, lengthMax: 6)} ACA / day',
                  style: TextStyle(fontSize: 12),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(bottom: 4),
                child: Text(
                  '${dic['earn.saving']} ≈ ${Fmt.priceFloor(rewardSavingEstimate)} aUSD / day',
                  style: TextStyle(fontSize: 12),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(bottom: 8),
                child: Text(
                  '${dic['earn.fee']} ${Fmt.ratio(fee)}',
                  style: TextStyle(fontSize: 12),
                ),
              ),
              canClaim
                  ? RoundedButton(
                      text: dic['earn.claim'],
                      onPressed: onWithdrawReward,
                    )
                  : Container(),
            ],
          ),
        ],
      ),
    );
  }
}
