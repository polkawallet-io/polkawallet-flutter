import 'package:encointer_wallet/common/components/addressIcon.dart';
import 'package:encointer_wallet/page/profile/aboutPage.dart';
import 'package:encointer_wallet/page/profile/account/accountManagePage.dart';
import 'package:encointer_wallet/page/profile/contacts/contactsPage.dart';
import 'package:encointer_wallet/page/profile/settings/settingsPage.dart';
import 'package:encointer_wallet/store/account/types/accountData.dart';
import 'package:encointer_wallet/store/app.dart';
import 'package:encointer_wallet/utils/format.dart';
import 'package:encointer_wallet/utils/i18n/index.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';

class Profile extends StatelessWidget {
  Profile(this.store);

  final AppStore store;

  @override
  Widget build(BuildContext context) {
    final Map<String, String> dic = I18n.of(context).profile;
    final Color grey = Theme.of(context).unselectedWidgetColor;

    return Observer(builder: (_) {
      AccountData acc = store.account.currentAccount;
      Color primaryColor = Theme.of(context).primaryColor;
      return Scaffold(
        appBar: AppBar(
          title: Text(dic['title']),
          centerTitle: true,
          elevation: 0.0,
        ),
        body: ListView(
          children: <Widget>[
            Container(
              color: primaryColor,
              padding: EdgeInsets.only(bottom: 16),
              child: ListTile(
                leading: AddressIcon('', pubKey: store.account.currentAccount.pubKey),
                title: Text(Fmt.accountName(context, acc), style: TextStyle(fontSize: 16, color: Colors.white)),
                subtitle: Text(
                  Fmt.address(store.account.currentAddress) ?? '',
                  style: TextStyle(fontSize: 16, color: Colors.white70),
                ),
              ),
            ),
            !(acc.observation ?? false)
                ? Container(
                    padding: EdgeInsets.all(24),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        ElevatedButton(
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.fromLTRB(24, 8, 24, 8),
                            backgroundColor: primaryColor,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                          ),
                          child: Text(
                            dic['account'],
                            style: Theme.of(context).textTheme.button,
                          ),
                          onPressed: () => Navigator.pushNamed(context, AccountManagePage.route),
                        )
                      ],
                    ),
                  )
                : Container(height: 24),
            ListTile(
              leading: Container(
                width: 32,
                child: Icon(Icons.people_outline, color: grey, size: 22),
              ),
              title: Text(dic['contact']),
              trailing: Icon(Icons.arrow_forward_ios, size: 18),
              onTap: () => Navigator.of(context).pushNamed(ContactsPage.route),
            ),
            ListTile(
              leading: Container(
                width: 32,
                child: Icon(Icons.settings, color: grey, size: 22),
              ),
              title: Text(dic['setting']),
              trailing: Icon(Icons.arrow_forward_ios, size: 18),
              onTap: () => Navigator.of(context).pushNamed(SettingsPage.route),
            ),
            ListTile(
              leading: Container(
                width: 32,
                child: Icon(Icons.info_outline, color: grey, size: 22),
              ),
              title: Text(dic['about']),
              trailing: Icon(Icons.arrow_forward_ios, size: 18),
              onTap: () => Navigator.of(context).pushNamed(AboutPage.route),
            ),
          ],
        ),
      );
    });
  }
}
