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

class PayoutPage extends StatefulWidget {
  PayoutPage(this.store);
  static final String route = '/staking/payout';
  final AppStore store;
  @override
  _PayoutPageState createState() => _PayoutPageState(store);
}

class _PayoutPageState extends State<PayoutPage> {
  _PayoutPageState(this.store);
  final AppStore store;

  void _onSubmit() {
    var dic = I18n.of(context).staking;

    List rewards = store.staking.ledger['rewards'];
    if (rewards.length == 1) {
      var args = {
        "title": dic['action.payout'],
        "txInfo": {
          "module": 'staking',
          "call": 'payoutNominator',
        },
        "detail": jsonEncode({
          'amount':
              Fmt.token(store.staking.accountRewardTotal, fullLength: true),
          'era': rewards[0]['era'],
          'nominating': rewards[0]['nominating'],
        }),
        "params": [
          // era
          rewards[0]['era'],
          // nominating
          jsonEncode(rewards[0]['nominating']),
        ],
        'onFinish': (BuildContext txPageContext) {
          Navigator.popUntil(txPageContext, ModalRoute.withName('/'));
          globalBondingRefreshKey.currentState.show();
        }
      };
      Navigator.of(context).pushNamed(TxConfirmPage.route, arguments: args);
      return;
    }

    var params = rewards
        .map((i) =>
            'api.tx.staking.payoutNominator(${i['era']}, ${jsonEncode(i['nominating'])})')
        .toList()
        .join(',');
    var args = {
      "title": dic['action.payout'],
      "txInfo": {
        "module": 'utility',
        "call": 'batch',
      },
      "detail": jsonEncode({
        'amount': Fmt.token(store.staking.accountRewardTotal, fullLength: true),
        'txs': rewards
            .map((i) => {'era': i['era'], 'nominating': i['nominating']})
            .toList(),
      }),
      "params": [],
      "rawParam": '[[$params]]',
      'onFinish': (BuildContext txPageContext) {
        Navigator.popUntil(txPageContext, ModalRoute.withName('/'));
        globalBondingRefreshKey.currentState.show();
      }
    };
    print(args['rawParam']);
    Navigator.of(context).pushNamed(TxConfirmPage.route, arguments: args);
  }

  @override
  Widget build(BuildContext context) {
    var dic = I18n.of(context).staking;
    String address = store.account.currentAddress;

    return Scaffold(
      appBar: AppBar(
        title: Text(dic['action.payout']),
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
                      dic['controller'],
                      store.account.currentAccount.name,
                      address,
                    ),
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: I18n.of(context).assets['amount'],
                      ),
                      initialValue: Fmt.token(store.staking.accountRewardTotal,
                          fullLength: true),
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
