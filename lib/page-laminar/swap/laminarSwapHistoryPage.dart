import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:polka_wallet/common/components/listTail.dart';
import 'package:polka_wallet/common/consts/settings.dart';
import 'package:polka_wallet/store/app.dart';
import 'package:polka_wallet/store/laminar/types/laminarTxSwapData.dart';
import 'package:polka_wallet/utils/i18n/index.dart';

class LaminarSwapHistoryPage extends StatefulWidget {
  LaminarSwapHistoryPage(this.store);

  static const String route = '/laminar/swap/txs';

  final AppStore store;

  @override
  _LaminarSwapHistoryPageState createState() => _LaminarSwapHistoryPageState();
}

class _LaminarSwapHistoryPageState extends State<LaminarSwapHistoryPage> {
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
            List<LaminarTxSwapData> list =
                widget.store.laminar.txsSwap.reversed.toList();

            return ListView.builder(
              itemCount: list.length + 1,
              itemBuilder: (BuildContext context, int i) {
                if (i == list.length) {
                  return ListTail(isLoading: false, isEmpty: list.length == 0);
                }

                final LaminarTxSwapData detail = list[i];
                final bool isRedeem = detail.call == 'redeem';
                return Container(
                  decoration: BoxDecoration(
                    border: Border(
                        bottom: BorderSide(width: 0.5, color: Colors.black12)),
                  ),
                  child: ListTile(
                    title: Text(
                        '${detail.call} ${isRedeem ? acala_stable_coin_view : detail.tokenId}'),
                    subtitle: Text(list[i].time.toString()),
                    trailing: Container(
                      width: 140,
                      child: Row(
                        children: <Widget>[
                          Expanded(
                            child: Padding(
                              padding: EdgeInsets.only(right: 12),
                              child: Text(
                                '${detail.amountPay} ${isRedeem ? detail.tokenId : acala_stable_coin_view}',
                                style: Theme.of(context).textTheme.headline4,
                                textAlign: TextAlign.end,
                              ),
                            ),
                          ),
                          Image.asset('assets/images/assets/assets_up.png')
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
            );
          },
        ),
      ),
    );
  }
}
