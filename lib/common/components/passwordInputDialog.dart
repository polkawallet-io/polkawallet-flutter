import 'package:flutter/cupertino.dart';
import 'package:polka_wallet/service/substrateApi/api.dart';
import 'package:polka_wallet/store/account/types/accountData.dart';
import 'package:polka_wallet/utils/format.dart';
import 'package:polka_wallet/utils/i18n/index.dart';

class PasswordInputDialog extends StatefulWidget {
  PasswordInputDialog({this.account, this.title, this.onOk});

  final AccountData account;
  final Widget title;
  final Function onOk;

  @override
  _PasswordInputDialog createState() => _PasswordInputDialog();
}

class _PasswordInputDialog extends State<PasswordInputDialog> {
  final TextEditingController _passCtrl = new TextEditingController();
  bool _submitting = false;

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
