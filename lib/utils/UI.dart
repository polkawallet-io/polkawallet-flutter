import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:polka_wallet/utils/i18n/index.dart';

class UI {
  static void copyAndNotify(BuildContext context, String text) {
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
}

// access the refreshIndicator globally
// assets index page:
final GlobalKey<RefreshIndicatorState> globalBalanceRefreshKey =
    new GlobalKey<RefreshIndicatorState>();
// asset page:
final GlobalKey<RefreshIndicatorState> globalAssetRefreshKey =
    new GlobalKey<RefreshIndicatorState>();
// staking bond page:
final GlobalKey<RefreshIndicatorState> globalBondingRefreshKey =
    new GlobalKey<RefreshIndicatorState>();
// staking nominate page:
final GlobalKey<RefreshIndicatorState> globalNominatingRefreshKey =
    new GlobalKey<RefreshIndicatorState>();
// council page:
final GlobalKey<RefreshIndicatorState> globalCouncilRefreshKey =
    new GlobalKey<RefreshIndicatorState>();
// democracy page:
final GlobalKey<RefreshIndicatorState> globalDemocracyRefreshKey =
    new GlobalKey<RefreshIndicatorState>();
