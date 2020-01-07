import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:polka_wallet/utils/i18n.dart';

class CreateAccount extends StatefulWidget {
  const CreateAccount(this.emitMsg, this.accountCreate);

  final Function emitMsg;
  final Map<String, dynamic> accountCreate;

  @override
  _CreateAccountState createState() =>
      _CreateAccountState(emitMsg, accountCreate);
}

class _CreateAccountState extends State<CreateAccount> {
  _CreateAccountState(this.emitMsg, this.accountCreate);

  final Function emitMsg;
  final Map<String, dynamic> accountCreate;

  String _selection = 'Mnemonic';

  Map<String, dynamic> _account = {};
  String _mnemonic, _seed, _keyStore;

  String _password;

  TextEditingController _keyCtrl = new TextEditingController();
  TextEditingController _nameCtrl = new TextEditingController();
  TextEditingController _passCtrl = new TextEditingController();
  TextEditingController _pass2Ctrl = new TextEditingController();

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    emitMsg('get', {'path': '/account/gen'});
  }

  @override
  Widget build(BuildContext context) {
    final Map<String, String> labels = I18n.of(context).home;
    print('build page');
    return Scaffold(
      appBar: AppBar(title: const Text('Create Account')),
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
                  hintText: labels['name'],
                  labelText: labels['name'],
                ),
                controller: _nameCtrl,
                validator: (v) {
                  return v.trim().length > 0 ? null : "用户名不能为空";
                },
              ),
              TextFormField(
                decoration: InputDecoration(
                  icon: Icon(Icons.lock),
                  hintText: labels['password'],
                  labelText: labels['password'],
                ),
                controller: _passCtrl,
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
                  hintText: labels['password2'],
                  labelText: labels['password2'],
                ),
                controller: _pass2Ctrl,
                obscureText: true,
                validator: (v) {
                  if (_password != v) {
                    return 'Confirm Password';
                  }
                  return null;
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
                    print('next');
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
