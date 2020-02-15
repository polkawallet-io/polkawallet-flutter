import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:polka_wallet/store/assets.dart';
import 'package:polka_wallet/utils/format.dart';
import 'package:polka_wallet/utils/i18n/index.dart';

class TxDetail extends StatelessWidget {
  TxDetail({
    this.success,
    this.action,
    this.eventId,
    this.block,
    this.info,
  });

  final bool success;
  final String action;
  final String eventId;
  final BlockData block;
  final List<DetailInfoItem> info;

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

  List<Widget> _buildListView(BuildContext context) {
    final Map<String, String> dic = I18n.of(context).assets;
    Widget buildLabel(String name) {
      return Container(
          padding: EdgeInsets.only(left: 8),
          width: 88,
          child: Text(name, style: Theme.of(context).textTheme.display4));
    }

    var list = <Widget>[
      Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Padding(
            padding: EdgeInsets.all(32),
            child: success
                ? Image.asset('assets/images/assets/success.png')
                : Image.asset('assets/images/staking/error.png'),
          ),
          Text(
            '$action ${success ? dic['success'] : dic['fail']}',
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
    ];
    info.forEach((i) {
      list.add(ListTile(
        leading: buildLabel(i.label),
        title: Text(i.title),
        subtitle: i.subtitle != null ? Text(i.subtitle) : null,
        trailing: i.address != null
            ? IconButton(
                icon: Image.asset('assets/images/public/copy.png'),
                onPressed: () => _onCopy(context, i.address),
              )
            : null,
      ));
    });
    list.addAll(<Widget>[
      ListTile(
        leading: buildLabel(dic['event']),
        title: Text(eventId),
      ),
      ListTile(
        leading: buildLabel(dic['block']),
        title: Text('#${block.id}'),
      ),
      ListTile(
        leading: buildLabel(dic['hash']),
        title: Text(Fmt.address(block.hash)),
      ),
      Container(
        height: 16,
      )
    ]);
    return list;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${I18n.of(context).assets['detail']}'),
        centerTitle: true,
      ),
      body: ListView(children: _buildListView(context)),
    );
  }
}

class DetailInfoItem {
  DetailInfoItem({this.label, this.title, this.subtitle, this.address});
  final String label;
  final String title;
  final String subtitle;
  final String address;
}
