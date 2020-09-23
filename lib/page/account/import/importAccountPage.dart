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

  Future<void> _importAccount() async {
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
    setState(() {
      _submitting = false;
    });
    Navigator.of(context).pop();

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
          UI.alertWASM(context, () {
            setState(() {
              _step = 0;
            });
          });
        }
        return;
      }
      _checkAccountDuplicate(acc);
      return;
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
  }

  Future<void> _checkAccountDuplicate(Map<String, dynamic> acc) async {
    int index =
        store.account.accountList.indexWhere((i) => i.pubKey == acc['pubKey']);
    if (index > -1) {
      Map<String, String> pubKeyMap =
          store.account.pubKeyAddressMap[store.settings.endpoint.ss58];
      String address = pubKeyMap[acc['pubKey']];
      if (address != null) {
        showCupertinoDialog(
          context: context,
          builder: (BuildContext context) {
            return CupertinoAlertDialog(
              title: Text(Fmt.address(address)),
              content: Text(I18n.of(context).account['import.duplicate']),
              actions: <Widget>[
                CupertinoButton(
                  child: Text(I18n.of(context).home['cancel']),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                CupertinoButton(
                  child: Text(I18n.of(context).home['ok']),
                  onPressed: () {
                    _saveAccount(acc);
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      }
    } else {
      _saveAccount(acc);
    }
  }

  Future<void> _saveAccount(Map<String, dynamic> acc) async {
    await store.account.addAccount(acc, store.account.newAccount.password);
    webApi.account.encodeAddress([acc['pubKey']]);

    store.assets.loadAccountCache();
    store.staking.loadAccountCache();

    // fetch info for the imported account
    String pubKey = acc['pubKey'];
    webApi.assets.fetchBalance();
    webApi.staking.fetchAccountStaking();
    webApi.account.fetchAccountsBonded([pubKey]);
    webApi.account.getPubKeyIcons([pubKey]);

    // go to home page
    Navigator.popUntil(context, ModalRoute.withName('/'));
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
            setNewAccount: store.account.setNewAccount,
            submitting: _submitting,
            onSubmit: _importAccount,
          ),
        ),
      );
    }
    return Scaffold(
      appBar: AppBar(title: Text(I18n.of(context).home['import'])),
      body: SafeArea(
        child: ImportAccountForm(store, (Map<String, dynamic> data) {
          if (data['finish'] == null) {
            setState(() {
              _keyType = data['keyType'];
              _cryptoType = data['cryptoType'];
              _derivePath = data['derivePath'];
              _step = 1;
            });
          } else {
            setState(() {
              _keyType = data['keyType'];
              _cryptoType = data['cryptoType'];
              _derivePath = data['derivePath'];
            });
            _importAccount();
          }
        }),
      ),
    );
  }
}
