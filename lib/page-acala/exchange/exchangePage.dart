import 'dart:convert';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:polka_wallet/common/components/currencyWithIcon.dart';
import 'package:polka_wallet/common/components/roundedButton.dart';
import 'package:polka_wallet/common/components/roundedCard.dart';
import 'package:polka_wallet/common/regInputFormatter.dart';
import 'package:polka_wallet/page-acala/homePage.dart';
import 'package:polka_wallet/page/account/txConfirmPage.dart';
import 'package:polka_wallet/page/assets/transfer/currencySelectPage.dart';
import 'package:polka_wallet/service/substrateApi/api.dart';
import 'package:polka_wallet/store/app.dart';
import 'package:polka_wallet/utils/UI.dart';
import 'package:polka_wallet/utils/format.dart';
import 'package:polka_wallet/utils/i18n/index.dart';

class ExchangePage extends StatefulWidget {
  ExchangePage(this.store);

  static const String route = '/acala/dex';
  final AppStore store;

  @override
  _ExchangePageState createState() => _ExchangePageState(store);
}

class _ExchangePageState extends State<ExchangePage> {
  _ExchangePageState(this.store);

  final AppStore store;

  final _formKey = GlobalKey<FormState>();
  final TextEditingController _amountPayCtrl = new TextEditingController();
  final TextEditingController _amountReceiveCtrl = new TextEditingController();

  String _currencyPay;
  String _currencyReceive;

  Future<void> _refreshData() async {
    String pubKey = store.account.currentAccount.pubKey;
    webApi.assets.fetchBalance(pubKey);
    webApi.acala.fetchTokens(pubKey);
    // then fetch txs history
  }

  void _switchPair() {
    List currencyIds = store.settings.networkConst['currencyIds'];
    String pay = _currencyPay ?? currencyIds[1];
    String receive = _currencyReceive ?? currencyIds[2];
    setState(() {
      _currencyPay = receive;
      _currencyReceive = pay;
    });
  }

  Future<void> _selectCurrencyPay() async {
    List<String> currencyOptions =
        List<String>.from(store.settings.networkConst['currencyIds'])
            .sublist(1);
    currencyOptions.retainWhere((i) =>
        i != (_currencyPay ?? currencyOptions[0]) &&
        i != (_currencyReceive ?? currencyOptions[1]));
    var selected = await Navigator.of(context)
        .pushNamed(CurrencySelectPage.route, arguments: currencyOptions);
    if (selected != null) {
      setState(() {
        _currencyPay = selected;
      });
    }
  }

  Future<void> _selectCurrencyReceive() async {
    List<String> currencyOptions =
        List<String>.from(store.settings.networkConst['currencyIds'])
            .sublist(1);
    currencyOptions.retainWhere((i) =>
        i != (_currencyPay ?? currencyOptions[0]) &&
        i != (_currencyReceive ?? currencyOptions[1]));
    var selected = await Navigator.of(context)
        .pushNamed(CurrencySelectPage.route, arguments: currencyOptions);
    if (selected != null) {
      setState(() {
        _currencyReceive = selected;
      });
    }
  }

  void _onSubmit() {
    if (_formKey.currentState.validate()) {
      int decimals = store.settings.networkState.tokenDecimals;
      List currencyIds = store.settings.networkConst['currencyIds'];
      String pay = _amountPayCtrl.text.trim();
      String receive = _amountReceiveCtrl.text.trim();
      var args = {
        "title": I18n.of(context).acala['dex.exchange'],
        "txInfo": {
          "module": 'dex',
          "call": 'swapCurrency',
        },
        "detail": jsonEncode({
          "currencyPay": _currencyPay ?? currencyIds[1],
          "amountPay": pay,
          "currencyReceive": _currencyReceive ?? currencyIds[2],
          "amountReceive": receive,
        }),
        "params": [
          // params.supply
          [
            _currencyPay ?? currencyIds[1],
            (double.parse(pay) * pow(10, decimals)).toStringAsFixed(0)
          ],
          // params.target
          [
            _currencyReceive ?? currencyIds[2],
            (double.parse(receive) * pow(10, decimals)).toStringAsFixed(0)
          ],
        ],
        "onFinish": (BuildContext txPageContext) {
          Navigator.popUntil(
              txPageContext, ModalRoute.withName(AcalaHomePage.route));
          globalDexRefreshKey.currentState.show();
        }
      };
      Navigator.of(context).pushNamed(TxConfirmPage.route, arguments: args);
    }
  }

  @override
  void initState() {
    super.initState();
    List currencyIds = store.settings.networkConst['currencyIds'];
    if (currencyIds != null && _currencyPay == null) {
      setState(() {
        _currencyPay = currencyIds[1];
        _currencyReceive = currencyIds[2];
      });
    }
  }

  @override
  void dispose() {
    _amountPayCtrl.dispose();
    _amountReceiveCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(_) {
    return Observer(
      builder: (BuildContext context) {
        final Map dic = I18n.of(context).acala;
        final Map dicAssets = I18n.of(context).assets;
        int decimals = store.settings.networkState.tokenDecimals;
        List currencyIds = store.settings.networkConst['currencyIds'];

        final double inputWidth = MediaQuery.of(context).size.width / 3;

        BigInt balance = BigInt.zero;
        if (currencyIds != null &&
            store.assets.balances[_currencyPay ?? currencyIds[1]] != null) {
          balance = Fmt.balanceInt(
              store.assets.balances[_currencyPay ?? currencyIds[1]]);
        }

        double rate = 0.00463;

        return Scaffold(
          appBar: AppBar(title: Text(dic['dex.title']), centerTitle: true),
          body: SafeArea(
            child: RefreshIndicator(
              key: globalAssetRefreshKey,
              onRefresh: _refreshData,
              child: ListView(
                padding: EdgeInsets.all(16),
                children: <Widget>[
                  RoundedCard(
                    padding: EdgeInsets.all(16),
                    child: currencyIds != null
                        ? Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  GestureDetector(
                                    child: CurrencyWithIcon(
                                      _currencyPay ?? currencyIds[1],
                                      textWidth: 48,
                                      textStyle:
                                          Theme.of(context).textTheme.display4,
                                      trailing: Icon(Icons.keyboard_arrow_down),
                                    ),
                                    onTap: () => _selectCurrencyPay(),
                                  ),
                                  IconButton(
                                    icon: Icon(
                                      Icons.repeat,
                                      color: Theme.of(context).primaryColor,
                                    ),
                                    onPressed: _switchPair,
                                  ),
                                  GestureDetector(
                                    child: CurrencyWithIcon(
                                      _currencyReceive ?? currencyIds[2],
                                      textWidth: 48,
                                      textStyle:
                                          Theme.of(context).textTheme.display4,
                                      trailing: Icon(Icons.keyboard_arrow_down),
                                    ),
                                    onTap: () => _selectCurrencyReceive(),
                                  )
                                ],
                              ),
                              Form(
                                key: _formKey,
                                autovalidate: true,
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Container(
                                      width: inputWidth,
                                      child: TextFormField(
                                        decoration: InputDecoration(
                                          hintText: dic['dex.pay'],
                                          labelText: dic['dex.pay'],
                                        ),
                                        inputFormatters: [
                                          RegExInputFormatter.withRegex(
                                              '^[0-9]{0,6}(\\.[0-9]{0,$decimals})?\$')
                                        ],
                                        controller: _amountPayCtrl,
                                        keyboardType:
                                            TextInputType.numberWithOptions(
                                                decimal: true),
                                        validator: (v) {
                                          if (v.isEmpty) {
                                            return dicAssets['amount.error'];
                                          }
                                          if (double.parse(v.trim()) >=
                                              balance /
                                                      BigInt.from(
                                                          pow(10, decimals)) -
                                                  0.02) {
                                            return dicAssets['amount.low'];
                                          }
                                          return null;
                                        },
                                      ),
                                    ),
                                    Container(
                                      width: inputWidth,
                                      child: TextFormField(
                                        decoration: InputDecoration(
                                          hintText: dic['dex.receive'],
                                          labelText: dic['dex.receive'],
                                        ),
                                        inputFormatters: [
                                          RegExInputFormatter.withRegex(
                                              '^[0-9]{0,6}(\\.[0-9]{0,$decimals})?\$')
                                        ],
                                        controller: _amountReceiveCtrl,
                                        keyboardType:
                                            TextInputType.numberWithOptions(
                                                decimal: true),
                                        validator: (v) {
                                          if (v.isEmpty) {
                                            return dicAssets['amount.error'];
                                          }
                                          // check if pool has sufficient assets
//                                    if (true) {
//                                      return dicAssets['amount.low'];
//                                    }
                                          return null;
                                        },
                                      ),
                                    )
                                  ],
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.only(top: 8),
                                child: Text(
                                  '${dicAssets['balance']}: ${Fmt.token(balance, decimals: decimals)} ${_currencyPay ?? currencyIds[1]}',
                                  style: TextStyle(
                                      color: Theme.of(context)
                                          .unselectedWidgetColor),
                                ),
                              ),
                              Divider(),
                              Text(
                                dic['dex.rate'],
                                style: TextStyle(
                                    color: Theme.of(context)
                                        .unselectedWidgetColor),
                              ),
                              Text(
                                  '1 ${_currencyPay ?? currencyIds[1]} = $rate ${_currencyReceive ?? currencyIds[2]}'),
                            ],
                          )
                        : CupertinoActivityIndicator(),
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 24),
                    child: RoundedButton(
                      text: dic['dex.exchange'],
                      onPressed: _onSubmit,
                    ),
                  )
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
