import 'package:biometric_storage/biometric_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:polka_wallet/common/components/roundedButton.dart';
import 'package:polka_wallet/service/substrateApi/api.dart';
import 'package:polka_wallet/store/account/account.dart';
import 'package:polka_wallet/utils/format.dart';
import 'package:polka_wallet/utils/i18n/index.dart';

class CreateAccountForm extends StatefulWidget {
  CreateAccountForm(this.store, {this.submitting, this.onSubmit});

  final AccountStore store;
  final Future<bool> Function() onSubmit;
  final bool submitting;

  @override
  _CreateAccountFormState createState() => _CreateAccountFormState();
}

class _CreateAccountFormState extends State<CreateAccountForm> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nameCtrl = new TextEditingController();
  final TextEditingController _passCtrl = new TextEditingController();
  final TextEditingController _pass2Ctrl = new TextEditingController();

  bool _supportBiometric = false;
  bool _enableBiometric = true; // if the biometric usage checkbox checked

  Future<void> _checkBiometricAuth() async {
    final response = await BiometricStorage().canAuthenticate();
    final supportBiometric = response == CanAuthenticateResponse.success;
    if (!supportBiometric) {
      return;
    }
    setState(() {
      _supportBiometric = supportBiometric;
    });
  }

  Future<void> _authBiometric() async {
    final storeFile = await webApi.account.getBiometricPassStoreFile(
      context,
      widget.store.currentAccountPubKey,
    );

    try {
      await storeFile.write(widget.store.newAccount.password);
      webApi.account.setBiometricEnabled(widget.store.currentAccountPubKey);
    } catch (err) {
      // ignore
    }
  }

  Future<void> _onSubmit() async {
    if (_formKey.currentState.validate()) {
      widget.store.setNewAccount(_nameCtrl.text, _passCtrl.text);
      final success = await widget.onSubmit();

      /// save password with biometrics after import success
      if (success && _supportBiometric && _enableBiometric) {
        await _authBiometric();
      }

      widget.store.resetNewAccount();
      Navigator.popUntil(context, ModalRoute.withName('/'));
    }
  }

  @override
  void initState() {
    super.initState();
    _checkBiometricAuth();
  }

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
                  decoration: InputDecoration(
                    icon: Icon(Icons.person),
                    hintText: dic['create.name'],
                    labelText: dic['create.name'],
                  ),
                  controller: _nameCtrl,
                  validator: (v) {
                    return v.trim().length > 0
                        ? null
                        : dic['create.name.error'];
                  },
                ),
                TextFormField(
                  decoration: InputDecoration(
                    icon: Icon(Icons.lock),
                    hintText: dic['create.password'],
                    labelText: dic['create.password'],
                  ),
                  controller: _passCtrl,
                  validator: (v) {
                    return Fmt.checkPassword(v.trim())
                        ? null
                        : dic['create.password.error'];
                  },
                  obscureText: true,
                ),
                TextFormField(
                  decoration: InputDecoration(
                    icon: Icon(Icons.lock),
                    hintText: dic['create.password2'],
                    labelText: dic['create.password2'],
                  ),
                  controller: _pass2Ctrl,
                  obscureText: true,
                  validator: (v) {
                    return _passCtrl.text != v
                        ? dic['create.password2.error']
                        : null;
                  },
                ),
                _supportBiometric
                    ? Padding(
                        padding: EdgeInsets.only(top: 24),
                        child: Row(
                          children: [
                            SizedBox(
                              height: 24,
                              width: 24,
                              child: Checkbox(
                                value: _enableBiometric,
                                onChanged: (v) {
                                  setState(() {
                                    _enableBiometric = v;
                                  });
                                },
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.only(left: 16),
                              child: Text(
                                  I18n.of(context).home['unlock.bio.enable']),
                            )
                          ],
                        ),
                      )
                    : Container(),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.all(16),
            child: RoundedButton(
              text: I18n.of(context).home['next'],
              onPressed: widget.submitting ? null : () => _onSubmit(),
            ),
          ),
        ],
      ),
    );
  }
}
