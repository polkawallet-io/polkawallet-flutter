import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:polka_wallet/page/account/create/createAccountForm.dart';
import 'package:polka_wallet/page/account/import/importAccountForm.dart';
import 'package:polka_wallet/service/substrateApi/api.dart';
import 'package:polka_wallet/store/app.dart';
import 'package:polka_wallet/utils/i18n/index.dart';

class ImportAccountPage extends StatefulWidget {
  const ImportAccountPage(this.store);

  static final String route = '/account/import';
  final AppStore store;

  @override
  _ImportAccountPageState createState() => _ImportAccountPageState(store);
}

class _ImportAccountPageState extends State<ImportAccountPage> {
  _ImportAccountPageState(this.store);

  final AppStore store;

  int _step = 0;
  String _keyType = '';
  String _cryptoType = '';
  String _derivePath = '';

  Future<void> _importAccount() async {
    var acc = await webApi.account.importAccount(
      keyType: _keyType,
      cryptoType: _cryptoType,
      derivePath: _derivePath,
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
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_step == 1) {
      return Scaffold(
        appBar: AppBar(
          title: Text(I18n.of(context).home['import']),
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              setState(() {
                _step = 0;
              });
            },
          ),
        ),
        body: SafeArea(
          child: CreateAccountForm(store.account.setNewAccount, _importAccount),
        ),
      );
    }
    return Scaffold(
      appBar: AppBar(title: Text(I18n.of(context).home['import'])),
      body: SafeArea(
        child: ImportAccountForm(store.account, (Map<String, dynamic> data) {
          if (data['finish'] == null) {
            setState(() {
              _keyType = data['keyType'];
              _cryptoType = data['cryptoType'];
              _derivePath = data['derivePath'];
              _step = 1;
            });
          } else {
            setState(() {
              _keyType = data['keyType'];
              _cryptoType = data['cryptoType'];
              _derivePath = data['derivePath'];
            });
            _importAccount();
          }
        }),
      ),
    );
  }
}
