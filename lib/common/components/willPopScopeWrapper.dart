import 'dart:io';

import 'package:encointer_wallet/utils/translations/index.dart';
import 'package:flutter/cupertino.dart';

class WillPopScopeWrapper extends StatelessWidget {
  WillPopScopeWrapper({this.child});

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
                  title: Text(I18n.of(context).translationsForLocale().home.exitConfirm),
                  actions: <Widget>[
                    CupertinoButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: Text(I18n.of(context).translationsForLocale().home.cancel),
                    ),
                    CupertinoButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      /*Navigator.of(context).pop(true)*/
                      child: Text(I18n.of(context).translationsForLocale().home.ok),
                    ),
                  ],
                ),
              )
            : Future.value(true);
      },
    );
  }
}
