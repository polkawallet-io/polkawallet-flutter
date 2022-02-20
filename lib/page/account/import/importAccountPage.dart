import 'package:encointer_wallet/page/account/create/addAccountForm.dart';
import 'package:encointer_wallet/page/account/create/createAccountForm.dart';
import 'package:encointer_wallet/page/account/import/importAccountForm.dart';
import 'package:encointer_wallet/service/substrateApi/api.dart';
import 'package:encointer_wallet/store/app.dart';
import 'package:encointer_wallet/utils/UI.dart';
import 'package:encointer_wallet/utils/format.dart';
import 'package:encointer_wallet/utils/translations/index.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:encointer_wallet/utils/translations/translations.dart';

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
          title: Text(I18n.of(context).translationsForLocale().home.loading),
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

    Navigator.of(context).pop();

    /// check if account duplicate
    if (acc != null) {
      if (acc['error'] != null) {
        if (acc['error'] == 'unreachable') {
          showCupertinoDialog(
            context: context,
            builder: (BuildContext context) {
              final Translations dic = I18n.of(context).translationsForLocale();
              return CupertinoAlertDialog(
                title: Container(),
                // content: Text('${accDic['importInvalid']} ${accDic[_keyType]}'),
                content: Text('${dic.account.importInvalid} accDic[_keyType]'), // TODO what is this?
                actions: <Widget>[
                  CupertinoButton(
                    child: Text(I18n.of(context).translationsForLocale().home.ok),
                    onPressed: () {
                      setState(() {
                        _step = 0;
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
          UI.alertWASM(context, () {
            setState(() {
              _step = 0;
              _submitting = false;
            });
          });
        }
        return;
      }
      _checkAccountDuplicate(acc);
      return;
    }

    // account == null
    showCupertinoDialog(
      context: context,
      builder: (BuildContext context) {
        final Translations dic = I18n.of(context).translationsForLocale();
        return CupertinoAlertDialog(
          title: Container(),
          content: Text('${dic.account.importInvalid} ${dic.account.createPassword}'),
          actions: <Widget>[
            CupertinoButton(
              child: Text(I18n.of(context).translationsForLocale().home.cancel),
              onPressed: () {
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
  }

  Future<void> _checkAccountDuplicate(Map<String, dynamic> acc) async {
    int index = store.account.accountList.indexWhere((i) => i.pubKey == acc['pubKey']);
    if (index > -1) {
      Map<String, String> pubKeyMap = store.account.pubKeyAddressMap[store.settings.endpoint.ss58];
      String address = pubKeyMap[acc['pubKey']];
      if (address != null) {
        showCupertinoDialog(
          context: context,
          builder: (BuildContext context) {
            return CupertinoAlertDialog(
              title: Text(Fmt.address(address)),
              content: Text(I18n.of(context).translationsForLocale().account.importDuplicate),
              actions: <Widget>[
                CupertinoButton(
                  child: Text(I18n.of(context).translationsForLocale().home.cancel),
                  onPressed: () {
                    setState(() {
                      _submitting = false;
                    });
                    Navigator.of(context).pop();
                  },
                ),
                CupertinoButton(
                  child: Text(I18n.of(context).translationsForLocale().home.ok),
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

    await store.loadAccountCache();

    // fetch info for the imported account
    String pubKey = acc['pubKey'];
    webApi.fetchAccountData();
    webApi.account.fetchAccountsBonded([pubKey]);
    webApi.account.getPubKeyIcons([pubKey]);
    store.account.setCurrentAccount(pubKey);

    // go to home page
    Navigator.popUntil(context, ModalRoute.withName('/'));
  }

  @override
  Widget build(BuildContext context) {
    if (_step == 1) {
      return Scaffold(
        appBar: AppBar(
          title: Text(
            I18n.of(context).translationsForLocale().home.accountImport,
            style: Theme.of(context).textTheme.headline3,
          ),
          centerTitle: true,
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
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
          child: !_submitting && store.account.accountListAll.isEmpty
              ? CreateAccountForm(store: store)
              : (!_submitting && store.account.accountListAll.isNotEmpty)
                  ? AddAccountForm(
                      isImporting: true,
                      setNewAccount: store.account.setNewAccount,
                      submitting: _submitting,
                      onSubmit: _importAccount,
                      store: store)
                  : Center(child: CupertinoActivityIndicator()),
        ),
      );
    }
    // todo what are the different steps 1 and 0? do i need here to add also the AddAccountForm?
    return Scaffold(
      appBar: AppBar(title: Text(I18n.of(context).translationsForLocale().home.accountImport)),
      body: SafeArea(
        child: !_submitting
            ? ImportAccountForm(store, (Map<String, dynamic> data) {
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
              })
            : Center(child: CupertinoActivityIndicator()),
      ),
    );
  }
}
