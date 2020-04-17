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

class SwapPage extends StatefulWidget {
  SwapPage(this.store);

  static const String route = '/acala/dex';
  final AppStore store;

  @override
  _SwapPageState createState() => _SwapPageState(store);
}

class _SwapPageState extends State<SwapPage> {
  _SwapPageState(this.store);

  final AppStore store;

  final _formKey = GlobalKey<FormState>();
  final TextEditingController _amountPayCtrl = new TextEditingController();
  final TextEditingController _amountReceiveCtrl = new TextEditingController();
  final TextEditingController _amountSlippageCtrl = new TextEditingController();

  final FocusNode _slippageFocusNode = FocusNode();

  String _slippage = '0.005';

  Future<void> _refreshData() async {
    String pubKey = store.account.currentAccount.pubKey;
    webApi.assets.fetchBalance(pubKey);
    webApi.acala.fetchTokens(pubKey);
    webApi.acala.fetchTokenSwapRatio();

    // then fetch txs history
  }

  Future<void> _switchPair() async {
    List<String> swapPair = store.acala.currentSwapPair.toList();
    store.acala.setSwapPair([swapPair[1], swapPair[0]]);
    _refreshData();
    _onSupplyAmountChange(_amountPayCtrl.text);
  }

  Future<void> _selectCurrencyPay() async {
    List<String> swapPair = store.acala.currentSwapPair;
    List<String> currencyOptions =
        List<String>.from(store.settings.networkConst['currencyIds'])
            .sublist(1);
    currencyOptions.retainWhere((i) => i != swapPair[0] && i != swapPair[1]);
    var selected = await Navigator.of(context)
        .pushNamed(CurrencySelectPage.route, arguments: currencyOptions);
    if (selected != null) {
      store.acala.setSwapPair([selected, swapPair[1]]);
      _refreshData();
    }
  }

  Future<void> _selectCurrencyReceive() async {
    List<String> swapPair = store.acala.currentSwapPair;
    List<String> currencyOptions =
        List<String>.from(store.settings.networkConst['currencyIds'])
            .sublist(1);
    currencyOptions.retainWhere((i) => i != swapPair[0] && i != swapPair[1]);
    var selected = await Navigator.of(context)
        .pushNamed(CurrencySelectPage.route, arguments: currencyOptions);
    if (selected != null) {
      store.acala.setSwapPair([swapPair[0], selected]);
      _refreshData();
    }
  }

  void _onSupplyAmountChange(String v) {
    String supply = v.trim();
    if (supply.isEmpty) {
      return;
    }
    _calcSwapAmount(supply, null);
  }

  void _onTargetAmountChange(String v) {
    String target = v.trim();
    if (target.isEmpty) {
      return;
    }
    _calcSwapAmount(null, target);
  }

  Future<void> _calcSwapAmount(String supply, String target) async {
    String output =
        await webApi.acala.fetchTokenSwapAmount(supply, target, '0');
    if (supply == null) {
      setState(() {
        _amountPayCtrl.text = output;
      });
    } else if (target == null) {
      setState(() {
        _amountReceiveCtrl.text = output;
      });
    }
  }

  void _onSubmit() {
    if (_formKey.currentState.validate()) {
      int decimals = store.settings.networkState.tokenDecimals;
      List<String> swapPair = store.acala.currentSwapPair;
      String pay = _amountPayCtrl.text.trim();
      String receive = _amountReceiveCtrl.text.trim();
      var args = {
        "title": I18n.of(context).acala['dex.exchange'],
        "txInfo": {
          "module": 'dex',
          "call": 'swapCurrency',
        },
        "detail": jsonEncode({
          "currencyPay": swapPair[0],
          "amountPay": pay,
          "currencyReceive": swapPair[1],
          "amountReceive": receive,
        }),
        "params": [
          // params.supply
          [
            swapPair[0],
            (double.parse(pay) * pow(10, decimals)).toStringAsFixed(0)
          ],
          // params.target
          [
            swapPair[1],
            (double.parse(receive) * pow(10, decimals)).toStringAsFixed(0)
          ],
        ],
        "onFinish": (BuildContext txPageContext, Map res) {
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
    if (currencyIds != null) {
      store.acala.setSwapPair(currencyIds.sublist(1, 3).reversed.toList());
      _refreshData();
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
        List swapPair = store.acala.currentSwapPair.toList();

        final double inputWidth = MediaQuery.of(context).size.width / 3;

        BigInt balance = BigInt.zero;
        if (currencyIds != null && swapPair.length > 0) {
          balance = Fmt.balanceInt(store.assets.balances[swapPair[0]]);
        }

        Color primary = Theme.of(context).primaryColor;
        Color grey = Theme.of(context).unselectedWidgetColor;
        Color lightGrey = Theme.of(context).dividerColor;

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
                    child: swapPair.length == 2
                        ? Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  GestureDetector(
                                    child: CurrencyWithIcon(
                                      swapPair[0],
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
                                    onPressed: () => _switchPair(),
                                  ),
                                  GestureDetector(
                                    child: CurrencyWithIcon(
                                      swapPair[1],
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
                                        onChanged: _onSupplyAmountChange,
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
                                        onChanged: _onTargetAmountChange,
                                      ),
                                    )
                                  ],
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.only(top: 8),
                                child: Text(
                                  '${dicAssets['balance']}: ${Fmt.token(balance, decimals: decimals)} ${swapPair[0]}',
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
                                  '1 ${swapPair[0]} = ${store.acala.swapRatio} ${swapPair[1]}'),
                            ],
                          )
                        : CupertinoActivityIndicator(),
                  ),
                  RoundedCard(
                    margin: EdgeInsets.only(top: 16),
                    padding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Container(
                          margin: EdgeInsets.only(bottom: 4),
                          child: Text(
                            dic['dex.rate'],
                            style: TextStyle(
                                color: Theme.of(context).unselectedWidgetColor),
                          ),
                        ),
                        Row(
                          children: <Widget>[
                            _SlippageButton(
                              content: '0.1 %',
                              active: _slippage == '0.001',
                              onPressed: () {
                                _slippageFocusNode.unfocus();
                                setState(() {
                                  _amountSlippageCtrl.text = '';
                                  _slippage = '0.001';
                                });
                              },
                            ),
                            _SlippageButton(
                              content: '0.5 %',
                              active: _slippage == '0.005',
                              onPressed: () {
                                _slippageFocusNode.unfocus();
                                setState(() {
                                  _amountSlippageCtrl.text = '';
                                  _slippage = '0.005';
                                });
                              },
                            ),
                            _SlippageButton(
                              content: '1 %',
                              active: _slippage == '0.01',
                              onPressed: () {
                                _slippageFocusNode.unfocus();
                                setState(() {
                                  _amountSlippageCtrl.text = '';
                                  _slippage = '0.01';
                                });
                              },
                            ),
                            Expanded(
                              child: CupertinoTextField(
                                padding: EdgeInsets.fromLTRB(12, 4, 12, 4),
                                placeholder: 'customized',
                                inputFormatters: [
                                  RegExInputFormatter.withRegex(
                                      '^[0-9]{0,6}(\\.[0-9]{0,$decimals})?\$')
                                ],
                                decoration: BoxDecoration(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(24)),
                                  border: Border.all(
                                      width: 0.5,
                                      color: _slippageFocusNode.hasFocus
                                          ? primary
                                          : grey),
                                ),
                                controller: _amountSlippageCtrl,
                                focusNode: _slippageFocusNode,
                                onChanged: (v) {
                                  setState(() {
                                    _slippage = v.trim();
                                  });
                                },
                                suffix: Container(
                                  padding: EdgeInsets.only(right: 8),
                                  child: Text(
                                    '%',
                                    style: TextStyle(
                                        color: _slippageFocusNode.hasFocus
                                            ? primary
                                            : grey),
                                  ),
                                ),
                              ),
                            )
                          ],
                        ),
                      ],
                    ),
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

class _SlippageButton extends StatelessWidget {
  _SlippageButton({this.content, this.active, this.onPressed});
  final String content;
  final bool active;
  final Function onPressed;
  @override
  Widget build(BuildContext context) {
    Color primary = Theme.of(context).primaryColor;
    Color grey = Theme.of(context).unselectedWidgetColor;
    Color white = Theme.of(context).cardColor;
    return GestureDetector(
      child: Container(
        margin: EdgeInsets.only(right: 8),
        padding: EdgeInsets.fromLTRB(12, 4, 12, 4),
        decoration: BoxDecoration(
          color: active ? primary : white,
          border: Border.all(color: active ? primary : grey),
          borderRadius: BorderRadius.all(Radius.circular(16)),
        ),
        child: Text(content, style: TextStyle(color: active ? white : grey)),
      ),
      onTap: onPressed,
    );
  }
}
