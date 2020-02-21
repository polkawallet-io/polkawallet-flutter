import 'dart:convert';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:polka_wallet/common/components/roundedButton.dart';
import 'package:polka_wallet/common/regInputFormatter.dart';
import 'package:polka_wallet/store/app.dart';
import 'package:polka_wallet/utils/format.dart';
import 'package:polka_wallet/utils/i18n/index.dart';

class Transfer extends StatefulWidget {
  const Transfer(this.store);

  final AppStore store;

  @override
  _TransferState createState() => _TransferState(store);
}

class _TransferState extends State<Transfer> {
  _TransferState(this.store);

  final AppStore store;

  final _formKey = GlobalKey<FormState>();

  final TextEditingController _addressCtrl = new TextEditingController();
  final TextEditingController _amountCtrl = new TextEditingController();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final String args = ModalRoute.of(context).settings.arguments;
    if (args != null) {
      setState(() {
        _addressCtrl.text = args;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final Map<String, String> dic = I18n.of(context).assets;
    String symbol = store.settings.networkState.tokenSymbol;
    int decimals = store.settings.networkState.tokenDecimals;

    int balance = Fmt.balanceInt(store.assets.balance);
    int available = balance;
    bool hasStakingData = store.staking.ledger['stakingLedger'] != null;
    if (hasStakingData) {
      int bonded = store.staking.ledger['stakingLedger']['active'];
      int unlocking = 0;
      List unlockingList = store.staking.ledger['stakingLedger']['unlocking'];
      unlockingList.forEach((i) => unlocking += i['value']);
      available = balance - bonded - unlocking;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('${dic['transfer']} $symbol'),
        centerTitle: true,
        actions: <Widget>[
          IconButton(
            icon: Image.asset('assets/images/assets/Menu_scan.png'),
            onPressed: () async {
              var to = await Navigator.of(context).pushNamed('/account/scan');
              setState(() {
                _addressCtrl.text = to;
              });
            },
          )
        ],
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
                            hintText: dic['address'],
                            labelText: dic['address'],
                            suffix: IconButton(
                              icon: Image.asset(
                                  'assets/images/profile/address.png'),
                              onPressed: () async {
                                var to = await Navigator.of(context)
                                    .pushNamed('/contacts/list');
                                setState(() {
                                  _addressCtrl.text = to;
                                });
                              },
                            )),
                        controller: _addressCtrl,
                        validator: (v) {
                          return Fmt.isAddress(v.trim())
                              ? null
                              : dic['address.error'];
                        },
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(16),
                      child: TextFormField(
                        decoration: InputDecoration(
                          hintText: dic['amount'],
                          labelText:
                              '${dic['amount']} (${dic['balance']}: ${Fmt.token(available)})',
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
                            return dic['amount.error'];
                          }
                          if (double.parse(v.trim()) >=
                              available / pow(10, decimals) - 0.02) {
                            return dic['amount.low'];
                          }
                          return null;
                        },
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.fromLTRB(16, 16, 16, 0),
                      child: Text(
                          'TransferFee: ${store.settings.transferFeeView} $symbol',
                          style:
                              TextStyle(fontSize: 16, color: Colors.black54)),
                    ),
                    Padding(
                      padding: EdgeInsets.all(16),
                      child: Text(
                          'CreationFee: ${store.settings.creationFeeView} $symbol',
                          style:
                              TextStyle(fontSize: 16, color: Colors.black54)),
                    ),
                  ],
                ),
              ),
            ),
            Container(
              padding: EdgeInsets.fromLTRB(16, 8, 16, 32),
              child: RoundedButton(
                text: I18n.of(context).assets['make'],
                onPressed: () {
                  if (_formKey.currentState.validate()) {
                    var args = {
                      "title": I18n.of(context).assets['transfer'],
                      "detail": jsonEncode({
                        "amount": _amountCtrl.text.trim(),
                        "destination": _addressCtrl.text.trim(),
                      }),
                      "params": {
                        "module": 'balances',
                        "call": 'transfer',
                        "amount": (double.parse(_amountCtrl.text.trim()) *
                                pow(10, decimals))
                            .toInt(),
                        "to": _addressCtrl.text.trim(),
                      },
                      'redirect': '/assets/detail'
                    };
                    Navigator.of(context)
                        .pushNamed('/staking/confirm', arguments: args);
                  }
                },
              ),
            )
          ],
        );
      }),
    );
  }
}
