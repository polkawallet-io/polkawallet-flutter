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

  Widget _buildStep0(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(I18n.of(context).home['import'])),
      body: CreateAccountForm(store.account.setNewAccount, () {
        setState(() {
          _step = 1;
        });
      }),
    );
  }

  Widget _buildStep1(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(I18n.of(context).home['import'])),
      body: ImportAccountForm(store.account.setNewAccountKey,
          (Map<String, dynamic> data) {
        store.api.importAccount(
          keyType: data['keyType'],
          cryptoType: data['cryptoType'],
        );
        Navigator.popUntil(context, ModalRoute.withName('/'));
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_step == 1) {
      return _buildStep1(context);
    }
    return _buildStep0(context);
  }
}
