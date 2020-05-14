import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:polka_wallet/utils/i18n/index.dart';

class WillPopScopWrapper extends StatelessWidget {
  WillPopScopWrapper({this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return new WillPopScope(
      child: child,
      onWillPop: () {
        return Platform.isAndroid
            ? showCupertinoDialog(
                context: context,
                builder: (context) => CupertinoAlertDialog(
                  title: Text(I18n.of(context).home['exit.confirm']),
                  actions: <Widget>[
                    CupertinoButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: Text(I18n.of(context).home['cancel']),
                    ),
                    CupertinoButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      /*Navigator.of(context).pop(true)*/
                      child: Text(I18n.of(context).home['ok']),
                    ),
                  ],
                ),
              )
            : Future.value(true);
      },
    );
  }
}
