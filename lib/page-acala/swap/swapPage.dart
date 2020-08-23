import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:polka_wallet/common/components/currencyWithIcon.dart';
import 'package:polka_wallet/common/components/outlinedButtonSmall.dart';
import 'package:polka_wallet/common/components/roundedButton.dart';
import 'package:polka_wallet/common/components/roundedCard.dart';
import 'package:polka_wallet/common/consts/settings.dart';
import 'package:polka_wallet/page-acala/swap/swapHistoryPage.dart';
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

  final GlobalKey<RefreshIndicatorState> _refreshKey =
      new GlobalKey<RefreshIndicatorState>();

  final _formKey = GlobalKey<FormState>();
  final TextEditingController _amountPayCtrl = new TextEditingController();
  final TextEditingController _amountReceiveCtrl = new TextEditingController();
  final TextEditingController _amountSlippageCtrl = new TextEditingController();

  final FocusNode _slippageFocusNode = FocusNode();

  double _slippage = 0.005;
  String _slippageError;
  List<String> _swapPair = [];
  double _swapRatio = 0;

  Future<void> _refreshData() async {
    webApi.assets.fetchBalance();
  }

  Future<void> _switchPair() async {
    setState(() {
      _swapPair = [_swapPair[1], _swapPair[0]];
    });
    await _calcSwapAmount(_amountPayCtrl.text.trim(), null);
    _refreshData();
  }

  Future<void> _selectCurrencyPay() async {
    List<String> currencyOptions = List<String>.of(store.acala.swapTokens);
    currencyOptions.add(acala_stable_coin_view);
    currencyOptions.retainWhere((i) => i != _swapPair[0] && i != _swapPair[1]);
    var selected = await Navigator.of(context)
        .pushNamed(CurrencySelectPage.route, arguments: currencyOptions);
    if (selected != null) {
      setState(() {
        _swapPair = [selected, _swapPair[1]];
      });
      await _calcSwapAmount(_amountPayCtrl.text, null);
      _refreshData();
    }
  }

  Future<void> _selectCurrencyReceive() async {
    List<String> currencyOptions = List<String>.of(store.acala.swapTokens);
    currencyOptions.add(acala_stable_coin_view);
    currencyOptions.retainWhere((i) => i != _swapPair[0] && i != _swapPair[1]);
    var selected = await Navigator.of(context)
        .pushNamed(CurrencySelectPage.route, arguments: currencyOptions);
    if (selected != null) {
      setState(() {
        _swapPair = [_swapPair[0], selected];
      });
      await _calcSwapAmount(_amountPayCtrl.text, null);
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

  Future<void> _calcSwapAmount(
    String supply,
    String target, {
    bool init = false,
  }) async {
    if (supply == null) {
      if (target.isNotEmpty) {
        String output = await webApi.acala.fetchTokenSwapAmount(
            supply, target, _swapPair, _slippage.toString());
        setState(() {
          if (!init) {
            _amountPayCtrl.text = output;
          }
          _swapRatio = double.parse(target) / double.parse(output);
        });
        if (!init) {
          _formKey.currentState.validate();
        }
      }
    } else if (target == null) {
      if (supply.isNotEmpty) {
        String output = await webApi.acala.fetchTokenSwapAmount(
            supply, target, _swapPair, _slippage.toString());
        setState(() {
          if (!init) {
            _amountReceiveCtrl.text = output;
          }
          _swapRatio = double.parse(output) / double.parse(supply);
        });
        if (!init) {
          _formKey.currentState.validate();
        }
      }
    }
  }

  void _onSlippageChange(String v) {
    final Map dic = I18n.of(context).acala;
    try {
      double value = double.parse(v.trim());
      if (value > 5 || value < 0.1) {
        setState(() {
          _slippageError = dic['dex.slippage.error'];
        });
      } else {
        setState(() {
          _slippageError = null;
        });
        _updateSlippage(value / 100, custom: true);
      }
    } catch (err) {
      setState(() {
        _slippageError = dic['dex.slippage.error'];
      });
    }
  }

  Future<void> _updateSlippage(double input, {bool custom = false}) async {
    if (!custom) {
      _slippageFocusNode.unfocus();
      setState(() {
        _amountSlippageCtrl.text = '';
      });
    }
    setState(() {
      _slippage = input;
    });
    await _calcSwapAmount(_amountPayCtrl.text.trim(), null);
    _refreshData();
  }

  void _onSubmit() {
    if (_formKey.currentState.validate()) {
      int decimals = store.settings.networkState.tokenDecimals;
      String pay = _amountPayCtrl.text.trim();
      String receive = _amountReceiveCtrl.text.trim();
      var args = {
        "title": I18n.of(context).acala['dex.title'],
        "txInfo": {
          "module": 'dex',
          "call": 'swapCurrency',
        },
        "detail": jsonEncode({
          "currencyPay": _swapPair[0],
          "amountPay": pay,
          "currencyReceive": _swapPair[1],
          "amountReceive": receive,
        }),
        "params": [
          // params.supply
          _swapPair[0],
          Fmt.tokenInt(pay, decimals).toString(),
          // params.target
          _swapPair[1],
          Fmt.tokenInt(receive, decimals).toString(),
        ],
        "onFinish": (BuildContext txPageContext, Map res) {
//          print(res);
          store.acala.setSwapTxs([res]);
          Navigator.popUntil(
              txPageContext, ModalRoute.withName(SwapPage.route));
          _refreshKey.currentState.show();
        }
      };
      Navigator.of(context).pushNamed(TxConfirmPage.route, arguments: args);
    }
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      List currencyIds = store.acala.swapTokens;
      if (currencyIds != null) {
        setState(() {
          _swapPair = [store.acala.swapTokens[0], acala_stable_coin_view];
        });
        _refreshData();
        _calcSwapAmount('1', null, init: true);
      }
    });
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

        BigInt balance = BigInt.zero;
        if (store.acala.swapTokens != null && _swapPair.length > 0) {
          balance = Fmt.balanceInt(
              store.assets.tokenBalances[_swapPair[0].toUpperCase()]);
        }

        Color primary = Theme.of(context).primaryColor;
        Color grey = Theme.of(context).unselectedWidgetColor;

        return Scaffold(
          appBar: AppBar(title: Text(dic['dex.title']), centerTitle: true),
          body: SafeArea(
            child: RefreshIndicator(
              key: _refreshKey,
              onRefresh: _refreshData,
              child: ListView(
                padding: EdgeInsets.all(16),
                children: <Widget>[
                  RoundedCard(
                    padding: EdgeInsets.all(16),
                    child: _swapPair.length == 2
                        ? Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Form(
                                key: _formKey,
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: <Widget>[
                                          GestureDetector(
                                            child: CurrencyWithIcon(
                                              _swapPair[0],
                                              textStyle: Theme.of(context)
                                                  .textTheme
                                                  .headline4,
                                              trailing: Icon(
                                                  Icons.keyboard_arrow_down),
                                            ),
                                            onTap: () => _selectCurrencyPay(),
                                          ),
                                          TextFormField(
                                            decoration: InputDecoration(
                                              hintText: dic['dex.pay'],
                                              labelText: dic['dex.pay'],
                                              suffix: GestureDetector(
                                                child: Icon(
                                                  CupertinoIcons
                                                      .clear_thick_circled,
                                                  color: Theme.of(context)
                                                      .disabledColor,
                                                  size: 18,
                                                ),
                                                onTap: () {
                                                  WidgetsBinding.instance
                                                      .addPostFrameCallback(
                                                          (_) => _amountPayCtrl
                                                              .clear());
                                                },
                                              ),
                                            ),
                                            inputFormatters: [
                                              UI.decimalInputFormatter(decimals)
                                            ],
                                            controller: _amountPayCtrl,
                                            keyboardType:
                                                TextInputType.numberWithOptions(
                                                    decimal: true),
                                            validator: (v) {
                                              try {
                                                if (v.isEmpty ||
                                                    double.parse(v) == 0) {
                                                  return dicAssets[
                                                      'amount.error'];
                                                }
                                              } catch (err) {
                                                return dicAssets[
                                                    'amount.error'];
                                              }
                                              if (double.parse(v.trim()) >
                                                  Fmt.bigIntToDouble(
                                                      balance, decimals)) {
                                                return dicAssets['amount.low'];
                                              }
                                              return null;
                                            },
                                            onChanged: _onSupplyAmountChange,
                                          ),
                                          Padding(
                                            padding: EdgeInsets.only(top: 8),
                                            child: Text(
                                              '${dicAssets['balance']}: ${Fmt.token(balance, decimals)} ${_swapPair[0]}',
                                              style: TextStyle(
                                                  color: Theme.of(context)
                                                      .unselectedWidgetColor),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    GestureDetector(
                                      child: Padding(
                                        padding:
                                            EdgeInsets.fromLTRB(8, 2, 8, 0),
                                        child: Icon(
                                          Icons.repeat,
                                          color: Theme.of(context).primaryColor,
                                        ),
                                      ),
                                      onTap: () => _switchPair(),
                                    ),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: <Widget>[
                                          GestureDetector(
                                            child: CurrencyWithIcon(
                                              _swapPair[1],
                                              textStyle: Theme.of(context)
                                                  .textTheme
                                                  .headline4,
                                              trailing: Icon(
                                                  Icons.keyboard_arrow_down),
                                            ),
                                            onTap: () =>
                                                _selectCurrencyReceive(),
                                          ),
                                          TextFormField(
                                            decoration: InputDecoration(
                                              hintText: dic['dex.receive'],
                                              labelText: dic['dex.receive'],
                                              suffix: GestureDetector(
                                                child: Icon(
                                                  CupertinoIcons
                                                      .clear_thick_circled,
                                                  color: Theme.of(context)
                                                      .disabledColor,
                                                  size: 18,
                                                ),
                                                onTap: () {
                                                  WidgetsBinding.instance
                                                      .addPostFrameCallback(
                                                          (_) =>
                                                              _amountReceiveCtrl
                                                                  .clear());
                                                },
                                              ),
                                            ),
                                            inputFormatters: [
                                              UI.decimalInputFormatter(decimals)
                                            ],
                                            controller: _amountReceiveCtrl,
                                            keyboardType:
                                                TextInputType.numberWithOptions(
                                                    decimal: true),
                                            validator: (v) {
                                              try {
                                                if (v.isEmpty ||
                                                    double.parse(v) == 0) {
                                                  return dicAssets[
                                                      'amount.error'];
                                                }
                                              } catch (err) {
                                                return dicAssets[
                                                    'amount.error'];
                                              }
                                              // check if pool has sufficient assets
//                                    if (true) {
//                                      return dicAssets['amount.low'];
//                                    }
                                              return null;
                                            },
                                            onChanged: _onTargetAmountChange,
                                          ),
                                        ],
                                      ),
                                    )
                                  ],
                                ),
                              ),
                              Divider(),
                              Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Text(
                                          dic['dex.rate'],
                                          style: TextStyle(
                                              color: Theme.of(context)
                                                  .unselectedWidgetColor),
                                        ),
                                        Text(
                                            '1 ${_swapPair[0]} = ${_swapRatio.toStringAsFixed(6)} ${_swapPair[1]}'),
                                      ],
                                    ),
                                    GestureDetector(
                                      child: Container(
                                        child: Column(
                                          children: <Widget>[
                                            Icon(Icons.history, color: primary),
                                            Text(
                                              dic['loan.txs'],
                                              style: TextStyle(
                                                  color: primary, fontSize: 14),
                                            )
                                          ],
                                        ),
                                      ),
                                      onTap: () => Navigator.of(context)
                                          .pushNamed(SwapHistoryPage.route),
                                    ),
                                  ])
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
                            dic['dex.slippage'],
                            style: TextStyle(
                                color: Theme.of(context).unselectedWidgetColor),
                          ),
                        ),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            OutlinedButtonSmall(
                              content: '0.1 %',
                              active: _slippage == 0.001,
                              onPressed: () => _updateSlippage(0.001),
                            ),
                            OutlinedButtonSmall(
                              content: '0.5 %',
                              active: _slippage == 0.005,
                              onPressed: () => _updateSlippage(0.005),
                            ),
                            OutlinedButtonSmall(
                              content: '1 %',
                              active: _slippage == 0.01,
                              onPressed: () => _updateSlippage(0.01),
                            ),
                            Expanded(
                              child: Column(
                                children: <Widget>[
                                  CupertinoTextField(
                                    padding: EdgeInsets.fromLTRB(12, 4, 12, 4),
                                    placeholder: 'customized',
                                    inputFormatters: [
                                      UI.decimalInputFormatter(decimals)
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
                                    onChanged: _onSlippageChange,
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
                                  _slippageError != null
                                      ? Text(
                                          _slippageError,
                                          style: TextStyle(
                                              color: Colors.red, fontSize: 12),
                                        )
                                      : Container()
                                ],
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
                      text: dic['dex.title'],
                      onPressed: _swapRatio == 0 ? null : _onSubmit,
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
