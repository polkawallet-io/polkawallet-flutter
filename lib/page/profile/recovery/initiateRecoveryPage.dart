import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:polka_wallet/common/components/addressFormItem.dart';
import 'package:polka_wallet/common/components/roundedButton.dart';
import 'package:polka_wallet/page/account/txConfirmPage.dart';
import 'package:polka_wallet/page/profile/contacts/contactListPage.dart';
import 'package:polka_wallet/service/substrateApi/api.dart';
import 'package:polka_wallet/store/account/types/accountData.dart';
import 'package:polka_wallet/store/app.dart';
import 'package:polka_wallet/utils/UI.dart';
import 'package:polka_wallet/utils/format.dart';
import 'package:polka_wallet/utils/i18n/index.dart';

class InitiateRecoveryPage extends StatefulWidget {
  InitiateRecoveryPage(this.store);
  static final String route = '/profile/recovery/init';
  final AppStore store;

  @override
  _InitiateRecoveryPage createState() => _InitiateRecoveryPage();
}

class _InitiateRecoveryPage extends State<InitiateRecoveryPage> {
  final double _recoveryDeposit = 5 / 6;

  AccountData _recoverable;
  bool _loading = false;

  Future<void> _handleRecoverableSelect() async {
    var res = await Navigator.of(context).pushNamed(ContactListPage.route);
    if (res != null) {
      setState(() {
        _recoverable = res;
      });
    }
  }

  Future<void> _onValidateSubmit() async {
    /// check if balance enough for deposit
    int decimals = widget.store.settings.networkState.tokenDecimals;
    if (!UI.checkBalanceAndAlert(
      context,
      widget.store,
      Fmt.tokenInt(_recoveryDeposit.toString(), decimals),
    )) {
      return;
    }

    /// check if account is recoverable
    setState(() {
      _loading = true;
    });
    Map info = await webApi.account.queryRecoverable(_recoverable.address);
    setState(() {
      _loading = false;
    });
    if (info == null) {
      showCupertinoDialog(
        context: context,
        builder: (BuildContext context) {
          final Map dic = I18n.of(context).profile;
          return CupertinoAlertDialog(
            title: Text(Fmt.address(_recoverable.address)),
            content: Text(dic['recovery.not.recoverable']),
            actions: <Widget>[
              CupertinoButton(
                child: Text(
                  I18n.of(context).home['cancel'],
                  style: TextStyle(
                    color: Theme.of(context).unselectedWidgetColor,
                  ),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    } else {
      _onSubmit();
    }
  }

  void _onSubmit() {
    var args = {
      "title": 'init',
      "txInfo": {
        "module": 'recovery',
        "call": 'initiateRecovery',
      },
      "detail": jsonEncode({
        'accountId': _recoverable.address,
        'deposit':
            '${Fmt.doubleFormat(_recoveryDeposit)} ${widget.store.settings.networkState.tokenSymbol}'
      }),
      "params": [_recoverable.address],
      'onFinish': (BuildContext txPageContext, Map res) {
        Navigator.popUntil(
            txPageContext, ModalRoute.withName('/profile/recovery/state'));
        globalRecoveryStateRefreshKey.currentState.show();
      }
    };
    Navigator.of(context).pushNamed(TxConfirmPage.route, arguments: args);
  }

  @override
  Widget build(BuildContext context) {
    final Map dic = I18n.of(context).profile;
    final String symbol = widget.store.settings.networkState.tokenSymbol;

    return Scaffold(
      appBar: AppBar(
        title: Text(dic['recovery.init']),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Container(
          color: Theme.of(context).cardColor,
          child: Column(
            children: [
              Expanded(
                child: ListView(
                  children: [
                    Padding(
                      padding: EdgeInsets.fromLTRB(16, 16, 16, 0),
                      child: AddressFormItem(
                        widget.store.account.currentAccount,
                        label: dic['recovery.init.new'],
                      ),
                    ),
                    ListTile(
                      title: Text(dic['recovery.init.old']),
                      trailing: Icon(Icons.arrow_forward_ios, size: 18),
                      onTap: () => _handleRecoverableSelect(),
                    ),
                    _recoverable != null
                        ? Padding(
                            padding: EdgeInsets.only(left: 16, right: 16),
                            child: AddressFormItem(
                              _recoverable,
                            ),
                          )
                        : Container(),
                    ListTile(
                      title: Text(dic['recovery.deposit']),
                      trailing: Text(
                        '${Fmt.doubleFormat(_recoveryDeposit)} $symbol',
                        style: Theme.of(context).textTheme.headline4,
                      ),
                    )
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.all(16),
                child: RoundedButton(
                  text: I18n.of(context).home['next'],
                  onPressed: () => _onValidateSubmit(),
                  submitting: _loading,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
