import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:encointer_wallet/common/components/addressIcon.dart';
import 'package:encointer_wallet/common/components/passwordInputDialog.dart';
import 'package:encointer_wallet/page/profile/account/changeNamePage.dart';
import 'package:encointer_wallet/page/profile/account/changePasswordPage.dart';
import 'package:encointer_wallet/page/profile/account/exportAccountPage.dart';
import 'package:encointer_wallet/service/substrateApi/api.dart';
import 'package:encointer_wallet/store/app.dart';
import 'package:encointer_wallet/utils/format.dart';
import 'package:encointer_wallet/utils/i18n/index.dart';

class AccountManagePage extends StatelessWidget {
  AccountManagePage(this.store);

  static final String route = '/profile/account';
  final Api api = webApi;
  final AppStore store;

  void _onDeleteAccount(BuildContext context) {
    showCupertinoDialog(
      context: context,
      builder: (BuildContext context) {
        return PasswordInputDialog(
          title: Text(I18n.of(context).profile['delete.confirm']),
          account: store.account.currentAccount,
          onOk: (_) {
            print("the context before account deletion: ${context}");
            store.account.removeAccount(store.account.currentAccount).then( (_) {
              // refresh balance
              store.assets.loadAccountCache();
              webApi.assets.fetchBalance();
            });
            Navigator.of(context).pop();
          },
          onReset: () async {
            await _purgeAccountsDialog(context);
            Navigator.of(context).pop();
            Navigator.of(context).pop();
          }
        );
      },
    );
  }

  Future<void> _purgeAccountsDialog(BuildContext context) async {
    print("current context: $context");
    var res = store.account.accountListAll;
    await showCupertinoDialog(
      context: context,
      builder: (_) {
        return CupertinoAlertDialog(
          title: Text(I18n.of(context).home['purge.accounts']),
          actions: <Widget>[
            CupertinoButton(
              child: Text(I18n.of(context).home['cancel']),
              onPressed: () {
                Navigator.of(context).pop();
              } ,
            ),
            CupertinoButton(
                child: Text(I18n.of(context).home['yes']),
                onPressed: () {
                  removeAccounts(res, context);
                  Navigator.of(context).pop();
                }
            ),
          ],
        );
      },
    );
  }

  void removeAccounts(accounts, context) {
    for (var account in accounts)
    {
      // print(account.name);
      store.account.removeAccount(account).then((_) {
        store.assets.loadAccountCache();
        webApi.assets.fetchBalance();
        // var res = store.account.accountListAll;
        // print("ammount of accounts is " + res.length.toString());
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final Map<String, String> dic = I18n.of(context).profile;

    Color primaryColor = Theme.of(context).primaryColor;
    return Observer(
      builder: (_) => Scaffold(
        appBar: AppBar(
          title: Text(dic['account']),
          centerTitle: true,
          elevation: 0.0,
        ),
        body: SafeArea(
          child: Column(
            children: <Widget>[
              Expanded(
                child: ListView(
                  children: <Widget>[
                    Container(
                      color: primaryColor,
                      padding: EdgeInsets.only(bottom: 16),
                      child: ListTile(
                        leading: AddressIcon(
                          '',
                          pubKey: store.account.currentAccount.pubKey,
                        ),
                        title: Text(store.account.currentAccount.name ?? 'name',
                            style: TextStyle(fontSize: 16, color: Colors.white)),
                        subtitle: Text(
                          Fmt.address(store.account.currentAddress) ?? '',
                          style: TextStyle(fontSize: 16, color: Colors.white70),
                        ),
                      ),
                    ),
                    Container(padding: EdgeInsets.only(top: 16)),
                    ListTile(
                      title: Text(dic['name.change']),
                      trailing: Icon(Icons.arrow_forward_ios, size: 18),
                      onTap: () => Navigator.pushNamed(context, ChangeNamePage.route),
                    ),
                    ListTile(
                      title: Text(dic['pass.change']),
                      trailing: Icon(Icons.arrow_forward_ios, size: 18),
                      onTap: () => Navigator.pushNamed(context, ChangePasswordPage.route),
                    ),
                    ListTile(
                      title: Text(dic['export']),
                      trailing: Icon(Icons.arrow_forward_ios, size: 18),
                      onTap: () => Navigator.of(context).pushNamed(ExportAccountPage.route),
                    ),
                  ],
                ),
              ),
              Row(
                children: <Widget>[
                  Expanded(
                    child: TextButton(
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.all(16),
                        backgroundColor: Colors.white,
                        textStyle: TextStyle(color: Colors.red),
                      ),
                      child: Text(dic['delete']),
                      onPressed: () => _onDeleteAccount(context),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
