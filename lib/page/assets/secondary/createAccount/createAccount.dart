import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:polka_wallet/page/assets/secondary/createAccount/createAccountForm.dart';
import 'package:polka_wallet/utils/i18n/index.dart';

class CreateAccount extends StatefulWidget {
  const CreateAccount(this.setNewAccount);

  final Function setNewAccount;

  @override
  _CreateAccountState createState() => _CreateAccountState(setNewAccount);
}

class _CreateAccountState extends State<CreateAccount> {
  _CreateAccountState(this.setNewAccount);

  final Function setNewAccount;

  int _step = 1;

  Widget _buildStep2(BuildContext context) {
    var theme = Theme.of(context).textTheme;
    final Map<String, String> i18n = I18n.of(context).account;

    return Scaffold(
      appBar: AppBar(title: const Text('Create Account')),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Expanded(
            child: ListView(
              padding: EdgeInsets.all(16),
              children: <Widget>[
                Container(
                  padding: EdgeInsets.only(bottom: 16),
                  child: Text(i18n['create.warn1'], style: theme.display4),
                ),
                Text(i18n['create.warn2']),
                Container(
                  padding: EdgeInsets.only(bottom: 16, top: 32),
                  child: Text(i18n['create.warn3'], style: theme.display4),
                ),
                Container(
                  padding: EdgeInsets.only(bottom: 8),
                  child: Text(i18n['create.warn4']),
                ),
                Text(i18n['create.warn5']),
                Container(
                  padding: EdgeInsets.only(bottom: 16, top: 32),
                  child: Text(i18n['create.warn6'], style: theme.display4),
                ),
                Container(
                  padding: EdgeInsets.only(bottom: 8),
                  child: Text(i18n['create.warn7']),
                ),
                Text(i18n['create.warn8']),
              ],
            ),
          ),
          Row(
            children: <Widget>[
              Expanded(
                child: Container(
                  padding: EdgeInsets.fromLTRB(16, 8, 16, 32),
                  child: RaisedButton(
                    padding: EdgeInsets.all(16),
                    color: Colors.pink,
                    child: Text(
                      I18n.of(context).home['next'],
                      style: theme.button,
                    ),
                    onPressed: () {
                      showCupertinoDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return CupertinoAlertDialog(
                              title: Container(),
                              content: Column(
                                children: <Widget>[
                                  Image.asset(
                                      'assets/images/public/dontscreen.png'),
                                  Container(
                                    padding:
                                        EdgeInsets.only(top: 16, bottom: 24),
                                    child: Text(
                                      I18n.of(context).account['create.warn9'],
                                      style:
                                          Theme.of(context).textTheme.display4,
                                    ),
                                  ),
                                  Text(I18n.of(context)
                                      .account['create.warn10']),
                                ],
                              ),
                              actions: <Widget>[
                                CupertinoButton(
                                  child: Text(I18n.of(context).home['cancel']),
                                  onPressed: () => Navigator.of(context).pop(),
                                ),
                                CupertinoButton(
                                  child: Text(I18n.of(context).home['ok']),
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                    Navigator.pushNamed(
                                        context, '/account/backup');
                                  },
                                ),
                              ],
                            );
                          });
                    },
                  ),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_step == 2) {
      return _buildStep2(context);
    }
    return Scaffold(
      appBar: AppBar(
        title: Text(I18n.of(context).home['create']),
      ),
      body: CreateAccountForm(setNewAccount, () {
        setState(() {
          _step = 2;
        });
      }),
    );
  }
}
