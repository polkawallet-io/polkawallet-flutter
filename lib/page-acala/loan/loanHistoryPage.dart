import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:polka_wallet/common/consts/settings.dart';
import 'package:polka_wallet/page/assets/transfer/detailPage.dart';
import 'package:polka_wallet/store/app.dart';
import 'package:polka_wallet/store/assets.dart';
import 'package:polka_wallet/utils/format.dart';
import 'package:polka_wallet/utils/i18n/index.dart';

class LoanHistoryPage extends StatelessWidget {
  LoanHistoryPage(this.store);

  static const String route = '/acala/loan/txs';

  final AppStore store;

  final GlobalKey<RefreshIndicatorState> _refreshKey =
      new GlobalKey<RefreshIndicatorState>();

  Future<void> _fetchData() async {}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(I18n.of(context).account['txs']),
      ),
      body: SafeArea(
        child: Observer(
          builder: (_) {
            List list = [];
            Map<int, BlockData> blockMap = store.assets.blockMap;
            return RefreshIndicator(
                key: _refreshKey,
                onRefresh: _fetchData,
                child: ListView.builder(
                  itemCount: list.length,
                  itemBuilder: (BuildContext context, int i) {
                    BlockData block = blockMap[list[i].block];
                    String time = 'time';
                    if (block != null) {
                      time = block.time.toString().split('.')[0];
                    }
                    return Container(
                      decoration: BoxDecoration(
                        border: Border(
                            bottom:
                                BorderSide(width: 0.5, color: Colors.black12)),
                      ),
                      child: ListTile(
                        title: Text(list[i].id),
                        subtitle: Text(time),
                        trailing: Container(
                          width: 110,
                          child: Row(
                            children: <Widget>[
                              Expanded(
                                child: Text(
                                  '${Fmt.token(list[i].value, decimals: acala_token_decimals)}',
                                  style: Theme.of(context).textTheme.display4,
                                ),
                              ),
                              Text('symbol')
                            ],
                          ),
                        ),
                        onTap: block != null
                            ? () {
                                Navigator.pushNamed(
                                    context, TransferDetailPage.route,
                                    arguments: i);
                              }
                            : null,
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
