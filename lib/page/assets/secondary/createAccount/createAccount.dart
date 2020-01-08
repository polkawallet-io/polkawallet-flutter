import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:polka_wallet/utils/i18n.dart';

class CreateAccount extends StatefulWidget {
  const CreateAccount();

  @override
  _CreateAccountState createState() => _CreateAccountState();
}

class _CreateAccountState extends State<CreateAccount> {
  _CreateAccountState();

  int _step = 0;

  String _password;

  TextEditingController _nameCtrl = new TextEditingController();
  TextEditingController _passCtrl = new TextEditingController();
  TextEditingController _pass2Ctrl = new TextEditingController();

  final _formKey = GlobalKey<FormState>();

  Widget _buildStep0(BuildContext context) {
    var buttonStyle = Theme.of(context).textTheme.button;

    return Scaffold(
      appBar: AppBar(title: const Text('Create Account')),
      body: ListView(
        padding: EdgeInsets.all(32),
        children: <Widget>[
          Image.asset('assets/images/public/About_logo.png'),
          Container(
            padding: EdgeInsets.only(top: 16),
            child: RaisedButton(
              padding: EdgeInsets.all(16),
              color: Colors.pink,
              child: Text(
                I18n.of(context).home['create'],
                style: buttonStyle,
              ),
              onPressed: () {
                setState(() {
                  _step = 1;
                });
              },
            ),
          ),
          Container(
            padding: EdgeInsets.only(top: 16),
            child: RaisedButton(
              padding: EdgeInsets.all(16),
              color: Colors.pink,
              child: Text(
                I18n.of(context).home['import'],
                style: buttonStyle,
              ),
              onPressed: () {
                print('import');
              },
            ),
          )
        ],
      ),
    );
  }

  Widget _buildStep2(BuildContext context) {
    var theme = Theme.of(context).textTheme;
    final Map<String, String> i18n = I18n.of(context).account;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Account'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            setState(() {
              _step = 1;
            });
          },
        ),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Expanded(
            child: ListView(
              padding: EdgeInsets.all(32),
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
                  padding: EdgeInsets.all(32),
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
                                  onPressed: () => Navigator.pushNamed(
                                      context, '/account/backup'),
                                ),
                              ],
                            );
                          });
                      print('finish');
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
    final Map<String, String> i18n = I18n.of(context).account;
    if (_step == 0) {
      return _buildStep0(context);
    }
    if (_step == 2) {
      return _buildStep2(context);
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Account'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            setState(() {
              _step = 0;
            });
          },
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
//            autovalidate: true,
          child: ListView(
            children: <Widget>[
              TextFormField(
                decoration: InputDecoration(
                  icon: Icon(Icons.person),
                  hintText: i18n['create.name'],
                  labelText: i18n['create.name'],
                ),
                controller: _nameCtrl,
                validator: (v) {
                  return v.trim().length > 0 ? null : i18n['create.name.error'];
                },
              ),
              TextFormField(
                decoration: InputDecoration(
                  icon: Icon(Icons.lock),
                  hintText: i18n['create.password'],
                  labelText: i18n['create.password'],
                ),
                controller: _passCtrl,
                validator: (v) {
                  var pass =
                      RegExp(r'^(?![0-9]+$)(?![a-zA-Z]+$)[0-9A-Za-z]{6,20}$');
                  return v.trim().contains(pass)
                      ? null
                      : i18n['create.password.error'];
                },
                obscureText: true,
                onChanged: (v) {
                  setState(() {
                    _password = v;
                  });
                },
              ),
              TextFormField(
                decoration: InputDecoration(
                  icon: Icon(Icons.lock),
                  hintText: i18n['create.password2'],
                  labelText: i18n['create.password2'],
                ),
                controller: _pass2Ctrl,
                obscureText: true,
                validator: (v) {
                  return _password != v ? i18n['create.password2.error'] : null;
                },
              ),
              Container(
                padding: EdgeInsets.only(top: 16),
                child: RaisedButton(
                  padding: EdgeInsets.all(16),
                  color: Colors.pink,
                  textColor: Colors.white,
                  child: Text(I18n.of(context).home['next']),
                  onPressed: () {
                    if (_formKey.currentState.validate()) {
                      setState(() {
                        _step = 2;
                      });
                    }
                  },
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
