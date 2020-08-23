import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:polka_wallet/common/consts/settings.dart';
import 'package:polka_wallet/store/acala/types/txLiquidityData.dart';
import 'package:polka_wallet/store/app.dart';
import 'package:polka_wallet/utils/format.dart';
import 'package:polka_wallet/utils/i18n/index.dart';

class EarnHistoryPage extends StatefulWidget {
  EarnHistoryPage(this.store);

  static const String route = '/acala/earn/txs';

  final AppStore store;

  @override
  _EarnHistoryPage createState() => _EarnHistoryPage(store);
}

class _EarnHistoryPage extends State<EarnHistoryPage> {
  _EarnHistoryPage(this.store);

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
            final int decimals = store.settings.networkState.tokenDecimals;
            final String token = ModalRoute.of(context).settings.arguments;
            List<TxDexLiquidityData> list =
                store.acala.txsDexLiquidity.reversed.toList();
            list.retainWhere((i) => i.currencyId == token);

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

                    TxDexLiquidityData detail = list[i];
                    String amount = '';
                    String image = 'assets/images/assets/assets_down.png';
                    switch (detail.action) {
                      case TxDexLiquidityData.actionDeposit:
                        amount =
                            '${Fmt.priceCeilBigInt(detail.amountToken, decimals)} ${detail.currencyId}\n+ ${Fmt.priceCeilBigInt(detail.amountStableCoin, decimals)} $acala_stable_coin_view';
                        image = 'assets/images/assets/assets_up.png';
                        break;
                      case TxDexLiquidityData.actionWithdraw:
                        amount =
                            '${Fmt.priceFloorBigInt(detail.amountShare, decimals, lengthFixed: 0)} Share';
                        break;
                      case TxDexLiquidityData.actionReward:
                        amount =
                            '${Fmt.priceCeilBigInt(detail.amountStableCoin, decimals)} $acala_stable_coin_view';
                        break;
                    }
                    return Container(
                      decoration: BoxDecoration(
                        border: Border(
                            bottom:
                                BorderSide(width: 0.5, color: Colors.black12)),
                      ),
                      child: ListTile(
                        title: Text(detail.action),
                        subtitle: Text(list[i].time.toString().split('.')[0]),
                        trailing: Container(
                          width: MediaQuery.of(context).size.width / 2,
                          child: Row(
                            children: <Widget>[
                              Expanded(
                                child: Padding(
                                  padding: EdgeInsets.only(right: 12),
                                  child: Text(
                                    amount,
                                    style:
                                        Theme.of(context).textTheme.headline4,
                                    textAlign: TextAlign.end,
                                  ),
                                ),
                              ),
                              Image.asset(image)
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
