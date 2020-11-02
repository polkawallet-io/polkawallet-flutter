import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:polka_wallet/page/account/create/createAccountForm.dart';
import 'package:polka_wallet/page/account/import/importAccountForm.dart';
import 'package:polka_wallet/service/substrateApi/api.dart';
import 'package:polka_wallet/store/app.dart';
import 'package:polka_wallet/utils/UI.dart';
import 'package:polka_wallet/utils/format.dart';
import 'package:polka_wallet/utils/i18n/index.dart';

class ImportAccountPage extends StatefulWidget {
  const ImportAccountPage(this.store);

  static final String route = '/account/import';
  final AppStore store;

  @override
  _ImportAccountPageState createState() => _ImportAccountPageState(store);
}

class _ImportAccountPageState extends State<ImportAccountPage> {
  _ImportAccountPageState(this.store);

  final AppStore store;

  int _step = 0;
  String _keyType = '';
  String _cryptoType = '';
  String _derivePath = '';
  bool _submitting = false;

  Future<bool> _importAccount() async {
    setState(() {
      _submitting = true;
    });
    showCupertinoDialog(
      context: context,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: Text(I18n.of(context).home['loading']),
          content: Container(height: 64, child: CupertinoActivityIndicator()),
        );
      },
    );

    /// import account
    var acc = await webApi.account.importAccount(
      keyType: _keyType,
      cryptoType: _cryptoType,
      derivePath: _derivePath,
    );

    /// check if account duplicate
    if (acc != null) {
      if (acc['error'] != null) {
        if (acc['error'] == 'unreachable') {
          showCupertinoDialog(
            context: context,
            builder: (BuildContext context) {
              final Map<String, String> accDic = I18n.of(context).account;
              return CupertinoAlertDialog(
                title: Container(),
                content:
                    Text('${accDic['import.invalid']} ${accDic[_keyType]}'),
                actions: <Widget>[
                  CupertinoButton(
                    child: Text(I18n.of(context).home['ok']),
                    onPressed: () {
                      setState(() {
                        _step = 0;
                      });
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              );
            },
          );
        } else {
          UI.alertWASM(
            context,
            () {
              setState(() {
                _step = 0;
              });
            },
            isImport: true,
          );
        }
        Navigator.of(context).pop();
        setState(() {
          _submitting = false;
        });
        return false;
      }
      final duplicated = await _checkAccountDuplicate(acc);
      if (duplicated) {
        Navigator.of(context).pop();
        setState(() {
          _submitting = false;
        });
        return false;
      }
      await webApi.account.saveAccount(acc);
      setState(() {
        _submitting = false;
      });
      Navigator.of(context).pop();
      return true;
    }

    showCupertinoDialog(
      context: context,
      builder: (BuildContext context) {
        final Map<String, String> accDic = I18n.of(context).account;
        return CupertinoAlertDialog(
          title: Container(),
          content:
              Text('${accDic['import.invalid']} ${accDic['create.password']}'),
          actions: <Widget>[
            CupertinoButton(
              child: Text(I18n.of(context).home['cancel']),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
    return false;
  }

  Future<bool> _checkAccountDuplicate(Map<String, dynamic> acc) async {
    int index =
        store.account.accountList.indexWhere((i) => i.pubKey == acc['pubKey']);
    if (index > -1) {
      Map<String, String> pubKeyMap =
          store.account.pubKeyAddressMap[store.settings.endpoint.ss58];
      String address = pubKeyMap[acc['pubKey']];
      if (address != null) {
        final duplicate = await showCupertinoDialog(
          context: context,
          builder: (BuildContext context) {
            return CupertinoAlertDialog(
              title: Text(Fmt.address(address)),
              content: Text(I18n.of(context).account['import.duplicate']),
              actions: <Widget>[
                CupertinoButton(
                  child: Text(I18n.of(context).home['cancel']),
                  onPressed: () => Navigator.of(context).pop(true),
                ),
                CupertinoButton(
                  child: Text(I18n.of(context).home['ok']),
                  onPressed: () => Navigator.of(context).pop(false),
                ),
              ],
            );
          },
        );
        return duplicate;
      }
    }
    return false;
  }

  Future<bool> _onNext(Map<String, dynamic> data) async {
    if (data['finish'] == null) {
      setState(() {
        _keyType = data['keyType'];
        _cryptoType = data['cryptoType'];
        _derivePath = data['derivePath'];
        _step = 1;
      });
      return false;
    } else {
      setState(() {
        _keyType = data['keyType'];
        _cryptoType = data['cryptoType'];
        _derivePath = data['derivePath'];
      });
      final saved = await _importAccount();
      return saved;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_step == 1) {
      return Scaffold(
        appBar: AppBar(
          title: Text(I18n.of(context).home['import']),
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios),
            onPressed: () {
              setState(() {
                _step = 0;
              });
            },
          ),
        ),
        body: SafeArea(
          child: CreateAccountForm(
            store.account,
            submitting: _submitting,
            onSubmit: _importAccount,
          ),
        ),
      );
    }
    return Scaffold(
      appBar: AppBar(title: Text(I18n.of(context).home['import'])),
      body: SafeArea(
        child: ImportAccountForm(store, _onNext),
      ),
    );
  }
}
