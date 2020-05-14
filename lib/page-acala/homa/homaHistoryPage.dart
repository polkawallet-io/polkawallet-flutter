import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:polka_wallet/store/acala/types/txHomaData.dart';
import 'package:polka_wallet/store/app.dart';
import 'package:polka_wallet/utils/i18n/index.dart';

class HomaHistoryPage extends StatefulWidget {
  HomaHistoryPage(this.store);

  static const String route = '/acala/homa/txs';

  final AppStore store;

  @override
  _HomaHistoryPage createState() => _HomaHistoryPage(store);
}

class _HomaHistoryPage extends State<HomaHistoryPage> {
  _HomaHistoryPage(this.store);

  final AppStore store;

  final GlobalKey<RefreshIndicatorState> _refreshKey =
      new GlobalKey<RefreshIndicatorState>();

  int _txsPage = 1;
  bool _isLastPage = false;
  ScrollController _scrollController;

  Future<void> _fetchData() async {
//    List res = await webApi.acala.updateTxs(_txsPage);
//
//    if (res.length < tx_list_page_size) {
//      setState(() {
//        _isLastPage = true;
//      });
//    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refreshKey.currentState.show();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(I18n.of(context).acala['loan.txs']),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Observer(
          builder: (_) {
            List<TxHomaData> list = store.acala.txsHoma.reversed.toList();
            return RefreshIndicator(
                key: _refreshKey,
                onRefresh: _fetchData,
                child: ListView.builder(
                  itemCount: list.length + 1,
                  itemBuilder: (BuildContext context, int i) {
                    if (i == list.length) {
                      return _isLastPage
                          ? Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Padding(
                                  padding: EdgeInsets.all(16),
                                  child: Text(
                                    I18n.of(context).assets['end'],
                                    style: TextStyle(
                                      fontSize: 18,
                                      color: Colors.black38,
                                    ),
                                  ),
                                )
                              ],
                            )
                          : Container();
                    }

                    TxHomaData detail = list[i];

                    String amountPay = detail.amountPay ?? '0';
                    String amountReceive = detail.amountReceive ?? '0';
                    String icon = 'assets_up.png';
                    if (detail.action == TxHomaData.actionRedeem) {
                      amountPay += ' LDOT';
                      amountReceive += ' DOT';
                    } else {
                      amountPay += ' DOT';
                      amountReceive += ' LDOT';
                    }
                    return Container(
                      decoration: BoxDecoration(
                        border: Border(
                            bottom:
                                BorderSide(width: 0.5, color: Colors.black12)),
                      ),
                      child: ListTile(
                        title: Text('${list[i].action} $amountReceive'),
                        subtitle: Text(list[i].time.toString()),
                        trailing: Container(
                          width: 140,
                          child: Row(
                            children: <Widget>[
                              Expanded(
                                child: Padding(
                                  padding: EdgeInsets.only(right: 12),
                                  child: Text(
                                    amountPay,
                                    style:
                                        Theme.of(context).textTheme.headline4,
                                    textAlign: TextAlign.end,
                                  ),
                                ),
                              ),
                              Image.asset('assets/images/assets/$icon')
                            ],
                          ),
                        ),
//                        onTap: () {
//                          Navigator.pushNamed(context, LoanTxDetailPage.route,
//                              arguments: list[i]);
//                        },
                      ),
                    );
                  },
                ));
          },
        ),
      ),
    );
  }
}
