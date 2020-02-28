import 'dart:convert';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:polka_wallet/common/components/roundedButton.dart';
import 'package:polka_wallet/common/regInputFormatter.dart';
import 'package:polka_wallet/store/app.dart';
import 'package:polka_wallet/utils/UI.dart';
import 'package:polka_wallet/utils/format.dart';
import 'package:polka_wallet/utils/i18n/index.dart';

class BondExtra extends StatefulWidget {
  BondExtra(this.store);
  final AppStore store;
  @override
  _BondExtraState createState() => _BondExtraState(store);
}

class _BondExtraState extends State<BondExtra> {
  _BondExtraState(this.store);
  final AppStore store;

  final _formKey = GlobalKey<FormState>();

  final TextEditingController _amountCtrl = new TextEditingController();

  @override
  Widget build(BuildContext context) {
    var dic = I18n.of(context).staking;
    var assetDic = I18n.of(context).assets;
    String symbol = store.settings.networkState.tokenSymbol;
    int decimals = store.settings.networkState.tokenDecimals;

    int balance = Fmt.balanceInt(store.assets.balance);
    int bonded = store.staking.ledger['stakingLedger']['active'];
    int unlocking = 0;
    List unlockingList = store.staking.ledger['stakingLedger']['unlocking'];
    unlockingList.forEach((i) => unlocking += i['value']);
    int available = balance - bonded - unlocking;
    String address = store.account.currentAccount.address;

    return Scaffold(
      appBar: AppBar(
        title: Text(dic['action.bondExtra']),
        centerTitle: true,
      ),
      body: Builder(builder: (BuildContext context) {
        return Column(
          children: <Widget>[
            Expanded(
              child: Form(
                key: _formKey,
                child: ListView(
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.all(16),
                      child: TextFormField(
                        decoration: InputDecoration(
                          hintText: dic['stash'],
                          labelText: dic['stash'],
                        ),
                        initialValue: address,
                        readOnly: true,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(16),
                      child: TextFormField(
                        decoration: InputDecoration(
                          hintText: dic['controller'],
                          labelText: dic['controller'],
                        ),
                        initialValue: address,
                        readOnly: true,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(16),
                      child: TextFormField(
                        decoration: InputDecoration(
                          hintText: assetDic['amount'],
                          labelText:
                              '${assetDic['amount']} (${dic['available']}: ${Fmt.token(available)} $symbol)',
                        ),
                        inputFormatters: [
                          RegExInputFormatter.withRegex(
                              '^[0-9]{0,6}(\\.[0-9]{0,$decimals})?\$')
                        ],
                        controller: _amountCtrl,
                        keyboardType:
                            TextInputType.numberWithOptions(decimal: true),
                        validator: (v) {
                          if (v.isEmpty) {
                            return assetDic['amount.error'];
                          }
                          if (double.parse(v.trim()) >=
                              available / pow(10, decimals) - 0.02) {
                            return assetDic['amount.low'];
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(16, 8, 16, 32),
              child: RoundedButton(
                text: I18n.of(context).home['submit.tx'],
                onPressed: () {
                  if (_formKey.currentState.validate()) {
                    var args = {
                      "title": dic['action.bondExtra'],
                      "detail": jsonEncode({
                        "amount": _amountCtrl.text.trim(),
                      }),
                      "params": {
                        "module": 'staking',
                        "call": 'bondExtra',
                        "amount": (double.parse(_amountCtrl.text.trim()) *
                                pow(10, decimals))
                            .toInt(),
                      },
                      'onFinish': (BuildContext txPageContext) {
                        Navigator.popUntil(
                            txPageContext, ModalRoute.withName('/'));
                        globalBondingRefreshKey.currentState.show();
                      }
                    };
                    Navigator.of(context)
                        .pushNamed('/staking/confirm', arguments: args);
                  }
                },
              ),
            ),
          ],
        );
      }),
    );
  }
}
