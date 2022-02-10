import 'package:encointer_wallet/common/components/accountAdvanceOption.dart';
import 'package:encointer_wallet/page/account/create/addAccountForm.dart';
import 'package:encointer_wallet/service/substrateApi/api.dart';
import 'package:encointer_wallet/store/app.dart';
import 'package:encointer_wallet/utils/i18n/index.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:encointer_wallet/common/theme.dart';

class AddAccountPage extends StatefulWidget {
  const AddAccountPage(this.store);

  static final String route = '/account/addAccount';
  final AppStore store;

  @override
  _AddAccountPageState createState() => _AddAccountPageState(store);
}

class _AddAccountPageState extends State<AddAccountPage> {
  _AddAccountPageState(this.store);

  final AppStore store;

  bool _submitting = false;

  Future<void> _createAndImportAccount() async {
    setState(() {
      _submitting = true;
    });

    await webApi.account.generateAccount();

    var acc = await webApi.account.importAccount(
      cryptoType: AccountAdvanceOptionParams.encryptTypeSR,
      derivePath: '',
    );

    if (acc['error'] != null) {
      setState(() {
        _submitting = false;
      });
      _showErrorCreatingAccountDialog(context);
      return;
    }

    await store.account.addAccount(acc, store.account.newAccount.password);
    webApi.account.encodeAddress([acc['pubKey']]);

    store.assets.loadAccountCache();

    // fetch info for the imported account
    String pubKey = acc['pubKey'];
    webApi.assets.fetchBalance();
    webApi.account.fetchAccountsBonded([pubKey]);
    webApi.account.getPubKeyIcons([pubKey]);
    store.account.setCurrentAccount(pubKey);

    setState(() {
      _submitting = false;
    });
    // go to home page
    Navigator.popUntil(context, ModalRoute.withName('/'));
  }

  static Future<void> _showErrorCreatingAccountDialog(BuildContext context) async {
    showCupertinoDialog(
      context: context,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: Container(),
          content: Text(I18n.of(context).account['create.error']),
          actions: <Widget>[
            CupertinoButton(
              child: Text(I18n.of(context).home['ok']),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> arg = ModalRoute.of(context).settings.arguments;
    final Map<String, String> dic = I18n.of(context).profile;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          dic['account.add'],
        ),
        leading: Container(),
        actions: <Widget>[
          IconButton(
            icon: Icon(
              Icons.close,
              color: encointerGrey,
            ),
            onPressed: () {
              Navigator.popUntil(context, ModalRoute.withName('/'));
            },
          )
        ],
      ),
      body: SafeArea(
        child: !_submitting
            ? AddAccountForm(
                isImporting: arg['isImporting'],
                setNewAccount: store.account.setNewAccount,
                submitting: _submitting,
                onSubmit: () {
                  setState(() {
                    _createAndImportAccount();
                  });
                },
                store: store,
              )
            : Center(child: CupertinoActivityIndicator()),
      ),
    );
  }
}
