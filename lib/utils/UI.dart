import 'dart:async';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:package_info/package_info.dart';
import 'package:polka_wallet/common/components/currencyWithIcon.dart';
import 'package:polka_wallet/common/components/downloadDialog.dart';
import 'package:polka_wallet/common/consts/settings.dart';
import 'package:polka_wallet/utils/i18n/index.dart';
import 'package:url_launcher/url_launcher.dart';

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

  static Future<void> launchURL(String url) async {
    if (await canLaunch(url)) {
      try {
        await launch(url);
      } catch (err) {
        print(err);
      }
    } else {
      print('Could not launch $url');
    }
  }

  static void showCurrencyPicker(BuildContext context, List<String> currencyIds,
      String selected, Function(String) onChange) {
    showCupertinoModalPopup(
      context: context,
      builder: (_) => Container(
        height: MediaQuery.of(context).copyWith().size.height / 3,
        child: CupertinoPicker(
          backgroundColor: Colors.white,
          itemExtent: 56,
          scrollController: FixedExtentScrollController(
              initialItem: currencyIds.indexOf(selected)),
          children: currencyIds
              .map(
                (i) => Padding(
                  padding: EdgeInsets.all(16),
                  child: CurrencyWithIcon(
                    i,
                    mainAxisAlignment: MainAxisAlignment.center,
                  ),
                ),
              )
              .toList(),
          onSelectedItemChanged: (v) {
            onChange(currencyIds[v]);
          },
        ),
      ),
    );
  }

  static Future<void> checkUpdate(BuildContext context, Map versions,
      {bool autoCheck = false}) async {
    if (!Platform.isAndroid && !Platform.isIOS) return;
    String platform = Platform.isAndroid ? 'android' : 'ios';
    final Map dic = I18n.of(context).home;
    String latest = versions[platform]['version'];
    String latestBeta = versions[platform]['version-beta'];

    PackageInfo info = await PackageInfo.fromPlatform();

    bool needUpdate = false;
    if (autoCheck) {
      if (latest.compareTo(info.version) > 0) {
        // new version found
        needUpdate = true;
      } else {
        return;
      }
    } else {
      if (latestBeta.compareTo(app_beta_version) > 0) {
        // new version found
        needUpdate = true;
      }
    }

    showCupertinoDialog(
      context: context,
      builder: (BuildContext context) {
        List versionInfo = versions[platform]['info']
            [I18n.of(context).locale.toString().contains('zh') ? 'zh' : 'en'];
        return CupertinoAlertDialog(
          title: Text('v$latestBeta'),
          content: Column(
            children: [
              Padding(
                padding: EdgeInsets.only(top: 12, bottom: 8),
                child:
                    Text(needUpdate ? dic['update.up'] : dic['update.latest']),
              ),
              needUpdate
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: versionInfo
                          .map((e) => Text(
                                '- $e',
                                textAlign: TextAlign.left,
                              ))
                          .toList(),
                    )
                  : Container()
            ],
          ),
          actions: <Widget>[
            CupertinoButton(
              child: Text(dic['cancel']),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            CupertinoButton(
              child: Text(dic['ok']),
              onPressed: () {
                Navigator.of(context).pop();
                if (!needUpdate) {
                  return;
                }
                if (Platform.isIOS) {
                  // go to ios download page
                  launchURL('https://polkawallet.io/#download');
                } else if (Platform.isAndroid) {
                  // download apk
                  // START LISTENING FOR DOWNLOAD PROGRESS REPORTING EVENTS
                  try {
                    String url = versions['android']['url'];
                    print(url);
                    showCupertinoDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return DownloadDialog(url);
                      },
                    );
                  } catch (e) {
                    print('Failed to make OTA update. Details: $e');
                  }
                }
              },
            ),
          ],
        );
      },
    );
  }

  static Future<void> alertWASM(BuildContext context, Function onCancel) async {
    showCupertinoDialog(
      context: context,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: Container(),
          content: Text(I18n.of(context).account['backup.error']),
          actions: <Widget>[
            CupertinoButton(
              child: Text(I18n.of(context).home['ok']),
              onPressed: () {
                Navigator.of(context).pop();
                onCancel();
              },
            ),
          ],
        );
      },
    );
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
// recovery settings page:
final GlobalKey<RefreshIndicatorState> globalRecoverySettingsRefreshKey =
    new GlobalKey<RefreshIndicatorState>();
// recovery state page:
final GlobalKey<RefreshIndicatorState> globalRecoveryStateRefreshKey =
    new GlobalKey<RefreshIndicatorState>();
// recovery vouch page:
final GlobalKey<RefreshIndicatorState> globalRecoveryProofRefreshKey =
    new GlobalKey<RefreshIndicatorState>();

// acala loan page:
final GlobalKey<RefreshIndicatorState> globalLoanRefreshKey =
    new GlobalKey<RefreshIndicatorState>();
// acala dexLiquidity page:
final GlobalKey<RefreshIndicatorState> globalDexLiquidityRefreshKey =
    new GlobalKey<RefreshIndicatorState>();
// acala homa page:
final GlobalKey<RefreshIndicatorState> globalHomaRefreshKey =
    new GlobalKey<RefreshIndicatorState>();

// encointerCeremoniesPage
final GlobalKey<RefreshIndicatorState> globalCeremonyPhaseChangeKey =
new GlobalKey<RefreshIndicatorState>();
final GlobalKey<RefreshIndicatorState> globalCeremonyRegistrationRefreshKey =
new GlobalKey<RefreshIndicatorState>();