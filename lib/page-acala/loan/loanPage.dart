import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_svg/svg.dart';
import 'package:polka_wallet/common/components/roundedCard.dart';
import 'package:polka_wallet/common/consts/settings.dart';
import 'package:polka_wallet/page-acala/loan/loanAdjustPage.dart';
import 'package:polka_wallet/page-acala/loan/loanCard.dart';
import 'package:polka_wallet/page-acala/loan/loanChart.dart';
import 'package:polka_wallet/page-acala/loan/loanCreatePage.dart';
import 'package:polka_wallet/service/substrateApi/api.dart';
import 'package:polka_wallet/store/acala/types/loanType.dart';
import 'package:polka_wallet/store/app.dart';
import 'package:polka_wallet/utils/UI.dart';
import 'package:polka_wallet/utils/format.dart';
import 'package:polka_wallet/utils/i18n/index.dart';

class LoanPage extends StatefulWidget {
  LoanPage(this.store);

  static const String route = '/acala/loan';
  final AppStore store;

  @override
  _LoanPageState createState() => _LoanPageState(store);
}

class _LoanPageState extends State<LoanPage> {
  _LoanPageState(this.store);

  final AppStore store;

  String _tab = 'DOT';

  Future<void> _fetchData() async {
    await Future.wait([
      webApi.acala.fetchTokens(store.account.currentAccount.pubKey),
      webApi.acala.fetchLoanTypes(),
    ]);
    webApi.acala.fetchAccountLoans();
  }

  @override
  void initState() {
    super.initState();
    webApi.acala.subscribeTokenPrices();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      globalLoanRefreshKey.currentState.show();
    });
  }

  @override
  void dispose() {
    webApi.acala.unsubscribeTokenPrices();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Map dic = I18n.of(context).acala;
    return Scaffold(
      backgroundColor: Theme.of(context).cardColor,
      appBar: AppBar(title: Text(dic['loan.title']), centerTitle: true),
      body: Observer(
        builder: (_) {
          LoanData loan = store.acala.loans[_tab];

          String balance = Fmt.priceFloorBigInt(
              Fmt.balanceInt(store.assets.tokenBalances[acala_stable_coin]));

          Color cardColor = Theme.of(context).cardColor;
          Color primaryColor = Theme.of(context).primaryColor;
          return SafeArea(
            child: RefreshIndicator(
                key: globalLoanRefreshKey,
                onRefresh: _fetchData,
                child: Column(
                  children: <Widget>[
                    CurrencyTab(store.acala.loanTypes, _tab, store.acala.prices,
                        (i) {
                      setState(() {
                        _tab = i;
                      });
                    }),
                    Expanded(
                      child: loan != null
                          ? ListView(
                              children: <Widget>[
                                loan.collaterals > BigInt.zero
                                    ? LoanCard(loan, balance)
                                    : RoundedCard(
                                        margin: EdgeInsets.all(16),
                                        padding:
                                            EdgeInsets.fromLTRB(48, 24, 48, 24),
                                        child: SvgPicture.asset(
                                            'assets/images/acala/loan-start.svg'),
                                      ),
                                loan.debitInUSD > BigInt.zero
                                    ? LoanChart(loan)
//                                    ? LoanDonutChart(loan)
                                    : Container()
                              ],
                            )
                          : Container(),
                    ),
                    store.acala.loanTypes.length > 0
                        ? Row(
                            children: <Widget>[
                              Expanded(
                                child: Container(
                                  color: Colors.blue,
                                  child: FlatButton(
                                      padding:
                                          EdgeInsets.only(top: 16, bottom: 16),
                                      child: Text(
                                        dic['loan.borrow'],
                                        style: TextStyle(color: cardColor),
                                      ),
                                      onPressed: () {
                                        if (loan != null &&
                                            loan.collaterals > BigInt.zero) {
                                          Navigator.of(context).pushNamed(
                                            LoanAdjustPage.route,
                                            arguments: LoanAdjustPageParams(
                                                LoanAdjustPage.actionTypeBorrow,
                                                _tab),
                                          );
                                        } else {
                                          Navigator.of(context).pushNamed(
                                            LoanCreatePage.route,
                                            arguments:
                                                LoanAdjustPageParams('', _tab),
                                          );
                                        }
                                      }),
                                ),
                              ),
                              loan != null && loan.debitInUSD > BigInt.zero
                                  ? Expanded(
                                      child: Container(
                                        color: primaryColor,
                                        child: FlatButton(
                                          padding: EdgeInsets.only(
                                              top: 16, bottom: 16),
                                          child: Text(
                                            dic['loan.payback'],
                                            style: TextStyle(color: cardColor),
                                          ),
                                          onPressed: () =>
                                              Navigator.of(context).pushNamed(
                                            LoanAdjustPage.route,
                                            arguments: LoanAdjustPageParams(
                                                LoanAdjustPage
                                                    .actionTypePayback,
                                                _tab),
                                          ),
                                        ),
                                      ),
                                    )
                                  : Container(),
                            ],
                          )
                        : Container(),
                  ],
                )),
          );
        },
      ),
    );
  }
}

class CurrencyTab extends StatelessWidget {
  CurrencyTab(this.tabs, this.activeTab, this.prices, this.onTabChange);
  final String activeTab;
  final List<LoanType> tabs;
  final Map<String, BigInt> prices;
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
          String price = Fmt.priceCeilBigInt(prices[i.token],
              decimals: acala_token_decimals);
          return Expanded(
            child: GestureDetector(
              child: Container(
                  padding: EdgeInsets.only(top: 8, bottom: 6),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        width: 2,
                        color: activeTab == i.token
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
                        child: activeTab == i.token
                            ? Image.asset('assets/images/assets/${i.token}.png')
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
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            i.token,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: activeTab == i.token
                                  ? Theme.of(context).primaryColor
                                  : Theme.of(context).unselectedWidgetColor,
                            ),
                          ),
                          Text(
                            '\$$price',
                            style: TextStyle(
                              fontSize: 12,
                              color: Theme.of(context).unselectedWidgetColor,
                            ),
                          )
                        ],
                      )
                    ],
                  )),
              onTap: () {
                if (activeTab != i.token) {
                  onTabChange(i.token);
                }
              },
            ),
          );
        }).toList(),
      ),
    );
  }
}
