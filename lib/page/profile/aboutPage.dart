import 'package:encointer_wallet/common/components/JumpToBrowserLink.dart';
import 'package:encointer_wallet/utils/translations/index.dart';
import 'package:encointer_wallet/utils/translations/translations.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:package_info/package_info.dart';

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
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.all(48),
              child: Image.asset('assets/images/public/logo_about.png'),
            ),
            Text(
              dic.profile.aboutBrief,
              style: Theme.of(context).textTheme.headline4,
            ),
            SizedBox(height: 8),
            FutureBuilder<PackageInfo>(
              future: PackageInfo.fromPlatform(),
              builder: (_, AsyncSnapshot<PackageInfo> snapshot) {
                print(snapshot);
                if (snapshot.hasData) {
                  return Text('${dic.profile.aboutVersion}: v${snapshot.data.version}+${snapshot.data.buildNumber}');
                } else {
                  return CupertinoActivityIndicator();
                }
              },
            ),
            SizedBox(height: 16),
            JumpToBrowserLink('https://encointer.org'),
          ],
        ),
      ),
    );
  }
}
