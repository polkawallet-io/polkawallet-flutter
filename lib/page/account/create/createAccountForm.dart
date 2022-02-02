import 'package:encointer_wallet/common/components/gradientElements.dart';
import 'package:encointer_wallet/store/app.dart';
import 'package:encointer_wallet/utils/format.dart';
import 'package:encointer_wallet/utils/i18n/index.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CreateAccountForm extends StatelessWidget {
  CreateAccountForm({this.setNewAccount, this.submitting, this.onSubmit, this.store});
//todo get rid of the setNewAccount method where password is stored
  final Function setNewAccount;
  final Function onSubmit;
  final bool submitting;
  final AppStore store;

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
          Expanded(
            child: ListView(
              padding: EdgeInsets.fromLTRB(16, 0, 16, 16),
              children: <Widget>[
                TextFormField(
                  key: Key('create-account-name'),
                  decoration: InputDecoration(
                    icon: Icon(Icons.person),
                    hintText: dic['create.hint'],
                    labelText: "${dic['create.name']}: ${dic['create.hint']}",
                  ),
                  controller: _nameCtrl,
                ),
                // todo: couldnt wrap this ternary in a single one, had to do two ternaries (for each pin)... clang: how to?
                (store.account.accountListAll.isEmpty)
                    ? TextFormField(
                        key: Key('create-account-pin'),
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          icon: Icon(Icons.lock),
                          hintText: dic['create.password'],
                          labelText: dic['create.password'],
                        ),
                        controller: _passCtrl,
                        validator: (v) {
                          return Fmt.checkPassword(v.trim()) ? null : dic['create.password.error'];
                        },
                        obscureText: true,
                        inputFormatters: <TextInputFormatter>[FilteringTextInputFormatter.digitsOnly],
                      )
                    : Container(),
                (store.account.accountListAll.isEmpty)
                    ? TextFormField(
                        key: Key('create-account-pin2'),
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          icon: Icon(Icons.lock),
                          hintText: dic['create.password2'],
                          labelText: dic['create.password2'],
                        ),
                        controller: _pass2Ctrl,
                        obscureText: true,
                        validator: (v) {
                          return _passCtrl.text != v ? dic['create.password2.error'] : null;
                        },
                        inputFormatters: <TextInputFormatter>[FilteringTextInputFormatter.digitsOnly],
                      )
                    : Container(),
              ],
            ),
          ),
          Container(
            key: Key('create-account-confirm'),
            padding: EdgeInsets.all(16),
            child: PrimaryButton(
              child: Text(I18n.of(context).account['create']),
              onPressed: () {
                if (_formKey.currentState.validate()) {
                  if (store.account.accountListAll.isEmpty) {
                    setNewAccount(_nameCtrl.text.isNotEmpty ? _nameCtrl.text : dic['create.default'], _passCtrl.text);
                  } else {
                    // cachedPin won't be empty, because cachedPin is verified not to be empty before user adds an account in profile/index.dart
                    setNewAccount(
                        _nameCtrl.text.isNotEmpty ? _nameCtrl.text : dic['create.default'], store.settings.cachedPin);
                  }
                  onSubmit();
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
