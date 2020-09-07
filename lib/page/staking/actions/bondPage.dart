import 'dart:convert';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:polka_wallet/common/components/addressFormItem.dart';
import 'package:polka_wallet/common/components/roundedButton.dart';
import 'package:polka_wallet/page/account/txConfirmPage.dart';
import 'package:polka_wallet/page/staking/actions/accountSelectPage.dart';
import 'package:polka_wallet/store/account/types/accountData.dart';
import 'package:polka_wallet/store/app.dart';
import 'package:polka_wallet/utils/UI.dart';
import 'package:polka_wallet/utils/format.dart';
import 'package:polka_wallet/utils/i18n/index.dart';

class BondPage extends StatefulWidget {
  BondPage(this.store);
  static final String route = '/staking/bond';
  final AppStore store;
  @override
  _BondPageState createState() => _BondPageState(store);
}

class _BondPageState extends State<BondPage> {
  _BondPageState(this.store);
  final AppStore store;

  final _formKey = GlobalKey<FormState>();
  final TextEditingController _amountCtrl = new TextEditingController();

  final _rewardToOptions = ['Staked', 'Stash', 'Controller'];

  AccountData _controller;

  int _rewardTo = 0;

  void _onSubmit() {
    var dic = I18n.of(context).staking;
    var rewardToOptions =
        _rewardToOptions.map((i) => dic['reward.$i']).toList();
    int decimals = store.settings.networkState.tokenDecimals;
    if (_formKey.currentState.validate()) {
      String controllerId = store.account.currentAddress;
      if (_controller != null) {
        controllerId = store.account
            .pubKeyAddressMap[store.settings.endpoint.info][_controller.pubKey];
      }

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
          // "controllerId":
          controllerId,
          // "amount":
          (double.parse(_amountCtrl.text.trim()) * pow(10, decimals)).toInt(),
          // "to"
          _rewardTo,
        ],
        'onFinish': (BuildContext txPageContext, Map res) {
          Navigator.popUntil(txPageContext, ModalRoute.withName('/'));
          globalBondingRefreshKey.currentState.show();
        }
      };
      Navigator.of(context).pushNamed(TxConfirmPage.route, arguments: args);
    }
  }

  Future<void> _changeControllerId(BuildContext context) async {
    var acc = await Navigator.of(context).pushNamed(AccountSelectPage.route);
    if (acc != null) {
      setState(() {
        _controller = acc;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    var dic = I18n.of(context).staking;
    var assetDic = I18n.of(context).assets;
    String symbol = store.settings.networkState.tokenSymbol;
    int decimals = store.settings.networkState.tokenDecimals;

    double available = 0;
    if (store.assets.balances[symbol] != null) {
      available = Fmt.bigIntToDouble(
          store.assets.balances[symbol].transferable, decimals);
    }

    var rewardToOptions =
        _rewardToOptions.map((i) => dic['reward.$i']).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(dic['action.bond']),
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
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.only(left: 16, right: 16, top: 8),
                        child: AddressFormItem(
                          store.account.currentAccount,
                          label: dic['stash'],
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(left: 16, right: 16),
                        child: AddressFormItem(
                          _controller ?? store.account.currentAccount,
                          label: dic['controller'],
                          onTap: () => _changeControllerId(context),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(left: 16, right: 16),
                        child: TextFormField(
                          decoration: InputDecoration(
                            hintText: assetDic['amount'],
                            labelText:
                                '${assetDic['amount']} (${dic['balance']}: ${Fmt.priceFloor(
                              available,
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
                            if (double.parse(v.trim()) >= available) {
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
                              height: MediaQuery.of(context)
                                      .copyWith()
                                      .size
                                      .height /
                                  3,
                              child: CupertinoPicker(
                                backgroundColor: Colors.white,
                                itemExtent: 56,
                                scrollController: FixedExtentScrollController(
                                    initialItem: _rewardTo),
                                children: rewardToOptions
                                    .map((i) => Padding(
                                        padding: EdgeInsets.all(12),
                                        child: Text(
                                          i,
                                          style: TextStyle(fontSize: 16),
                                        )))
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
