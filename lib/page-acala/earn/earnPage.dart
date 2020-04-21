import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_svg/svg.dart';
import 'package:polka_wallet/common/components/infoItem.dart';
import 'package:polka_wallet/common/components/roundedCard.dart';
import 'package:polka_wallet/common/consts/settings.dart';
import 'package:polka_wallet/page-acala/loan/loanAdjustPage.dart';
import 'package:polka_wallet/page-acala/loan/loanCard.dart';
import 'package:polka_wallet/page-acala/loan/loanChart.dart';
import 'package:polka_wallet/page-acala/loan/loanCreatePage.dart';
import 'package:polka_wallet/page-acala/loan/loanDonutChart.dart';
import 'package:polka_wallet/service/substrateApi/api.dart';
import 'package:polka_wallet/store/acala/acala.dart';
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
      webApi.acala.fetchDexLiquidityPoolSwapRatios(),
      webApi.acala.fetchDexLiquidityPoolShare(_tab),
      webApi.acala.fetchDexLiquidityPoolShareRewards(_tab),
    ]);
//    webApi.acala.fetchAccountLoans();
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
    return Scaffold(
      backgroundColor: Theme.of(context).cardColor,
      appBar: AppBar(title: Text(dic['earn.title']), centerTitle: true),
      body: Observer(
        builder: (_) {
          BigInt share = store.acala.swapPoolShares[_tab] ?? BigInt.zero;

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
                    }),
                    Expanded(
                      child: ListView(
                        children: <Widget>[
                          _SystemCard(
                            reward: store.acala.swapPoolRewards[_tab],
                            fee: store.acala.swapFee,
                            token: _tab,
                            baseCoin: store.acala.acalaBaseCoin,
                            swapRatio:
                                store.acala.swapPoolRatios[_tab] as String,
                            amountToken: Fmt.balanceInt(
                                store.acala.swapPool[_tab][0].toString()),
                            amountStableCoin: Fmt.balanceInt(
                                store.acala.swapPool[_tab][1].toString()),
                          )
//                                loan.collaterals > BigInt.zero
//                                    ? LoanCard(loan, balance)
//                                    : RoundedCard(
//                                        margin: EdgeInsets.all(16),
//                                        padding:
//                                            EdgeInsets.fromLTRB(48, 24, 48, 24),
//                                        child: SvgPicture.asset(
//                                            'assets/images/acala/loan-start.svg'),
//                                      ),
//                                loan.debitInUSD > BigInt.zero
//                                    ? LoanChart(loan)
////                                    ? LoanDonutChart(loan)
//                                    : Container()
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
                                  if (share > BigInt.zero) {
                                    Navigator.of(context).pushNamed(
                                      LoanAdjustPage.route,
                                      arguments: LoanAdjustPageParams(
                                          LoanAdjustPage.actionTypeBorrow,
                                          _tab),
                                    );
                                  } else {
                                    Navigator.of(context).pushNamed(
                                      LoanCreatePage.route,
                                      arguments: LoanAdjustPageParams('', _tab),
                                    );
                                  }
                                }),
                          ),
                        ),
                        share > BigInt.zero
                            ? Expanded(
                                child: Container(
                                  color: primaryColor,
                                  child: FlatButton(
                                    padding:
                                        EdgeInsets.only(top: 16, bottom: 16),
                                    child: Text(
                                      dic['earn.withdraw'],
                                      style: TextStyle(color: cardColor),
                                    ),
                                    onPressed: () =>
                                        Navigator.of(context).pushNamed(
                                      LoanAdjustPage.route,
                                      arguments: LoanAdjustPageParams(
                                          LoanAdjustPage.actionTypePayback,
                                          _tab),
                                    ),
                                  ),
                                ),
                              )
                            : Container(),
                      ],
                    ),
                  ],
                )),
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
  final BigInt amountToken;
  final BigInt amountStableCoin;
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
                    Fmt.priceFloor(amountToken),
                    style: primaryText,
                  ),
                ],
              ),
              Column(
                children: <Widget>[
                  Text(baseCoin),
                  Text(
                    Fmt.priceFloor(amountStableCoin),
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
    this.reward,
    this.fee,
    this.token,
    this.baseCoin,
    this.amountToken,
    this.amountStableCoin,
  });
  final double reward;
  final double fee;
  final String token;
  final String baseCoin;
  final BigInt amountToken;
  final BigInt amountStableCoin;
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
                    Fmt.priceFloor(amountToken),
                    style: primaryText,
                  ),
                ],
              ),
              Column(
                children: <Widget>[
                  Text(baseCoin),
                  Text(
                    Fmt.priceFloor(amountStableCoin),
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
                title: dic['earn.reward.year'],
                content: Fmt.ratio(reward),
              ),
              InfoItem(
                crossAxisAlignment: CrossAxisAlignment.center,
                title: dic['earn.fee'],
                content: Fmt.ratio(fee),
              ),
            ],
          )
        ],
      ),
    );
  }
}
