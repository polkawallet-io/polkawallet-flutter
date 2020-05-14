import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:polka_wallet/common/components/infoItem.dart';
import 'package:polka_wallet/common/components/roundedCard.dart';
import 'package:polka_wallet/common/consts/settings.dart';
import 'package:polka_wallet/page-acala/earn/addLiquidityPage.dart';
import 'package:polka_wallet/page-acala/earn/earnHistoryPage.dart';
import 'package:polka_wallet/page-acala/earn/withdrawLiquidityPage.dart';
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

  String _tab = 'DOT';

  Future<void> _fetchData() async {
    webApi.acala.fetchDexLiquidityPoolSwapRatio(_tab);
    await webApi.acala.fetchDexPoolInfo(_tab);
  }

  Future<void> _onWithdrawReward(double reward) async {
    String amount = Fmt.doubleFormat(reward, length: 6);
    var args = {
      "title": I18n.of(context).acala['earn.get'],
      "txInfo": {
        "module": 'dex',
        "call": 'withdrawIncentiveInterest',
      },
      "detail": jsonEncode({
        "currencyId": _tab,
        "amount": '$amount $acala_stable_coin_view',
      }),
      "params": [_tab],
      "onFinish": (BuildContext txPageContext, Map res) {
        res['action'] = TxDexLiquidityData.actionReward;
        res['reward'] = amount;
        store.acala.setDexLiquidityTxs([res]);
        Navigator.popUntil(txPageContext, ModalRoute.withName(EarnPage.route));
        globalDexLiquidityRefreshKey.currentState.show();
      }
    };
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
    final int decimals = acala_token_decimals;
    return Scaffold(
      backgroundColor: Theme.of(context).cardColor,
      appBar: AppBar(title: Text(dic['earn.title']), centerTitle: true),
      body: Observer(
        builder: (_) {
          BigInt shareTotal = BigInt.zero;
          BigInt share = BigInt.zero;
          double userShare = 0;

          double amountToken = 0;
          double amountStableCoin = 0;
          double amountTokenUser = 0;
          double amountStableCoinUser = 0;

          DexPoolInfoData poolInfo = store.acala.dexPoolInfoMap[_tab];
          if (poolInfo != null) {
            shareTotal = poolInfo.sharesTotal;
            share = poolInfo.shares;
            userShare = share / shareTotal;

            amountToken =
                Fmt.bigIntToDouble(poolInfo.amountToken, decimals: decimals);
            amountStableCoin = Fmt.bigIntToDouble(poolInfo.amountStableCoin,
                decimals: decimals);
            amountTokenUser = amountToken * userShare;
            amountStableCoinUser = amountStableCoin * userShare;
          }

          double swapRatio = double.parse(
              (store.acala.swapPoolRatios[_tab] ?? '0').toString());

          Color cardColor = Theme.of(context).cardColor;
          Color primaryColor = Theme.of(context).primaryColor;

          return SafeArea(
            child: RefreshIndicator(
              key: globalDexLiquidityRefreshKey,
              onRefresh: _fetchData,
              child: Column(
                children: <Widget>[
                  _CurrencyTab(store.acala.swapTokens, _tab, (i) {
                    setState(() {
                      _tab = i;
                    });
                    globalDexLiquidityRefreshKey.currentState.show();
                  }),
                  Expanded(
                    child: ListView(
                      children: <Widget>[
                        _SystemCard(
                          reward: store.acala.swapPoolRewards[_tab],
                          fee: store.acala.swapFee,
                          token: _tab,
                          swapRatio: Fmt.doubleFormat(swapRatio, length: 2),
                          amountToken: Fmt.doubleFormat(amountToken),
                          amountStableCoin:
                              Fmt.doubleFormat(amountStableCoin, length: 2),
                        ),
                        _UserCard(
                          share: userShare,
                          reward: poolInfo != null ? poolInfo.reward : 0,
                          token: _tab,
                          amountToken: Fmt.doubleFormat(amountTokenUser),
                          amountStableCoin:
                              Fmt.doubleFormat(amountStableCoinUser, length: 2),
                          onWithdrawReward: () =>
                              _onWithdrawReward(poolInfo.reward),
                        )
                      ],
                    ),
                  ),
                  swapRatio > 0
                      ? Row(
                          children: <Widget>[
                            Expanded(
                              child: Container(
                                color: Colors.blue,
                                child: FlatButton(
                                    padding:
                                        EdgeInsets.only(top: 16, bottom: 16),
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
                                        padding: EdgeInsets.only(
                                            top: 16, bottom: 16),
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
                        )
                      : Container(),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _CurrencyTab extends StatelessWidget {
  _CurrencyTab(this.tabs, this.activeTab, this.onTabChange);
  final String activeTab;
  final List<String> tabs;
  final Function(String) onTabChange;

  @override
  Widget build(BuildContext context) {
    final double iconSize = 28;
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
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
        ],
      ),
      child: Row(
        children: tabs.map((i) {
          return Expanded(
            child: GestureDetector(
              child: Container(
                  padding: EdgeInsets.only(top: 8, bottom: 6),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        width: 2,
                        color: activeTab == i
                            ? Theme.of(context).primaryColor
                            : Theme.of(context).cardColor,
                      ),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Container(
                        width: iconSize,
                        margin: EdgeInsets.only(right: 8),
                        child: activeTab == i
                            ? Image.asset('assets/images/assets/$i.png')
                            : Container(
                                width: iconSize,
                                height: iconSize,
                                decoration: BoxDecoration(
                                  color: Theme.of(context).dividerColor,
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(iconSize),
                                  ),
                                ),
                              ),
                      ),
                      Text(
                        i,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: activeTab == i
                              ? Theme.of(context).primaryColor
                              : Theme.of(context).unselectedWidgetColor,
                        ),
                      ),
                    ],
                  )),
              onTap: () {
                if (activeTab != i) {
                  onTabChange(i);
                }
              },
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _SystemCard extends StatelessWidget {
  _SystemCard({
    this.reward,
    this.fee,
    this.token,
    this.swapRatio,
    this.amountToken,
    this.amountStableCoin,
  });
  final double reward;
  final double fee;
  final String token;
  final String swapRatio;
  final String amountToken;
  final String amountStableCoin;
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
          Padding(
            padding: EdgeInsets.only(bottom: 16),
            child: Text(dic['earn.pool']),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              Column(
                children: <Widget>[
                  Text(token),
                  Text(
                    amountToken,
                    style: primaryText,
                  ),
                ],
              ),
              Column(
                children: <Widget>[
                  Text(acala_stable_coin_view),
                  Text(
                    amountStableCoin,
                    style: primaryText,
                  ),
                ],
              )
            ],
          ),
          Padding(
            padding: EdgeInsets.only(top: 8),
            child: Text(
              '${dic['dex.rate']} 1 $token = $swapRatio $acala_stable_coin_view',
              style: TextStyle(fontSize: 12),
            ),
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
        ],
      ),
    );
  }
}

class _UserCard extends StatelessWidget {
  _UserCard({
    this.share,
    this.reward,
    this.token,
    this.amountToken,
    this.amountStableCoin,
    this.onWithdrawReward,
  });
  final double share;
  final double reward;
  final String token;
  final String amountToken;
  final String amountStableCoin;
  final Function onWithdrawReward;
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
      margin: EdgeInsets.fromLTRB(16, 0, 16, 24),
      padding: EdgeInsets.all(16),
      child: Stack(
        alignment: AlignmentDirectional.topEnd,
        children: <Widget>[
          Column(
            children: <Widget>[
              Padding(
                padding: EdgeInsets.only(top: 8, bottom: 20),
                child: Text(dic['earn.deposit.user']),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  Column(
                    children: <Widget>[
                      Text(token),
                      Text(
                        amountToken,
                        style: primaryText,
                      ),
                    ],
                  ),
                  Column(
                    children: <Widget>[
                      Text(acala_stable_coin_view),
                      Text(
                        amountStableCoin,
                        style: primaryText,
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
                    title: dic['earn.share'],
                    content: Fmt.ratio(share),
                  ),
                  Expanded(
                    child: Column(
                      children: <Widget>[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Text(dic['earn.reward']),
                            reward != null && reward >= 0.01
                                ? GestureDetector(
                                    child: Padding(
                                      padding: EdgeInsets.only(left: 4),
                                      child: Icon(
                                        Icons.card_giftcard,
                                        size: 18,
                                        color: primary,
                                      ),
                                    ),
                                    onTap: onWithdrawReward,
                                  )
                                : Container(),
                          ],
                        ),
                        Text(
                          '${Fmt.doubleFormat(reward, length: 4)} $acala_stable_coin_view',
                          style: Theme.of(context).textTheme.headline4,
                        )
                      ],
                    ),
                  )
                ],
              )
            ],
          ),
          GestureDetector(
            child: Container(
              child: Column(
                children: <Widget>[
                  Icon(Icons.history, color: primary),
                  Text(
                    dic['loan.txs'],
                    style: TextStyle(color: primary, fontSize: 12),
                  )
                ],
              ),
            ),
            onTap: () => Navigator.of(context)
                .pushNamed(EarnHistoryPage.route, arguments: token),
          ),
        ],
      ),
    );
  }
}
