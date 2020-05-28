import 'package:flutter/cupertino.dart';
import 'package:polka_wallet/service/substrateApi/api.dart';
import 'package:polka_wallet/utils/format.dart';
import 'package:polka_wallet/utils/i18n/index.dart';

class PasswordInputDialog extends StatefulWidget {
  PasswordInputDialog({this.title, this.onOk});

  final Widget title;
  final Function onOk;

  @override
  _PasswordInputDialog createState() =>
      _PasswordInputDialog(title: title, onOk: onOk);
}

class _PasswordInputDialog extends State<PasswordInputDialog> {
  _PasswordInputDialog({this.title, this.onOk});

  final Widget title;
  final Function(String) onOk;

  final TextEditingController _passCtrl = new TextEditingController();

  Future<void> _onOk(String password) async {
    var res = await webApi.account.checkAccountPassword(password);
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
      onOk(password);
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
      title: title ?? Container(),
      content: Padding(
        padding: EdgeInsets.only(top: 16),
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
      actions: <Widget>[
        CupertinoButton(
          child: Text(dic['cancel']),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        CupertinoButton(
          child: Text(dic['ok']),
          onPressed: () => _onOk(_passCtrl.text.trim()),
        ),
      ],
    );
  }
}
