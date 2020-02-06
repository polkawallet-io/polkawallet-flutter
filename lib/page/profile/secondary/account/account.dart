import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:polka_wallet/store/account.dart';
import 'package:polka_wallet/utils/format.dart';
import 'package:polka_wallet/utils/i18n/index.dart';

class AccountManage extends StatelessWidget {
  AccountManage(this.store);

  final AccountStore store;

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
        body: Column(
          children: <Widget>[
            Expanded(
              child: ListView(
                children: <Widget>[
                  Container(
                    color: Colors.pink,
                    padding: EdgeInsets.only(bottom: 16),
                    child: ListTile(
                      leading: Container(
                        width: 72,
                        height: 72,
                        child: Image.asset(
                            'assets/images/assets/Assets_nav_0.png'),
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
                    title: Text(dic['name.change']),
                    trailing: Icon(Icons.arrow_forward_ios, size: 18),
                    onTap: () => Navigator.pushNamed(context, '/profile/name'),
                  ),
                  ListTile(
                    title: Text(dic['pass.change']),
                    trailing: Icon(Icons.arrow_forward_ios, size: 18),
                    onTap: () =>
                        Navigator.pushNamed(context, '/profile/password'),
                  ),
                  ListTile(
                    title: Text(dic['export']),
                    trailing: Icon(Icons.arrow_forward_ios, size: 18),
                  ),
                ],
              ),
            ),
            Row(
              children: <Widget>[
                Expanded(
                  child: RaisedButton(
                    padding: EdgeInsets.all(16),
                    color: Colors.white,
                    textColor: Colors.pink,
                    child: Text(dic['delete']),
                    onPressed: () {
                      showCupertinoDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return CupertinoAlertDialog(
                            title: Text(dic['delete.confirm']),
                            content: Text(dic['delete.warn']),
                            actions: <Widget>[
                              CupertinoButton(
                                child: Text(I18n.of(context).home['cancel']),
                                onPressed: () => Navigator.of(context).pop(),
                              ),
                              CupertinoButton(
                                child: Text(I18n.of(context).home['ok']),
                                onPressed: () {
                                  Navigator.popUntil(
                                      context, ModalRoute.withName('/'));
                                  store.removeAccount(store.currentAccount);
                                },
                              ),
                            ],
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
