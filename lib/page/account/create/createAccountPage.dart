import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:polka_wallet/common/components/accountAdvanceOption.dart';
import 'package:polka_wallet/common/components/roundedButton.dart';
import 'package:polka_wallet/page/account/create/backupAccountPage.dart';
import 'package:polka_wallet/page/account/create/createAccountForm.dart';
import 'package:polka_wallet/service/substrateApi/api.dart';
import 'package:polka_wallet/store/app.dart';
import 'package:polka_wallet/utils/UI.dart';
import 'package:polka_wallet/utils/i18n/index.dart';

class CreateAccountPage extends StatefulWidget {
  const CreateAccountPage(this.store);

  static final String route = '/account/create';
  final AppStore store;

  @override
  _CreateAccountPageState createState() => _CreateAccountPageState();
}

class _CreateAccountPageState extends State<CreateAccountPage> {
  AccountAdvanceOptionParams _advanceOptions = AccountAdvanceOptionParams();

  int _step = 0;
  bool _submitting = false;

  Future<bool> _importAccount() async {
    setState(() {
      _submitting = true;
    });
    showCupertinoDialog(
      context: context,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: Text(I18n.of(context).home['loading']),
          content: Container(height: 64, child: CupertinoActivityIndicator()),
        );
      },
    );

    var acc = await webApi.account.importAccount(
      cryptoType:
          _advanceOptions.type ?? AccountAdvanceOptionParams.encryptTypeSR,
      derivePath: _advanceOptions.path ?? '',
    );

    if (acc['error'] != null) {
      Navigator.of(context).pop();
      UI.alertWASM(context, () {
        setState(() {
          _submitting = false;
          _step = 0;
        });
      });
      return false;
    }

    await webApi.account.saveAccount(acc);
    setState(() {
      _submitting = false;
    });
    Navigator.of(context).pop();
    return true;
  }

  Future<void> _onNext() async {
    final next = await showCupertinoDialog(
      context: context,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: Container(),
          content: Column(
            children: <Widget>[
              Image.asset('assets/images/public/dontscreen.png'),
              Container(
                padding: EdgeInsets.only(top: 16, bottom: 24),
                child: Text(
                  I18n.of(context).account['create.warn9'],
                  style: Theme.of(context).textTheme.headline4,
                ),
              ),
              Text(I18n.of(context).account['create.warn10']),
            ],
          ),
          actions: <Widget>[
            CupertinoButton(
              child: Text(I18n.of(context).home['cancel']),
              onPressed: () => Navigator.of(context).pop(false),
            ),
            CupertinoButton(
              child: Text(I18n.of(context).home['ok']),
              onPressed: () => Navigator.of(context).pop(true),
            ),
          ],
        );
      },
    );
    if (next) {
      final advancedOptions =
          await Navigator.pushNamed(context, BackupAccountPage.route);
      if (advancedOptions != null) {
        setState(() {
          _step = 1;
        });
      }
    }
  }

  Widget _generateSeed(BuildContext context) {
    var theme = Theme.of(context).textTheme;
    final Map<String, String> i18n = I18n.of(context).account;

    return Scaffold(
      appBar: AppBar(title: Text(I18n.of(context).home['create'])),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Expanded(
              child: ListView(
                padding: EdgeInsets.all(16),
                children: <Widget>[
                  Container(
                    padding: EdgeInsets.only(bottom: 16),
                    child: Text(i18n['create.warn1'], style: theme.headline4),
                  ),
                  Text(i18n['create.warn2']),
                  Container(
                    padding: EdgeInsets.only(bottom: 16, top: 32),
                    child: Text(i18n['create.warn3'], style: theme.headline4),
                  ),
                  Container(
                    padding: EdgeInsets.only(bottom: 8),
                    child: Text(i18n['create.warn4']),
                  ),
                  Text(i18n['create.warn5']),
                  Container(
                    padding: EdgeInsets.only(bottom: 16, top: 32),
                    child: Text(i18n['create.warn6'], style: theme.headline4),
                  ),
                  Container(
                    padding: EdgeInsets.only(bottom: 8),
                    child: Text(i18n['create.warn7']),
                  ),
                  Text(i18n['create.warn8']),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.all(16),
              child: RoundedButton(
                text: I18n.of(context).home['next'],
                onPressed: () => _onNext(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_step == 0) {
      return _generateSeed(context);
    }
    return Scaffold(
      appBar: AppBar(
        title: Text(I18n.of(context).home['create']),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios),
          onPressed: () {
            setState(() {
              _step = 0;
            });
          },
        ),
      ),
      body: SafeArea(
        child: CreateAccountForm(
          widget.store.account,
          submitting: _submitting,
          onSubmit: _importAccount,
        ),
      ),
    );
  }
}
