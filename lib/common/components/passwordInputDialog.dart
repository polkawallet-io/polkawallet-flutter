import 'package:biometric_storage/biometric_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:polka_wallet/service/substrateApi/api.dart';
import 'package:polka_wallet/store/account/types/accountData.dart';
import 'package:polka_wallet/utils/format.dart';
import 'package:polka_wallet/utils/i18n/index.dart';

class PasswordInputDialog extends StatefulWidget {
  PasswordInputDialog({this.account, this.title, this.content, this.onOk});

  final AccountData account;
  final Widget title;
  final Widget content;
  final Function onOk;

  @override
  _PasswordInputDialog createState() => _PasswordInputDialog();
}

class _PasswordInputDialog extends State<PasswordInputDialog> {
  final TextEditingController _passCtrl = new TextEditingController();

  bool _submitting = false;

  bool _isBiometricAuthorized = false; // if user authorized biometric usage

  Future<void> _onOk(String password) async {
    setState(() {
      _submitting = true;
    });
    var res =
        await webApi.account.checkAccountPassword(widget.account, password);
    if (mounted) {
      setState(() {
        _submitting = false;
      });
    }
    if (res == null) {
      final Map<String, String> dic = I18n.of(context).profile;
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
      widget.onOk(password);
      Navigator.of(context).pop();
    }
  }

  Future<CanAuthenticateResponse> _checkBiometricAuthenticate() async {
    final response = await BiometricStorage().canAuthenticate();

    final supportBiometric = response == CanAuthenticateResponse.success;
    final isBiometricAuthorized =
        webApi.account.getBiometricEnabled(widget.account.pubKey);
    setState(() {
      _isBiometricAuthorized = isBiometricAuthorized;
    });
    print('_supportBiometric: $supportBiometric');
    print('_isBiometricAuthorized: $isBiometricAuthorized');
    if (supportBiometric) {
      final authStorage = await webApi.account
          .getBiometricPassStoreFile(context, widget.account.pubKey);
      // we prompt biometric auth here if device supported
      // and user authorized to use biometric.
      if (isBiometricAuthorized) {
        try {
          final result = await authStorage.read();
          print('read password from authStorage: $result');
          if (result != null) {
            await _onOk(result);
          }
        } catch (err) {
          Navigator.of(context).pop();
        }
      }
    }
    return response;
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkBiometricAuthenticate();
    });
  }

  @override
  void dispose() {
    _passCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Map<String, String> dic = I18n.of(context).home;

    return CupertinoAlertDialog(
      title: widget.title ?? Container(),
      content: _isBiometricAuthorized
          ? Container()
          : Column(
              children: [
                Padding(
                  padding: EdgeInsets.only(top: 4),
                  child: widget.content ?? Container(),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 12),
                  child: CupertinoTextField(
                    placeholder: I18n.of(context).profile['pass.old'],
                    controller: _passCtrl,
                    onChanged: (v) {
                      return Fmt.checkPassword(v.trim())
                          ? null
                          : I18n.of(context).account['create.password.error'];
                    },
                    obscureText: true,
                    clearButtonMode: OverlayVisibilityMode.editing,
                  ),
                ),
              ],
            ),
      actions: <Widget>[
        CupertinoButton(
          child: Text(dic['cancel']),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        CupertinoButton(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _submitting ? CupertinoActivityIndicator() : Container(),
              Text(dic['ok'])
            ],
          ),
          onPressed: _submitting ? null : () => _onOk(_passCtrl.text.trim()),
        ),
      ],
    );
  }
}
