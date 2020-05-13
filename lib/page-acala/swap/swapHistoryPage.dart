import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:polka_wallet/store/acala/types/txSwapData.dart';
import 'package:polka_wallet/store/app.dart';
import 'package:polka_wallet/utils/i18n/index.dart';

class SwapHistoryPage extends StatefulWidget {
  SwapHistoryPage(this.store);

  static const String route = '/acala/swap/txs';

  final AppStore store;

  @override
  _SwapHistoryPage createState() => _SwapHistoryPage(store);
}

class _SwapHistoryPage extends State<SwapHistoryPage> {
  _SwapHistoryPage(this.store);

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
            final Map dic = I18n.of(context).acala;
            List<TxSwapData> list = store.acala.txsSwap.reversed.toList();

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
                                        fontSize: 18, color: Colors.black38),
                                  ),
                                )
                              ],
                            )
                          : Container();
                    }
//                    BlockData block = blockMap[list[i].block];
//                    String time = 'time';
//                    if (block != null) {
//                      time = block.time.toString().split('.')[0];
//                    }

                    TxSwapData detail = list[i];
                    return Container(
                      decoration: BoxDecoration(
                        border: Border(
                            bottom:
                                BorderSide(width: 0.5, color: Colors.black12)),
                      ),
                      child: ListTile(
                        title: Text(
                            '${dic['dex.tx.pay']} ${detail.amountPay} ${detail.tokenPay}'),
                        subtitle: Text(list[i].time.toString()),
                        trailing: Container(
                          width: 140,
                          child: Row(
                            children: <Widget>[
                              Expanded(
                                child: Padding(
                                  padding: EdgeInsets.only(right: 12),
                                  child: Text(
                                    '${detail.amountReceive} ${detail.tokenReceive}',
                                    style:
                                        Theme.of(context).textTheme.headline4,
                                    textAlign: TextAlign.end,
                                  ),
                                ),
                              ),
                              Image.asset(
                                  'assets/images/assets/assets_down.png')
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
