import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:polka_wallet/store/service.dart';

import 'package:provider/provider.dart';
import 'package:polka_wallet/store/assets.dart';

class CreateAccount extends StatefulWidget {
  const CreateAccount(this.emitMsg);

  final Function emitMsg;

  @override
  _CreateAccountState createState() => _CreateAccountState(emitMsg);
}

class _CreateAccountState extends State<CreateAccount>
    with TickerProviderStateMixin {
  _CreateAccountState(this.emitMsg);
  Function emitMsg;

  String _selection = 'Mnemonic';

  Map<String, dynamic> _account = {};
  String _mnemonic, _seed, _keyStore;

  String _password;

  TextEditingController _keyCtrl = new TextEditingController();
  TextEditingController _nameCtrl = new TextEditingController();
  TextEditingController _passCtrl = new TextEditingController();
  TextEditingController _pass2Ctrl = new TextEditingController();

  final _formKey = GlobalKey<FormState>();

  final assetsStore = AssetsStore();

  Widget _buildTextField() {
    switch (_selection) {
      case 'Mnemonic':
        return TextFormField(
          initialValue: assetsStore.newAccount.mnemonic,
          maxLines: 3,
        );
      case 'Raw Seed':
        return TextFormField(
          initialValue: assetsStore.newAccount.seed,
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
  void initState() {
    super.initState();
    emitMsg('get', {'path': '/account/gen'});
  }

  @override
  Widget build(BuildContext context) => Observer(builder: (_) {
        return Scaffold(
          appBar: AppBar(title: const Text('Create Account')),
          body: Padding(
            padding: EdgeInsets.all(16),
            child: Form(
              key: _formKey,
//            autovalidate: true,
              child: ListView(
//            crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Center(
                    child: Text(assetsStore.newAccount.address ?? ''),
                  ),
                  Text('Create from'),
                  DropdownButton<String>(
                      value: _selection,
                      onChanged: (String value) {
                        if (value != 'KeyStore') {
                          emitMsg('get', {'path': '/account/gen'});
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
                  _buildTextField(),
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
      });
}
