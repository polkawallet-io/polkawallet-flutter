import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:polka_wallet/page/assets/secondary/createAccount/createAccountForm.dart';
import 'package:polka_wallet/page/assets/secondary/importAccount/importAccountForm.dart';
import 'package:polka_wallet/store/app.dart';
import 'package:polka_wallet/utils/i18n/index.dart';

class ImportAccount extends StatefulWidget {
  const ImportAccount(this.store);

  final AppStore store;

  @override
  _ImportAccountState createState() => _ImportAccountState(store);
}

class _ImportAccountState extends State<ImportAccount> {
  _ImportAccountState(this.store);

  final AppStore store;

  int _step = 0;

  Future<void> _importAccount(Map<String, dynamic> data) async {
    var acc = await store.api.importAccount(
      keyType: data['keyType'],
      cryptoType: data['cryptoType'],
    );
    if (acc != null) {
      Navigator.popUntil(context, ModalRoute.withName('/'));
      return;
    }

    showCupertinoDialog(
      context: context,
      builder: (BuildContext context) {
        final Map<String, String> accDic = I18n.of(context).account;
        return CupertinoAlertDialog(
          title: Container(),
          content:
              Text('${accDic['import.invalid']} ${accDic['create.password']}'),
          actions: <Widget>[
            CupertinoButton(
              child: Text(I18n.of(context).home['cancel']),
              onPressed: () => Navigator.of(context).pop(),
            ),
            CupertinoButton(
              child: Text(I18n.of(context).home['ok']),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_step == 1) {
      return Scaffold(
        appBar: AppBar(title: Text(I18n.of(context).home['import'])),
        body: ImportAccountForm(store.account.setNewAccountKey, _importAccount),
      );
    }
    return Scaffold(
      appBar: AppBar(title: Text(I18n.of(context).home['import'])),
      body: CreateAccountForm(store.account.setNewAccount, () {
        setState(() {
          _step = 1;
        });
      }),
    );
  }
}
