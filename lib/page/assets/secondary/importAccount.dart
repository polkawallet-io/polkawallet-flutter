import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:polka_wallet/store/assets.dart';

class ImportAccount extends StatefulWidget {
  const ImportAccount(this.evalJavascript, this.accountCreate);

  final Function evalJavascript;
  final Account accountCreate;

  @override
  _ImportAccountState createState() =>
      _ImportAccountState(evalJavascript, accountCreate);
}

class _ImportAccountState extends State<ImportAccount> {
  _ImportAccountState(this.evalJavascript, this.accountCreate);

  final Function evalJavascript;
  final Account accountCreate;

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
    evalJavascript('account.gen()');
  }

  Widget _buildKeyField() {
    switch (_selection) {
      case 'Mnemonic':
        String v = accountCreate.mnemonic;
        return TextFormField(
          initialValue: v,
          maxLines: 3,
        );
      case 'Raw Seed':
        String v = accountCreate.seed;
        return new TextFormField(
          initialValue: v,
        );
      case 'KeyStore':
        return TextFormField(
          maxLines: 4,
        );
      default:
        return TextFormField(
          maxLines: 4,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    print('build page');
    return Scaffold(
      appBar: AppBar(title: const Text('Create Account')),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
//            autovalidate: true,
          child: accountCreate.address == ''
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    CircularProgressIndicator(),
                    Text('Loading items...'),
                  ],
                )
              : ListView(
                  children: <Widget>[
                    Center(
                      child: Text(accountCreate.address),
                    ),
                    Text('Create from'),
                    DropdownButton<String>(
                        value: _selection,
                        onChanged: (String value) {
                          if (value != 'KeyStore') {
                            evalJavascript('account.gen()');
                          }
                          setState(() {
                            _selection = value;
                          });
                        },
                        items: <String>['Mnemonic', 'Raw Seed', 'KeyStore']
                            .map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList()),
                    _buildKeyField(),
                    Divider(),
                    Text('Name'),
                    TextFormField(
                      controller: _nameCtrl,
                      validator: (v) {
                        return v.trim().length > 0 ? null : "用户名不能为空";
                      },
                    ),
                    Divider(),
                    Text('Password'),
                    TextFormField(
                      controller: _passCtrl,
                      obscureText: true,
                      onChanged: (v) {
                        setState(() {
                          _password = v;
                        });
                      },
                    ),
                    Divider(),
                    Text('Confirm Password'),
                    TextFormField(
                      controller: _pass2Ctrl,
                      obscureText: true,
                      validator: (v) {
                        if (_password != v) {
                          return 'Confirm Password';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
