import 'dart:async';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:polka_wallet/common/components/currencyWithIcon.dart';
import 'package:polka_wallet/common/components/outlinedButtonSmall.dart';
import 'package:polka_wallet/common/components/roundedButton.dart';
import 'package:polka_wallet/common/components/roundedCard.dart';
import 'package:polka_wallet/page-acala/swap/swapHistoryPage.dart';
import 'package:polka_wallet/page/account/txConfirmPage.dart';
import 'package:polka_wallet/page/assets/transfer/currencySelectPage.dart';
import 'package:polka_wallet/service/substrateApi/api.dart';
import 'package:polka_wallet/store/acala/types/swapOutputData.dart';
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
  int _swapMode = 0; // 0 for 'EXACT_INPUT' and 1 for 'EXACT_OUTPUT'
  double _swapRatio = 0;
  SwapOutputData _swapOutput = SwapOutputData();

  // use a _timer to control swap amount query
  Timer _timer;

  Future<void> _refreshData() async {
    webApi.assets.fetchBalance();
  }

  Future<void> _switchPair() async {
    setState(() {
      _swapPair = [_swapPair[1], _swapPair[0]];
    });
    await _updateSwapAmount();
    _refreshData();
  }

  Future<void> _selectCurrencyPay() async {
    List<String> currencyOptions = List<String>.of(store.acala.swapTokens);
    currencyOptions.retainWhere((i) => i != _swapPair[0] && i != _swapPair[1]);
    var selected = await Navigator.of(context)
        .pushNamed(CurrencySelectPage.route, arguments: currencyOptions);
    if (selected != null) {
      setState(() {
        _swapPair = [selected, _swapPair[1]];
      });
      await _updateSwapAmount();
      _refreshData();
    }
  }

  Future<void> _selectCurrencyReceive() async {
    List<String> currencyOptions = List<String>.of(store.acala.swapTokens);
    currencyOptions.retainWhere((i) => i != _swapPair[0] && i != _swapPair[1]);
    var selected = await Navigator.of(context)
        .pushNamed(CurrencySelectPage.route, arguments: currencyOptions);
    if (selected != null) {
      setState(() {
        _swapPair = [_swapPair[0], selected];
      });
      await _updateSwapAmount();
      _refreshData();
    }
  }

  void _onSupplyAmountChange(String v) {
    String supply = v.trim();
    if (supply.isEmpty) {
      return;
    }
    setState(() {
      _swapMode = 0;
    });

    if (_timer != null) {
      _timer.cancel();
    }
    _timer = Timer(Duration(seconds: 1), () {
      _calcSwapAmount(supply, null);
    });
  }

  void _onTargetAmountChange(String v) {
    String target = v.trim();
    if (target.isEmpty) {
      return;
    }
    setState(() {
      _swapMode = 1;
    });

    if (_timer != null) {
      _timer.cancel();
    }
    _timer = Timer(Duration(seconds: 1), () {
      _calcSwapAmount(null, target);
    });
  }

  Future<void> _updateSwapAmount() async {
    if (_swapMode == 0) {
      await _calcSwapAmount(_amountPayCtrl.text.trim(), null);
    } else {
      await _calcSwapAmount(null, _amountReceiveCtrl.text.trim());
    }
  }

  Future<void> _calcSwapAmount(
    String supply,
    String target, {
    bool init = false,
  }) async {
    if (supply == null) {
      final output = await webApi.acala.fetchTokenSwapAmount(
        supply,
        target.isEmpty ? '1' : target,
        _swapPair,
        _slippage.toString(),
      );
      setState(() {
        if (!init && target.isNotEmpty) {
          _amountPayCtrl.text = output.amount.toString();
        }
        _swapRatio = target.isEmpty
            ? output.amount
            : double.parse(target) / output.amount;
        _swapOutput = output;
      });
      if (!init && target.isNotEmpty) {
        _formKey.currentState.validate();
      }
    } else if (target == null) {
      final output = await webApi.acala.fetchTokenSwapAmount(
        supply.isEmpty ? '1' : supply,
        target,
        _swapPair,
        _slippage.toString(),
      );
      setState(() {
        if (!init && supply.isNotEmpty) {
          _amountReceiveCtrl.text = output.amount.toString();
        }
        _swapRatio = supply.isEmpty
            ? output.amount
            : output.amount / double.parse(supply);
        _swapOutput = output;
      });
      if (!init && supply.isNotEmpty) {
        _formKey.currentState.validate();
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
      String pay = _amountPayCtrl.text.trim();
      String receive = _amountReceiveCtrl.text.trim();
      var args = {
        "title": I18n.of(context).acala['dex.title'],
        "txInfo": {
          "module": 'dex',
          "call":
              _swapMode == 0 ? 'swapWithExactSupply' : 'swapWithExactTarget',
        },
        "detail": jsonEncode({
          "currencyPay": _swapPair[0],
          "amountPay": pay,
          "currencyReceive": _swapPair[1],
          "amountReceive": receive,
        }),
        "params": [
          _swapOutput.path,
          _swapOutput.input,
          _swapOutput.output,
        ],
        "onFinish": (BuildContext txPageContext, Map res) {
//          print(res);
          res['mode'] = _swapMode;
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
          _swapPair = [store.acala.swapTokens[0], store.acala.swapTokens[1]];
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
                padding: EdgeInsets.fromLTRB(8, 16, 8, 16),
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
                                              '${dicAssets['balance']}: ${Fmt.token(balance, decimals)} ${Fmt.tokenView(_swapPair[0])}',
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
                                          '1 ${Fmt.tokenView(_swapPair[0])} = ${_swapRatio.toStringAsFixed(6)} ${Fmt.tokenView(_swapPair[1])}'),
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
                                ],
                              ),
                              (_swapOutput.path?.length ?? 0) > 2
                                  ? Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Divider(),
                                        Text(dic['dex.route'],
                                            style: TextStyle(
                                                color: Theme.of(context)
                                                    .unselectedWidgetColor)),
                                        Row(
                                          children: _swapOutput.path.map((e) {
                                            return CurrencyWithIcon(
                                              e['Token'].toUpperCase(),
                                              textStyle: Theme.of(context)
                                                  .textTheme
                                                  .headline4,
                                              trailing: e ==
                                                      _swapOutput.path[
                                                          _swapOutput
                                                                  .path.length -
                                                              1]
                                                  ? null
                                                  : Padding(
                                                      padding: EdgeInsets.only(
                                                          left: 8, right: 8),
                                                      child: Icon(
                                                          Icons
                                                              .arrow_forward_ios,
                                                          size: 18),
                                                    ),
                                            );
                                          }).toList(),
                                        )
                                      ],
                                    )
                                  : Container()
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
