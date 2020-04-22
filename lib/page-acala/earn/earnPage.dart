import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:polka_wallet/common/components/infoItem.dart';
import 'package:polka_wallet/common/components/roundedCard.dart';
import 'package:polka_wallet/common/consts/settings.dart';
import 'package:polka_wallet/page-acala/earn/addLiquidityPage.dart';
import 'package:polka_wallet/page-acala/earn/withdrawLiquidityPage.dart';
import 'package:polka_wallet/page-acala/loan/loanAdjustPage.dart';
import 'package:polka_wallet/service/substrateApi/api.dart';
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
    print('refresh');
    await Future.wait([
      webApi.acala.fetchDexLiquidityPool(),
      webApi.acala.fetchDexLiquidityPoolShareTotal(),
      webApi.acala.fetchDexLiquidityPoolSwapRatios(),
      webApi.acala.fetchDexLiquidityPoolShare(_tab),
      webApi.acala.fetchDexLiquidityPoolShareRewards(_tab),
    ]);
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
          BigInt shareTotal =
              store.acala.swapPoolSharesTotal[_tab] ?? BigInt.zero;
          BigInt share = store.acala.swapPoolShares[_tab] ?? BigInt.zero;
          double userShare = share / shareTotal;

          Color cardColor = Theme.of(context).cardColor;
          Color primaryColor = Theme.of(context).primaryColor;

          List pool = store.acala.swapPool[_tab];
          double amountToken = Fmt.balanceDouble(
              pool != null ? pool[0].toString() : '',
              decimals: decimals);
          double amountStableCoin = Fmt.balanceDouble(
              pool != null ? pool[1].toString() : '',
              decimals: decimals);
          double amountTokenUser = amountToken * userShare;
          double amountStableCoinUser = amountStableCoin * userShare;

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
                          baseCoin: store.acala.acalaBaseCoin,
                          swapRatio: store.acala.swapPoolRatios[_tab] as String,
                          amountToken: amountToken.toString(),
                          amountStableCoin: amountStableCoin.toString(),
                        ),
                        _UserCard(
                          share: userShare,
                          reward: store.acala.swapPoolShareRewards[_tab],
                          token: _tab,
                          baseCoin: store.acala.acalaBaseCoin,
                          amountToken: amountTokenUser.toString(),
                          amountStableCoin: amountStableCoinUser.toString(),
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
                                  arguments: AddLiquidityPageParams(
                                    AddLiquidityPage.actionDeposit,
                                    _tab,
                                  ),
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

class _CurrencyTab extends StatelessWidget {
  _CurrencyTab(this.tabs, this.activeTab, this.onTabChange);
  final String activeTab;
  final List<String> tabs;
  final Function(String) onTabChange;

  @override
  Widget build(BuildContext context) {
    final Map dic = I18n.of(context).acala;
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
                        width: 32,
                        margin: EdgeInsets.only(right: 8),
                        child: activeTab == i
                            ? Image.asset('assets/images/assets/$i.png')
                            : Container(
                                width: 32,
                                height: 32,
                                decoration: BoxDecoration(
                                  color: Theme.of(context).dividerColor,
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(32),
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
    this.baseCoin,
    this.swapRatio,
    this.amountToken,
    this.amountStableCoin,
  });
  final double reward;
  final double fee;
  final String token;
  final String baseCoin;
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
                  Text(baseCoin),
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
              '${dic['dex.rate']} 1$token=$swapRatio$baseCoin',
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
    this.baseCoin,
    this.amountToken,
    this.amountStableCoin,
  });
  final double share;
  final BigInt reward;
  final String token;
  final String baseCoin;
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
      margin: EdgeInsets.fromLTRB(16, 0, 16, 24),
      padding: EdgeInsets.all(16),
      child: Column(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(bottom: 16),
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
                  Text(baseCoin),
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
                        reward > BigInt.zero
                            ? GestureDetector(
                                child: Padding(
                                  padding: EdgeInsets.only(left: 4),
                                  child: Icon(
                                    Icons.card_giftcard,
                                    size: 18,
                                    color: primary,
                                  ),
                                ),
                                onTap: () => print('rewards'),
                              )
                            : Container(),
                      ],
                    ),
                    Text(
                      Fmt.priceFloor(reward),
                      style: Theme.of(context).textTheme.display4,
                    )
                  ],
                ),
              )
            ],
          )
        ],
      ),
    );
  }
}
