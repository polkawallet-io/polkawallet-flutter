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

class Bond extends StatefulWidget {
  Bond(this.store);
  final AppStore store;
  @override
  _BondState createState() => _BondState(store);
}

class _BondState extends State<Bond> {
  _BondState(this.store);
  final AppStore store;

  final _formKey = GlobalKey<FormState>();

  final TextEditingController _amountCtrl = new TextEditingController();

  int _rewardTo = 0;

  @override
  Widget build(BuildContext context) {
    var dic = I18n.of(context).staking;
    var assetDic = I18n.of(context).assets;
    String symbol = store.settings.networkState.tokenSymbol;
    int decimals = store.settings.networkState.tokenDecimals;

    String balance = Fmt.balance(store.assets.balance);
    String address = store.account.currentAddress;

    var rewardToOptions = [dic['reward.bond'], dic['reward.stash']];

    return Scaffold(
      appBar: AppBar(
        title: Text(dic['action.bond']),
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
                              '${assetDic['amount']} (${dic['balance']}: $balance $symbol)',
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
                              double.parse(balance) - 0.02) {
                            return assetDic['amount.low'];
                          }
                          return null;
                        },
                      ),
                    ),
                    ListTile(
                      title: Text(dic['bond.reward']),
                      subtitle: Text(rewardToOptions[_rewardTo]),
                      trailing: Icon(Icons.arrow_forward_ios, size: 18),
                      onTap: () {
                        showCupertinoModalPopup(
                          context: context,
                          builder: (_) => Container(
                            height:
                                MediaQuery.of(context).copyWith().size.height /
                                    3,
                            child: CupertinoPicker(
                              backgroundColor: Colors.white,
                              itemExtent: 56,
                              scrollController: FixedExtentScrollController(
                                  initialItem: _rewardTo),
                              children: rewardToOptions
                                  .map((i) => Padding(
                                      padding: EdgeInsets.all(12),
                                      child: Text(i)))
                                  .toList(),
                              onSelectedItemChanged: (v) {
                                setState(() {
                                  _rewardTo = v;
                                });
                              },
                            ),
                          ),
                        );
                      },
                    )
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
                      "title": dic['action.bond'],
                      "txInfo": {
                        "module": 'staking',
                        "call": 'bond',
                      },
                      "detail": jsonEncode({
                        "amount": _amountCtrl.text.trim(),
                        "reward_destination": rewardToOptions[_rewardTo],
                      }),
                      "params": [
                        // "from":
                        store.account.currentAddress,
                        // "amount":
                        (double.parse(_amountCtrl.text.trim()) *
                                pow(10, decimals))
                            .toInt(),
                        // "to"
                        _rewardTo,
                      ],
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
