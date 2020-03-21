import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:polka_wallet/common/components/addressIcon.dart';
import 'package:polka_wallet/page/profile/account/changeNamePage.dart';
import 'package:polka_wallet/page/profile/account/changePasswordPage.dart';
import 'package:polka_wallet/page/profile/account/exportAccountPage.dart';
import 'package:polka_wallet/service/substrateApi/api.dart';
import 'package:polka_wallet/store/app.dart';
import 'package:polka_wallet/utils/format.dart';
import 'package:polka_wallet/utils/i18n/index.dart';

class AccountManagePage extends StatelessWidget {
  AccountManagePage(this.store);

  static final String route = '/profile/account';
  final Api api = webApi;
  final AppStore store;

  final TextEditingController _passCtrl = new TextEditingController();

  void _onDeleteAccount(BuildContext context) {
    final Map<String, String> dic = I18n.of(context).profile;
    final Map<String, String> accDic = I18n.of(context).account;

    Future<void> onOk() async {
      var res = await api.account.checkAccountPassword(_passCtrl.text);
      if (res == null) {
        showCupertinoDialog(
          context: context,
          builder: (BuildContext context) {
            return CupertinoAlertDialog(
              title: Text(dic['pass.error']),
              content: Text(dic['pass.error.txt']),
              actions: <Widget>[
                CupertinoButton(
                  child: Text(I18n.of(context).home['ok']),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            );
          },
        );
      } else {
        store.account.removeAccount(store.account.currentAccount).then((_) {
          String addressNew = store.account.currentAddress;
          // refresh balance
          store.assets.loadAccountCache();
          webApi.assets.fetchBalance(addressNew);
          // refresh user's staking & gov info
          store.gov.clearSate();
          store.staking.loadAccountCache();
          webApi.staking.fetchAccountStaking(addressNew);
        });
        Navigator.popUntil(context, ModalRoute.withName('/'));
      }
    }

    showCupertinoDialog(
      context: context,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: Text(dic['delete.confirm']),
          content: Padding(
            padding: EdgeInsets.only(top: 16),
            child: CupertinoTextField(
              placeholder: dic['pass.old'],
              controller: _passCtrl,
              onChanged: (v) {
                return Fmt.checkPassword(v.trim())
                    ? null
                    : accDic['create.password.error'];
              },
              obscureText: true,
              clearButtonMode: OverlayVisibilityMode.editing,
            ),
          ),
          actions: <Widget>[
            CupertinoButton(
              child: Text(I18n.of(context).home['cancel']),
              onPressed: () {
                Navigator.of(context).pop();
                _passCtrl.clear();
              },
            ),
            CupertinoButton(
              child: Text(I18n.of(context).home['ok']),
              onPressed: onOk,
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final Map<String, String> dic = I18n.of(context).profile;

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
                      color: Colors.pink,
                      padding: EdgeInsets.only(bottom: 16),
                      child: ListTile(
                        leading: AddressIcon(
                          '',
                          pubKey: store.account.currentAccount.pubKey,
                        ),
                        title: Text(store.account.currentAccount.name ?? 'name',
                            style:
                                TextStyle(fontSize: 16, color: Colors.white)),
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
                      onTap: () =>
                          Navigator.pushNamed(context, ChangeNamePage.route),
                    ),
                    ListTile(
                      title: Text(dic['pass.change']),
                      trailing: Icon(Icons.arrow_forward_ios, size: 18),
                      onTap: () => Navigator.pushNamed(
                          context, ChangePasswordPage.route),
                    ),
                    ListTile(
                      title: Text(dic['export']),
                      trailing: Icon(Icons.arrow_forward_ios, size: 18),
                      onTap: () => Navigator.of(context)
                          .pushNamed(ExportAccountPage.route),
                    ),
                  ],
                ),
              ),
              Row(
                children: <Widget>[
                  Expanded(
                    child: FlatButton(
                      padding: EdgeInsets.all(16),
                      color: Colors.white,
                      textColor: Colors.pink,
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
