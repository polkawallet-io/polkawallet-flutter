import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:polka_wallet/store/app.dart';
import 'package:polka_wallet/store/assets.dart';
import 'package:polka_wallet/utils/format.dart';
import 'package:polka_wallet/utils/i18n/index.dart';

class TransferDetail extends StatelessWidget {
  TransferDetail(this.store);

  final AppStore store;

  void _onCopy(BuildContext context, String text) {
    Clipboard.setData(ClipboardData(text: text));

    showCupertinoDialog(
      context: context,
      builder: (BuildContext context) {
        final Map<String, String> dic = I18n.of(context).assets;
        return CupertinoAlertDialog(
          title: Container(),
          content: Text('${dic['copy']} ${dic['success']}'),
        );
      },
    );

    Timer(Duration(seconds: 2), () {
      Navigator.of(context).pop();
    });
  }

  @override
  Widget build(BuildContext context) {
    final Map<String, String> dic = I18n.of(context).assets;
    final String symbol = store.settings.networkState.tokenSymbol;
    final int decimals = store.settings.networkState.tokenDecimals;
    final TransferData tx = store.assets.txDetail;
    final BlockData block = store.assets.blockMap[tx.block];

    final TextStyle labelStyle = Theme.of(context).textTheme.display4;
    final String txType = tx.sender == store.account.currentAccount.address
        ? dic['transfer']
        : dic['receive'];
    Widget buildLabel(String name) {
      return Container(
          padding: EdgeInsets.only(left: 8),
          width: 80,
          child: Text(name, style: labelStyle));
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('${dic['detail']}'),
        centerTitle: true,
      ),
      body: ListView(
        children: <Widget>[
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Padding(
                padding: EdgeInsets.all(32),
                child: Image.asset('assets/images/assets/success.png'),
              ),
              Text(
                '$txType ${dic['success']}',
                style: Theme.of(context).textTheme.display3,
              ),
              Padding(
                padding: EdgeInsets.only(top: 8, bottom: 32),
                child: Text(block != null
                    ? block.time.toString().split('.')[0]
                    : 'datetime'),
              ),
            ],
          ),
          Divider(),
          ListTile(
            leading: buildLabel(dic['value']),
            title: Text(
                '${Fmt.token(tx.value, decimals, fullLength: true)} $symbol'),
          ),
          ListTile(
            leading: buildLabel(dic['fee']),
            title: Text(
                '${Fmt.token(tx.fee, decimals, fullLength: true)} $symbol'),
          ),
          ListTile(
            leading: buildLabel(dic['from']),
            title: Text(tx.senderId),
            subtitle: Text(Fmt.address(tx.sender)),
            trailing: IconButton(
              icon: Image.asset('assets/images/public/copy.png'),
              onPressed: () => _onCopy(context, tx.sender),
            ),
          ),
          ListTile(
            leading: buildLabel(dic['to']),
            title: Text(tx.destinationId),
            subtitle: Text(Fmt.address(tx.destination)),
            trailing: IconButton(
              icon: Image.asset('assets/images/public/copy.png'),
              onPressed: () => _onCopy(context, tx.destination),
            ),
          ),
          ListTile(
            leading: buildLabel(dic['block']),
            title: Text('#${tx.block}'),
          ),
          ListTile(
            leading: buildLabel(dic['event']),
            title: Text(tx.id),
          ),
        ],
      ),
    );
  }
}
