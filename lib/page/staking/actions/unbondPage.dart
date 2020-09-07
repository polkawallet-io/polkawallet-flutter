import 'dart:convert';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:polka_wallet/common/components/addressFormItem.dart';
import 'package:polka_wallet/common/components/roundedButton.dart';
import 'package:polka_wallet/page/account/txConfirmPage.dart';
import 'package:polka_wallet/store/app.dart';
import 'package:polka_wallet/utils/UI.dart';
import 'package:polka_wallet/utils/format.dart';
import 'package:polka_wallet/utils/i18n/index.dart';

class UnBondPage extends StatefulWidget {
  UnBondPage(this.store);
  static final String route = '/staking/unbond';
  final AppStore store;
  @override
  _UnBondPageState createState() => _UnBondPageState(store);
}

class _UnBondPageState extends State<UnBondPage> {
  _UnBondPageState(this.store);
  final AppStore store;

  final _formKey = GlobalKey<FormState>();

  final TextEditingController _amountCtrl = new TextEditingController();

  @override
  Widget build(BuildContext context) {
    var dic = I18n.of(context).staking;
    var assetDic = I18n.of(context).assets;
    String symbol = store.settings.networkState.tokenSymbol;
    int decimals = store.settings.networkState.tokenDecimals;

    double bonded = 0;
    if (store.staking.ownStashInfo != null) {
      bonded = Fmt.bigIntToDouble(
          BigInt.parse(
              store.staking.ownStashInfo.stakingLedger['active'].toString()),
          decimals);
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(dic['action.unbond']),
        centerTitle: true,
      ),
      body: Builder(builder: (BuildContext context) {
        return SafeArea(
          child: Column(
            children: <Widget>[
              Expanded(
                child: Form(
                  key: _formKey,
                  child: ListView(
                    padding: EdgeInsets.all(16),
                    children: <Widget>[
                      AddressFormItem(
                        store.account.currentAccount,
                        label: dic['controller'],
                      ),
                      TextFormField(
                        decoration: InputDecoration(
                          hintText: assetDic['amount'],
                          labelText:
                              '${assetDic['amount']} (${dic['bonded']}: ${Fmt.priceFloor(
                            bonded,
                            lengthMax: 3,
                          )} $symbol)',
                        ),
                        inputFormatters: [UI.decimalInputFormatter(decimals)],
                        controller: _amountCtrl,
                        keyboardType:
                            TextInputType.numberWithOptions(decimal: true),
                        validator: (v) {
                          if (v.isEmpty) {
                            return assetDic['amount.error'];
                          }
                          if (double.parse(v.trim()) > bonded) {
                            return assetDic['amount.low'];
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(16),
                child: RoundedButton(
                  text: I18n.of(context).home['submit.tx'],
                  onPressed: () {
                    if (_formKey.currentState.validate()) {
                      var args = {
                        "title": dic['action.unbond'],
                        "txInfo": {
                          "module": 'staking',
                          "call": 'unbond',
                        },
                        "detail": jsonEncode({
                          "amount": _amountCtrl.text.trim(),
                        }),
                        "params": [
                          // "amount"
                          (double.parse(_amountCtrl.text.trim()) *
                                  pow(10, decimals))
                              .toInt(),
                        ],
                        'onFinish': (BuildContext txPageContext, Map res) {
                          Navigator.popUntil(
                              txPageContext, ModalRoute.withName('/'));
                          globalBondingRefreshKey.currentState.show();
                        }
                      };
                      Navigator.of(context)
                          .pushNamed(TxConfirmPage.route, arguments: args);
                    }
                  },
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}
