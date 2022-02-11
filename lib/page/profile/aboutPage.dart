import 'package:encointer_wallet/common/components/JumpToBrowserLink.dart';
import 'package:encointer_wallet/utils/translations/index.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:package_info/package_info.dart';
import 'package:encointer_wallet/utils/translations/translations.dart';

class AboutPage extends StatelessWidget {
  static final String route = '/profile/about';

  @override
  Widget build(BuildContext context) {
    final Translations dic = I18n.of(context).translationsForLocale();
    return Scaffold(
      backgroundColor: Theme.of(context).cardColor,
      appBar: AppBar(
        title: Text(dic.profile.about),
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
                  dic.profile.aboutBrif,
                  style: Theme.of(context).textTheme.headline4,
                ),
              ],
            ),
            Padding(
              padding: EdgeInsets.all(8),
              child: FutureBuilder<PackageInfo>(
                future: PackageInfo.fromPlatform(),
                builder: (_, AsyncSnapshot<PackageInfo> snapshot) {
                  print(snapshot);
                  if (snapshot.hasData) {
                    return Text('${dic.profile.aboutVersion}: v${snapshot.data.version}');
                  } else {
                    return CupertinoActivityIndicator();
                  }
                },
              ),
            ),
            Padding(
              padding: EdgeInsets.only(top: 16),
              child: JumpToBrowserLink('https://encointer.org'),
            ),
            Expanded(child: Container()),
          ],
        ),
      ),
    );
  }
}
