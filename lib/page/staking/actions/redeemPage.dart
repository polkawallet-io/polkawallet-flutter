import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:polka_wallet/common/components/addressFormItem.dart';
import 'package:polka_wallet/common/components/roundedButton.dart';
import 'package:polka_wallet/page/account/txConfirmPage.dart';
import 'package:polka_wallet/store/app.dart';
import 'package:polka_wallet/utils/UI.dart';
import 'package:polka_wallet/utils/format.dart';
import 'package:polka_wallet/utils/i18n/index.dart';

class RedeemPage extends StatefulWidget {
  RedeemPage(this.store);
  static final String route = '/staking/redeem';
  final AppStore store;
  @override
  _RedeemPageState createState() => _RedeemPageState(store);
}

class _RedeemPageState extends State<RedeemPage> {
  _RedeemPageState(this.store);
  final AppStore store;

  void _onSubmit() {
    var dic = I18n.of(context).staking;
    final int decimals = store.settings.networkState.tokenDecimals;
    var args = {
      "title": dic['action.redeem'],
      "txInfo": {
        "module": 'staking',
        "call": 'withdrawUnbonded',
      },
      "detail": jsonEncode({
        'amount':
            Fmt.token(store.staking.ledger['redeemable'], length: decimals)
      }),
      "params": [],
      'onFinish': (BuildContext txPageContext, Map res) {
        Navigator.popUntil(txPageContext, ModalRoute.withName('/'));
        globalBondingRefreshKey.currentState.show();
      }
    };

    Navigator.of(context).pushNamed(TxConfirmPage.route, arguments: args);
  }

  @override
  Widget build(BuildContext context) {
    var dic = I18n.of(context).staking;
    final int decimals = store.settings.networkState.tokenDecimals;

    return Scaffold(
      appBar: AppBar(
        title: Text(dic['action.redeem']),
        centerTitle: true,
      ),
      body: Builder(builder: (BuildContext context) {
        return SafeArea(
          child: Column(
            children: <Widget>[
              Expanded(
                child: ListView(
                  padding: EdgeInsets.all(16),
                  children: <Widget>[
                    AddressFormItem(
                      store.account.currentAccount,
                      label: dic['controller'],
                    ),
                    TextFormField(
                      decoration: InputDecoration(
                        hintText: I18n.of(context).assets['amount'],
                        labelText: I18n.of(context).assets['amount'],
                      ),
                      initialValue: Fmt.token(
                          store.staking.ledger['redeemable'],
                          length: decimals),
                      readOnly: true,
                    ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.all(16),
                child: RoundedButton(
                  text: I18n.of(context).home['submit.tx'],
                  onPressed: _onSubmit,
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}
