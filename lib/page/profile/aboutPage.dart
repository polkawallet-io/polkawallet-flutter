import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:polka_wallet/common/components/JumpToBrowserLink.dart';
import 'package:polka_wallet/common/components/roundedButton.dart';
import 'package:polka_wallet/common/consts/settings.dart';
import 'package:polka_wallet/service/walletApi.dart';
import 'package:polka_wallet/utils/UI.dart';
import 'package:polka_wallet/utils/i18n/index.dart';

class AboutPage extends StatefulWidget {
  static final String route = '/profile/about';

  @override
  _AboutPage createState() => _AboutPage();
}

class _AboutPage extends State<AboutPage> {
  bool _loading = false;

  Future<void> _checkUpdate() async {
    setState(() {
      _loading = true;
    });
    Map versions = await WalletApi.getLatestVersion();
    setState(() {
      _loading = false;
    });
    UI.checkUpdate(context, versions);
  }

  @override
  Widget build(BuildContext context) {
    final Map dic = I18n.of(context).profile;
    return Scaffold(
      backgroundColor: Theme.of(context).cardColor,
      appBar: AppBar(
        title: Text(dic['about']),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.all(48),
              child: Image.asset('assets/images/public/logo_about.png'),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  dic['about.brif'],
                  style: Theme.of(context).textTheme.headline4,
                ),
              ],
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.only(top: 16),
                child: JumpToBrowserLink('https://polkawallet.io'),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(8),
              child: Text('${dic['about.version']}: $app_beta_version'),
            ),
            Padding(
              padding: EdgeInsets.all(16),
              child: RoundedButton(
                text: I18n.of(context).home['update'],
                onPressed: () {
                  _checkUpdate();
                },
                submitting: _loading,
              ),
            )
          ],
        ),
      ),
    );
  }
}
