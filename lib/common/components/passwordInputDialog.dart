import 'package:encointer_wallet/service/substrateApi/api.dart';
import 'package:encointer_wallet/store/account/types/accountData.dart';
import 'package:encointer_wallet/utils/format.dart';
import 'package:encointer_wallet/utils/i18n/index.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

showPasswordInputDialog(context, account, title, onOk) {
  return PasswordInputDialog(
    account: account,
    title: title,
    onCancel: () => Navigator.of(context).pop(),
    onOk: onOk,
  );
}

showPasswordDialogWithAccountSwitch(context, currentAccount, onOk, onAccountSwitch) {
  return PasswordInputDialog(
    account: currentAccount,
    title: Text(
        I18n.of(context).home['unlock.account'].replaceAll('CURRENT_ACCOUNT_NAME', currentAccount.name.toString())),
    onOk: onOk,
    onAccountSwitch: onAccountSwitch,
  );
}

class PasswordInputDialog extends StatefulWidget {
  PasswordInputDialog({this.account, this.title, this.onOk, this.onCancel, this.onAccountSwitch});

  final AccountData account;
  final Widget title;
  final Function onOk;
  final Function onCancel;
  final Function onAccountSwitch;

  @override
  _PasswordInputDialogState createState() => _PasswordInputDialogState();
}

class _PasswordInputDialogState extends State<PasswordInputDialog> {
  final TextEditingController _passCtrl = new TextEditingController();
  bool _submitting = false;

  Future<void> _onOk(String password) async {
    setState(() {
      _submitting = true;
    });
    var res = await webApi.account.checkAccountPassword(widget.account, password);
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
                key: Key('error-dialog-ok'),
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
      content: Padding(
        padding: EdgeInsets.only(top: 16),
        child: CupertinoTextField(
          autofocus: true,
          keyboardType: TextInputType.number,
          placeholder: I18n.of(context).profile['pass.old'],
          controller: _passCtrl,
          onChanged: (v) {
            return Fmt.checkPassword(v.trim()) ? null : I18n.of(context).account['create.password.error'];
          },
          obscureText: true,
          clearButtonMode: OverlayVisibilityMode.editing,
          inputFormatters: <TextInputFormatter>[FilteringTextInputFormatter.digitsOnly],
        ),
      ),
      actions: <Widget>[
        widget.onAccountSwitch != null
            ? CupertinoButton(
                child: Text(dic['switch']),
                onPressed: () {
                  widget.onAccountSwitch();
                },
              )
            : Container(),
        widget.onCancel != null
            ? CupertinoButton(
                child: Text(dic['cancel']),
                onPressed: () {
                  widget.onCancel();
                },
              )
            : Container(),
        CupertinoButton(
          key: Key('password-ok'),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [_submitting ? CupertinoActivityIndicator() : Container(), Text(dic['ok'])],
          ),
          onPressed: _submitting ? null : () => _onOk(_passCtrl.text.trim()),
        ),
      ],
    );
  }
}
