import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:polka_wallet/utils/i18n/index.dart';

class CreateAccountForm extends StatelessWidget {
  CreateAccountForm(this.setNewAccount, this.onSubmit);

  final Function setNewAccount;
  final Function onSubmit;

  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nameCtrl = new TextEditingController();
  final TextEditingController _passCtrl = new TextEditingController();
  final TextEditingController _pass2Ctrl = new TextEditingController();

  @override
  Widget build(BuildContext context) {
    final Map<String, String> dic = I18n.of(context).account;

    return Form(
      key: _formKey,
      child: Column(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(left: 16, right: 16),
            child: TextFormField(
              decoration: InputDecoration(
                icon: Icon(Icons.person),
                hintText: dic['create.name'],
                labelText: dic['create.name'],
              ),
              controller: _nameCtrl,
              validator: (v) {
                return v.trim().length > 0 ? null : dic['create.name.error'];
              },
            ),
          ),
          Padding(
            padding: EdgeInsets.only(left: 16, right: 16),
            child: TextFormField(
              decoration: InputDecoration(
                icon: Icon(Icons.lock),
                hintText: dic['create.password'],
                labelText: dic['create.password'],
              ),
              controller: _passCtrl,
              validator: (v) {
                var pass =
                    RegExp(r'^(?![0-9]+$)(?![a-zA-Z]+$)[0-9A-Za-z]{6,20}$');
                return v.trim().contains(pass)
                    ? null
                    : dic['create.password.error'];
              },
              obscureText: true,
            ),
          ),
          Padding(
            padding: EdgeInsets.only(left: 16, right: 16),
            child: TextFormField(
              decoration: InputDecoration(
                icon: Icon(Icons.lock),
                hintText: dic['create.password2'],
                labelText: dic['create.password2'],
              ),
              controller: _pass2Ctrl,
              obscureText: true,
              validator: (v) {
                return _passCtrl.value.text != v
                    ? dic['create.password2.error']
                    : null;
              },
            ),
          ),
          Expanded(child: Container()),
          Row(
            children: <Widget>[
              Expanded(
                child: Container(
                  padding: EdgeInsets.all(16),
                  child: RaisedButton(
                    padding: EdgeInsets.all(16),
                    color: Colors.pink,
                    textColor: Colors.white,
                    child: Text(I18n.of(context).home['next']),
                    onPressed: () {
                      if (_formKey.currentState.validate()) {
                        setNewAccount(_nameCtrl.text, _passCtrl.text);
                        onSubmit();
                      }
                    },
                  ),
                ),
              )
            ],
          ),
        ],
      ),
    );
  }
}
