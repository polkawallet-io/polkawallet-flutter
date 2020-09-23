import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:polka_wallet/page/staking/actions/stakingDetailPage.dart';
import 'package:polka_wallet/store/staking/types/txData.dart';
import 'package:polka_wallet/utils/format.dart';

class TxList extends StatelessWidget {
  TxList(this.txs);

  final List<TxData> txs;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        itemCount: txs.length,
        itemBuilder: (_, i) {
          return ListTile(
            leading: Container(
              padding: EdgeInsets.only(top: 8),
              child: txs[i].success
                  ? Icon(Icons.check_circle, color: Colors.green)
                  : Icon(Icons.error, color: Colors.red),
            ),
            title: Text(txs[i].call),
            subtitle: Text(Fmt.dateTime(DateTime.fromMillisecondsSinceEpoch(
                txs[i].blockTimestamp * 1000))),
            trailing: Container(
              width: 80,
              child: Text(txs[i].txNumber),
            ),
            onTap: () {
              Navigator.of(context)
                  .pushNamed(StakingDetailPage.route, arguments: txs[i]);
            },
          );
        });
  }
}
