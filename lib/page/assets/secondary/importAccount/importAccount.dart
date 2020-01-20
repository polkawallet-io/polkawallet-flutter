import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:polka_wallet/page/assets/secondary/createAccount/createAccountForm.dart';
import 'package:polka_wallet/page/assets/secondary/importAccount/importAccountForm.dart';
import 'package:polka_wallet/store/account.dart';
import 'package:polka_wallet/utils/i18n/index.dart';

class ImportAccount extends StatefulWidget {
  const ImportAccount(this.evalJavascript, this.store);

  final Function evalJavascript;
  final AccountStore store;

  @override
  _ImportAccountState createState() =>
      _ImportAccountState(evalJavascript, store);
}

class _ImportAccountState extends State<ImportAccount> {
  _ImportAccountState(this.evalJavascript, this.store);

  final Function evalJavascript;
  final AccountStore store;

  int _step = 0;
  String _selection = 'Mnemonic';

  Map<String, dynamic> _account = {};
  String _mnemonic, _seed, _keyStore;

  String _password;

  TextEditingController _keyCtrl = new TextEditingController();

  final _formKey = GlobalKey<FormState>();

  Widget _buildStep0(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(I18n.of(context).home['import'])),
      body: CreateAccountForm(store.setNewAccount, () {
        setState(() {
          _step = 1;
        });
      }),
    );
  }

  Widget _buildStep1(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(I18n.of(context).home['import'])),
      body: ImportAccountForm(store.setNewAccount, () {
        setState(() {
          _step = 2;
        });
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
