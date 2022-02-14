import 'package:encointer_wallet/common/components/encointerTextFormField.dart';
import 'package:encointer_wallet/common/components/gradientElements.dart';
import 'package:encointer_wallet/common/theme.dart';
import 'package:encointer_wallet/service/substrateApi/api.dart';
import 'package:encointer_wallet/store/account/account.dart';
import 'package:encointer_wallet/store/account/types/accountData.dart';
import 'package:encointer_wallet/store/settings.dart';
import 'package:encointer_wallet/utils/format.dart';
import 'package:encointer_wallet/utils/translations/index.dart';
import 'package:encointer_wallet/utils/translations/translations.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ChangePasswordPage extends StatefulWidget {
  ChangePasswordPage(this.store, this.settingsStore);

  static final String route = '/profile/password';
  final AccountStore store;
  final SettingsStore settingsStore;

  @override
  _ChangePassword createState() => _ChangePassword(store, settingsStore);
}

class _ChangePassword extends State<ChangePasswordPage> {
  _ChangePassword(this.store, this.settingsStore);

  final Api api = webApi;
  final AccountStore store;
  final SettingsStore settingsStore;
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _passOldCtrl = new TextEditingController();
  final TextEditingController _passCtrl = new TextEditingController();
  final TextEditingController _pass2Ctrl = new TextEditingController();

  bool _submitting = false;

  Future<void> _onSave() async {
    if (_formKey.currentState.validate()) {
      setState(() {
        _submitting = true;
      });

      final Translations dic = I18n.of(context).translationsForLocale();
      final String passOld = _passOldCtrl.text.trim();
      final String passNew = _passCtrl.text.trim();
      // check password
      final passChecked = await webApi.account.checkAccountPassword(store.currentAccount, passOld);
      if (passChecked == null) {
        showCupertinoDialog(
          context: context,
          builder: (BuildContext context) {
            return CupertinoAlertDialog(
              title: Text(dic.profile.passError),
              content: Text(dic.profile.passErrorTxt),
              actions: <Widget>[
                CupertinoButton(
                  child: Text(I18n.of(context).translationsForLocale().home.ok),
                  onPressed: () {
                    _passOldCtrl.clear();
                    setState(() {
                      _submitting = false;
                    });
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      } else {
        // we need to iterate over all active accounts and update there password
        settingsStore.setPin(passNew);
        store.accountListAll.forEach((account) async {
          final Map acc =
              await api.evalJavascript('account.changePassword("${account.pubKey}", "$passOld", "$passNew")');

          // update encrypted seed after password updated
          store.accountListAll.map((accountData) {
            // use local name, not webApi returned name
            Map<String, dynamic> localAcc = AccountData.toJson(accountData);
            // make metadata the same as the polkadot-js/api's
            acc['meta']['name'] = localAcc['name'];
            store.updateAccount(acc);
            store.updateSeed(accountData.pubKey, _passOldCtrl.text, _passCtrl.text);
          });
        });
        showCupertinoDialog(
          context: context,
          builder: (BuildContext context) {
            return CupertinoAlertDialog(
              title: Text(dic.profile.passSuccess),
              content: Text(dic.profile.passSuccessTxt),
              actions: <Widget>[
                CupertinoButton(
                    child: Text(I18n.of(context).translationsForLocale().home.ok),
                    onPressed: () => {
                          // moving back to profile page after changing password
                          Navigator.popUntil(context, ModalRoute.withName('/')),
                        }),
              ],
            );
          },
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final Translations dic = I18n.of(context).translationsForLocale();
    return Scaffold(
      appBar: AppBar(
        title: Text(dic.profile.passChange),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: <Widget>[
              Expanded(
                child: Center(
                  child: Form(
                    key: _formKey,
                    child: ListView(
                      shrinkWrap: true,
                      children: <Widget>[
                        Text(
                          dic.profile.passHint1,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.headline2,
                        ),
                        SizedBox(height: 16),
                        Text(
                          dic.profile.passHint2,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.headline2.copyWith(color: Colors.black),
                        ),
                        SizedBox(height: 30),
                        EncointerTextFormField(
                          labelText: dic.profile.passOld,
                          controller: _passOldCtrl,
                          validator: (v) {
                            return Fmt.checkPassword(v.trim()) ? null : dic.account.createPasswordError;
                          },
                          obscureText: true,
                          inputFormatters: <TextInputFormatter>[FilteringTextInputFormatter.digitsOnly],
                        ),
                        SizedBox(height: 20),
                        EncointerTextFormField(
                          labelText: dic.profile.passNew,
                          controller: _passCtrl,
                          validator: (v) {
                            return Fmt.checkPassword(v.trim()) ? null : dic.account.createPasswordError;
                          },
                          obscureText: true,
                          inputFormatters: <TextInputFormatter>[FilteringTextInputFormatter.digitsOnly],
                        ),
                        SizedBox(height: 20),
                        EncointerTextFormField(
                          labelText: dic.profile.passNew2,
                          controller: _pass2Ctrl,
                          validator: (v) {
                            return v.trim() != _passCtrl.text ? dic.account.createPassword2Error : null;
                          },
                          obscureText: true,
                          inputFormatters: <TextInputFormatter>[FilteringTextInputFormatter.digitsOnly],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              PrimaryButton(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _submitting ? CupertinoActivityIndicator() : Container(),
                    Text(
                      dic.profile.contactSave,
                      style: Theme.of(context).textTheme.headline3.copyWith(color: encointerLightBlue),
                    ),
                  ],
                ),
                onPressed: _submitting ? null : _onSave,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
