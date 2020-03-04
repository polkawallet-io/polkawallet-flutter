import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:polka_wallet/common/components/addressIcon.dart';
import 'package:polka_wallet/store/account.dart';
import 'package:polka_wallet/utils/format.dart';
import 'package:polka_wallet/utils/i18n/index.dart';

class Profile extends StatelessWidget {
  Profile(this.store);

  final AccountStore store;

  @override
  Widget build(BuildContext context) {
    final Map<String, String> dic = I18n.of(context).profile;
    return Observer(builder: (_) {
      AccountData acc = store.currentAccount;
      return Scaffold(
        appBar: AppBar(
          title: Text(dic['title']),
          centerTitle: true,
          elevation: 0.0,
        ),
        body: ListView(
          children: <Widget>[
            Container(
              color: Colors.pink,
              padding: EdgeInsets.only(bottom: 16),
              child: ListTile(
                leading: AddressIcon(address: store.currentAddress),
                title: Text(acc.name ?? 'name',
                    style: TextStyle(fontSize: 16, color: Colors.white)),
                subtitle: Text(
                  Fmt.address(store.currentAddress) ?? '',
                  style: TextStyle(fontSize: 16, color: Colors.white70),
                ),
              ),
            ),
            Container(
              padding: EdgeInsets.all(24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  RaisedButton(
                    padding: EdgeInsets.fromLTRB(24, 8, 24, 8),
                    color: Colors.pinkAccent,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24)),
                    child: Text(
                      dic['account'],
                      style: Theme.of(context).textTheme.button,
                    ),
                    onPressed: () =>
                        Navigator.pushNamed(context, '/profile/account'),
                  )
                ],
              ),
            ),
            ListTile(
              leading: Image.asset('assets/images/profile/address.png'),
              title: Text(dic['contact']),
              trailing: Icon(Icons.arrow_forward_ios, size: 18),
              onTap: () => Navigator.of(context).pushNamed('/profile/contacts'),
            ),
            ListTile(
              leading: Image.asset('assets/images/profile/setting.png'),
              title: Text(dic['setting']),
              trailing: Icon(Icons.arrow_forward_ios, size: 18),
              onTap: () => Navigator.of(context).pushNamed('/profile/settings'),
            ),
            ListTile(
              leading: Image.asset('assets/images/profile/about.png'),
              title: Text(dic['about']),
              trailing: Icon(Icons.arrow_forward_ios, size: 18),
              onTap: () => Navigator.of(context).pushNamed('/profile/about'),
            ),
          ],
        ),
      );
    });
  }
}
