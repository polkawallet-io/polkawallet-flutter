import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
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
  }

  @override
  Widget build(BuildContext context) {
    final Map dic = I18n.of(context).acala;
    return Scaffold(
      appBar: AppBar(title: Text(dic['loan.title']), centerTitle: true),
      body: SafeArea(
        child: RefreshIndicator(
          key: globalLoanRefreshKey,
          onRefresh: _fetchData,
          child: Column(
            children: <Widget>[
              CurrencyTab(collateral, _tab, (i) {
                setState(() {
                  _tab = i;
                });
              }),
              Expanded(
                child: ListView(
                  children: <Widget>[
                    Text('coll'),
                  ],
                ),
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
              )
            ],
          ),
        ),
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
