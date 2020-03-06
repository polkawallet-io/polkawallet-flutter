import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:package_info/package_info.dart';
import 'package:polka_wallet/utils/i18n/index.dart';

class About extends StatelessWidget {
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
              padding: EdgeInsets.all(48),
              child: Image.asset('assets/images/public/About_logo.png'),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  dic['about.brif'],
                  style: Theme.of(context).textTheme.display1,
                ),
              ],
            ),
            Expanded(
              child: Text(
                'https://polkawallet.io',
                style: Theme.of(context).textTheme.display4,
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
