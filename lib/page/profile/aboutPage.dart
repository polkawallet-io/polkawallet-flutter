import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:package_info/package_info.dart';
import 'package:polka_wallet/common/components/JumpToBrowserLink.dart';
import 'package:polka_wallet/utils/i18n/index.dart';

class AboutPage extends StatelessWidget {
  static final String route = '/profile/about';

  @override
  Widget build(BuildContext context) {
    var dic = I18n.of(context).profile;
    return Scaffold(
      appBar: AppBar(
        title: Text(dic['about']),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(top: 100,left: 48,right: 48, bottom: 48),
              child: Column(
                children: <Widget>[
                  Image.asset(
                    'assets/images/assets/logo.png',
                    width: 100,
                  ),
                  Text(
                    'DATA HIGHWAY',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20
                    ),
                  ),
                ]
              )
            ),
            Expanded(
              flex: 3,
              child: Container()
            ),
            Text(
              dic['about.power'],
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Container(
                  alignment: Alignment.center,
                  padding: EdgeInsets.all(20),
                  child: Image.asset(
                    'assets/images/public/About_logo.png',
                  ),
                )
              ]
            ),
            // Row(
            //   mainAxisAlignment: MainAxisAlignment.center,
            //   children: <Widget>[
            //     Text(
            //       dic['about.brif'],
            //       style: Theme.of(context).textTheme.display1,
            //     ),
            //   ],
            // ),
            Expanded(
              child: Text(
                'https://polkawallet.io',
                // style: Theme.of(context).textTheme.display4,
              ),
            ),
            FutureBuilder<PackageInfo>(
              future: PackageInfo.fromPlatform(),
              builder:
                  (BuildContext context, AsyncSnapshot<PackageInfo> snapshot) {
                return snapshot.hasData
                    ? Padding(
                        padding: EdgeInsets.all(24),
                        child: Text(
                            '${dic['about.version']}: v${snapshot.data.version}'),
                      )
                    : Container();
              },
            ),
          ],
        ),
      ),
    );
  }
}
