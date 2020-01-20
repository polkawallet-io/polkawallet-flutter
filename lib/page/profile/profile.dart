import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:polka_wallet/store/account.dart';
import 'package:polka_wallet/utils/format.dart';
import 'package:polka_wallet/utils/i18n/index.dart';

class Profile extends StatelessWidget {
  Profile(this.store);

  final AccountStore store;

  @override
  Widget build(BuildContext context) {
    Map<String, String> dic = I18n.of(context).profile;

    return Observer(
      builder: (_) => Scaffold(
        appBar: AppBar(
          title: Text(dic['title']),
          centerTitle: true,
          elevation: 0.0,
        ),
        body: Column(
          children: <Widget>[
            Container(
              color: Colors.pink,
              padding: EdgeInsets.only(bottom: 16),
              child: ListTile(
                leading: Container(
                  width: 72,
                  height: 72,
                  child: Image.asset('assets/images/assets/KSC.png'),
                ),
                title: Text(store.currentAccount.name ?? 'name',
                    style: TextStyle(fontSize: 16, color: Colors.white)),
                subtitle: Text(
                  Fmt.address(store.currentAccount.address) ?? '',
                  style: TextStyle(fontSize: 16, color: Colors.white70),
                ),
              ),
            ),
            Container(padding: EdgeInsets.only(top: 16)),
            ListTile(
              leading: Image.asset('assets/images/profile/address.png'),
              title: Text(dic['account']),
              trailing: Icon(Icons.arrow_forward_ios, size: 18),
              onTap: () => Navigator.pushNamed(context, '/profile/account'),
            ),
            ListTile(
              leading: Image.asset('assets/images/profile/address.png'),
              title: Text(dic['address']),
              trailing: Icon(Icons.arrow_forward_ios, size: 18),
            ),
            ListTile(
              leading: Image.asset('assets/images/profile/setting.png'),
              title: Text(dic['setting']),
              trailing: Icon(Icons.arrow_forward_ios, size: 18),
            ),
            ListTile(
              leading: Image.asset('assets/images/profile/about.png'),
              title: Text(dic['about']),
              trailing: Icon(Icons.arrow_forward_ios, size: 18),
            ),
          ],
        ),
      ),
    );
  }
}
