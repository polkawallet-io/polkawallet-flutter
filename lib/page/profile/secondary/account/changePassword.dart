import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:polka_wallet/service/api.dart';
import 'package:polka_wallet/store/account.dart';
import 'package:polka_wallet/utils/format.dart';
import 'package:polka_wallet/utils/i18n/index.dart';

class ChangePassword extends StatefulWidget {
  ChangePassword(this.api, this.store);

  final Api api;
  final AccountStore store;

  @override
  _ChangePassword createState() => _ChangePassword(api, store);
}

class _ChangePassword extends State<ChangePassword> {
  _ChangePassword(this.api, this.store);

  final Api api;
  final AccountStore store;

  final _formKey = GlobalKey<FormState>();
  final TextEditingController _passOldCtrl = new TextEditingController();
  final TextEditingController _passCtrl = new TextEditingController();
  final TextEditingController _pass2Ctrl = new TextEditingController();

  Future<void> _onSave() async {
    if (_formKey.currentState.validate()) {
      var dic = I18n.of(context).profile;
      var acc =
          await api.changeAccountPassword(_passOldCtrl.text, _passCtrl.text);
      if (acc == null) {
        showCupertinoDialog(
          context: context,
          builder: (BuildContext context) {
            return CupertinoAlertDialog(
              title: Text(dic['pass.error']),
              content: Text(dic['pass.error.txt']),
              actions: <Widget>[
                CupertinoButton(
                  child: Text(I18n.of(context).home['ok']),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            );
          },
        );
      } else {
        acc['name'] = store.currentAccount.name;
        store.updateAccount(acc);
        showCupertinoDialog(
          context: context,
          builder: (BuildContext context) {
            return CupertinoAlertDialog(
              title: Text(dic['pass.success']),
              content: Text(dic['pass.success.txt']),
              actions: <Widget>[
                CupertinoButton(
                  child: Text(I18n.of(context).home['ok']),
                  onPressed: () => Navigator.popUntil(
                      context, ModalRoute.withName('/profile/account')),
                ),
              ],
            );
          },
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    var dic = I18n.of(context).profile;
    var accDic = I18n.of(context).account;
    return Scaffold(
      appBar: AppBar(
        title: Text(dic['pass.change']),
        centerTitle: true,
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: Form(
              key: _formKey,
              child: ListView(
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.fromLTRB(24, 8, 24, 8),
                    child: TextFormField(
                      decoration: InputDecoration(
                        icon: Icon(Icons.lock),
                        hintText: dic['pass.old'],
                        labelText: dic['pass.old'],
                      ),
                      controller: _passOldCtrl,
                      validator: (v) {
                        return Fmt.checkPassword(v.trim())
                            ? null
                            : accDic['create.password.error'];
                      },
                      obscureText: true,
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(24, 8, 24, 8),
                    child: TextFormField(
                      decoration: InputDecoration(
                        icon: Icon(Icons.lock),
                        hintText: dic['pass.new'],
                        labelText: dic['pass.new'],
                      ),
                      controller: _passCtrl,
                      validator: (v) {
                        return Fmt.checkPassword(v.trim())
                            ? null
                            : accDic['create.password.error'];
                      },
                      obscureText: true,
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(24, 8, 24, 8),
                    child: TextFormField(
                      decoration: InputDecoration(
                        icon: Icon(Icons.lock),
                        hintText: dic['pass.new2'],
                        labelText: dic['pass.new2'],
                      ),
                      controller: _pass2Ctrl,
                      validator: (v) {
                        return v.trim() != _passCtrl.text
                            ? accDic['create.password2.error']
                            : null;
                      },
                      obscureText: true,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Row(
            children: <Widget>[
              Expanded(
                child: Container(
                  margin: EdgeInsets.fromLTRB(24, 8, 24, 24),
                  child: RaisedButton(
                      padding: EdgeInsets.all(16),
                      color: Colors.pink,
                      child: Text(
                        dic['contact.save'],
                        style: TextStyle(color: Colors.white),
                      ),
                      onPressed: _onSave),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}
