import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_svg/svg.dart';
import 'package:polka_wallet/common/components/roundedCard.dart';
import 'package:polka_wallet/common/consts/settings.dart';
import 'package:polka_wallet/page-acala/loan/loanAdjustPage.dart';
import 'package:polka_wallet/page-acala/loan/loanCard.dart';
import 'package:polka_wallet/page-acala/loan/loanChart.dart';
import 'package:polka_wallet/page-acala/loan/loanCreatePage.dart';
import 'package:polka_wallet/page-acala/loan/loanHistoryPage.dart';
import 'package:polka_wallet/page/assets/transfer/currencySelectPage.dart';
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
    return Observer(
      builder: (_) {
        final LoanData loan = store.acala.loans[_tab];

        final int decimals = store.settings.networkState.tokenDecimals;
        final String balance = Fmt.priceFloorBigInt(
          Fmt.balanceInt(store.assets.tokenBalances[acala_stable_coin]),
          decimals,
        );

        final Color cardColor = Theme.of(context).cardColor;
        final Color primaryColor = Theme.of(context).primaryColor;
        return Scaffold(
          backgroundColor: Theme.of(context).cardColor,
          appBar: AppBar(
            title: Text(dic['loan.title']),
            centerTitle: true,
            actions: <Widget>[
              IconButton(
                icon: Icon(Icons.history),
                onPressed: () => Navigator.of(context)
                    .pushNamed(LoanHistoryPage.route, arguments: loan.type),
              )
            ],
          ),
          body: SafeArea(
            child: RefreshIndicator(
              key: globalLoanRefreshKey,
              onRefresh: _fetchData,
              child: Column(
                children: <Widget>[
                  CurrencySelector(
                    tokenOptions:
                        store.acala.loanTypes.map((e) => e.token).toList(),
                    token: _tab,
                    decimals: decimals,
                    price: store.acala.prices[_tab],
                    onSelect: (res) {
                      if (res != null) {
                        setState(() {
                          _tab = res;
                        });
                      }
                    },
                  ),
                  Expanded(
                    child: loan != null
                        ? ListView(
                            children: <Widget>[
                              loan.collaterals > BigInt.zero
                                  ? LoanCard(loan, balance, decimals)
                                  : RoundedCard(
                                      margin: EdgeInsets.all(16),
                                      padding:
                                          EdgeInsets.fromLTRB(48, 24, 48, 24),
                                      child: SvgPicture.asset(
                                          'assets/images/acala/loan-start.svg'),
                                    ),
                              loan.debitInUSD > BigInt.zero
                                  ? LoanChart(loan, decimals)
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
                                              LoanAdjustPage.actionTypePayback,
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
              ),
            ),
          ),
        );
      },
    );
  }
}

class CurrencySelector extends StatelessWidget {
  CurrencySelector({
    this.tokenOptions,
    this.token,
    this.decimals,
    this.price,
    this.onSelect,
  });
  final List<String> tokenOptions;
  final String token;
  final int decimals;
  final BigInt price;
  final Function(String) onSelect;
  @override
  Widget build(BuildContext context) {
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
      child: ListTile(
        leading: CircleAvatar(
          child: Image.asset('assets/images/assets/$token.png'),
          radius: 16,
        ),
        title: Text(
          Fmt.tokenView(token),
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).primaryColor,
          ),
        ),
        subtitle: price != null
            ? Text(
                '\$${Fmt.token(price, decimals)}',
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).unselectedWidgetColor,
                ),
              )
            : null,
        trailing: Icon(Icons.arrow_forward_ios, size: 18),
        onTap: () async {
          final res = await Navigator.of(context).pushNamed(
            CurrencySelectPage.route,
            arguments: tokenOptions,
          );
          if (res != null) {
            onSelect(res);
          }
        },
      ),
    );
  }
}
