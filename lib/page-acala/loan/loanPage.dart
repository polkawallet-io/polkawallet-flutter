import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:polka_wallet/common/components/infoItem.dart';
import 'package:polka_wallet/common/components/roundedCard.dart';
import 'package:polka_wallet/common/theme.dart';
import 'package:polka_wallet/service/substrateApi/api.dart';
import 'package:polka_wallet/store/app.dart';
import 'package:polka_wallet/utils/UI.dart';
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

  final List<String> collateral = ['DOT', 'XBTC'];

  String _tab = 'DOT';

  Future<void> _fetchData() async {
    print('refresh');
    webApi.acala.fetchPrices();
//    webApi.acala.fetchAccountLoans();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      globalLoanRefreshKey.currentState.show();
    });
  }

  @override
  Widget build(BuildContext context) {
    final Map dic = I18n.of(context).acala;
    bool haveLoan = true;
    return Scaffold(
      appBar: AppBar(title: Text(dic['loan.title']), centerTitle: true),
      body: Observer(
        builder: (_) {
          print(store.acala.prices);
          print(store.acala.loans);
          return SafeArea(
            child: RefreshIndicator(
              key: globalLoanRefreshKey,
              onRefresh: _fetchData,
              child: ListView(
                children: <Widget>[
                  CurrencyTab(collateral, _tab, (i) {
                    setState(() {
                      _tab = i;
                    });
                  }),
                  haveLoan
                      ? RoundedCard(
                          margin: EdgeInsets.all(16),
                          padding: EdgeInsets.fromLTRB(16, 32, 16, 16),
                          child: Column(
                            children: <Widget>[
                              Text(dic['loan.borrowed'] + 'aUSD'),
                              Text(
                                '300.56',
                                style: TextStyle(
                                    fontSize: 36,
                                    color: Theme.of(context).primaryColor),
                              ),
                              Row(
                                children: <Widget>[
                                  Expanded(
                                    child: FlatButton(
                                      child: Text('borrow'),
                                      color: Theme.of(context).primaryColor,
                                    ),
                                  ),
                                  Expanded(
                                    child: FlatButton(
                                      child: Text('pay back'),
                                      color: Theme.of(context).primaryColor,
                                    ),
                                  )
                                ],
                              ),
                              Divider(height: 48),
                              Row(
                                children: <Widget>[
                                  InfoItem(
                                    title: dic['loan.collateral'],
                                    content: '0',
                                  ),
                                  InfoItem(
                                    title: dic['collateral.require'],
                                    content: '0',
                                  ),
                                ],
                              )
                            ],
                          ),
                        )
                      : Container(),
                  haveLoan ? LoanChart() : Container()
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class CurrencyTab extends StatelessWidget {
  CurrencyTab(this.tabs, this.activeTab, this.onTabChange);
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
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            i,
                            style: Theme.of(context).textTheme.display4,
                          ),
                          Text(
                            '\$ 345.984',
                            style: TextStyle(
                                fontSize: 12,
                                color: Theme.of(context).unselectedWidgetColor),
                          )
                        ],
                      )
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

class LoanChart extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return RoundedCard(
      margin: EdgeInsets.fromLTRB(16, 8, 16, 32),
      padding: EdgeInsets.all(16),
      child: Container(
        padding: EdgeInsets.only(top: 8, right: 8),
        decoration: BoxDecoration(
          border: Border(
            left: BorderSide(),
            bottom: BorderSide(),
          ),
        ),
        child: Stack(
          alignment: AlignmentDirectional.bottomStart,
          children: <Widget>[
            // borrowed amount
            Container(
              color: color_green_45,
              height: 60,
              child: Padding(
                padding: EdgeInsets.only(left: 8, top: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[Text('\$300'), Text('borrowed')],
                ),
              ),
            ),
            // the liquidation line
            Container(
              height: 150,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Divider(color: Colors.red),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[Text('105%'), Text('Liquidation')],
                  ),
                ],
              ),
            ),
            // the required line
            Container(
              height: 120,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Divider(color: Colors.orange),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[Text('120%'), Text('Required')],
                  ),
                ],
              ),
            ),
            Container(
              height: 160,
              decoration: BoxDecoration(
                color: color_green_26,
              ),
              child: Padding(
                padding: EdgeInsets.only(left: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[Text('1200'), Text('Collateral')],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
