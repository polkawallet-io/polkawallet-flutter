import 'dart:convert';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:polka_wallet/common/components/currencyWithIcon.dart';
import 'package:polka_wallet/common/components/roundedButton.dart';
import 'package:polka_wallet/common/components/roundedCard.dart';
import 'package:polka_wallet/common/regInputFormatter.dart';
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

  final _formKey = GlobalKey<FormState>();
  final TextEditingController _amountPayCtrl = new TextEditingController();
  final TextEditingController _amountReceiveCtrl = new TextEditingController();
  final TextEditingController _amountSlippageCtrl = new TextEditingController();

  final FocusNode _slippageFocusNode = FocusNode();

  double _slippage = 0.005;
  String _slippageError;

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
    await _calcSwapAmount(_amountPayCtrl.text.trim(), null);
    _refreshData();
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
      await _calcSwapAmount(_amountPayCtrl.text, null);
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

  Future<void> _calcSwapAmount(String supply, String target) async {
    if (supply == null) {
      if (target.isNotEmpty) {
        String output = await webApi.acala
            .fetchTokenSwapAmount(supply, target, _slippage.toString());
        setState(() {
          _amountPayCtrl.text = output;
        });
        _formKey.currentState.validate();
      }
    } else if (target == null) {
      if (supply.isNotEmpty) {
        String output = await webApi.acala
            .fetchTokenSwapAmount(supply, target, _slippage.toString());
        setState(() {
          _amountReceiveCtrl.text = output;
        });
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
      int decimals = store.settings.networkState.tokenDecimals;
      List<String> swapPair = store.acala.currentSwapPair;
      String pay = _amountPayCtrl.text.trim();
      String receive = _amountReceiveCtrl.text.trim();
      var args = {
        "title": I18n.of(context).acala['dex.title'],
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
          swapPair[0],
          Fmt.tokenInt(pay, decimals: decimals).toString(),
          // params.target
          swapPair[1],
          Fmt.tokenInt(receive, decimals: decimals).toString(),
        ],
        "onFinish": (BuildContext txPageContext, Map res) {
//          print(res);
          store.acala.setSwapTxs([res]);
          Navigator.popUntil(
              txPageContext, ModalRoute.withName(SwapPage.route));
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
              key: globalDexRefreshKey,
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
                                                  .addPostFrameCallback((_) =>
                                                      _amountPayCtrl.clear());
                                            },
                                          ),
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
                                                  .addPostFrameCallback((_) =>
                                                      _amountReceiveCtrl
                                                          .clear());
                                            },
                                          ),
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
                                            '1 ${swapPair[0]} = ${store.acala.swapRatio} ${swapPair[1]}'),
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
                            _SlippageButton(
                              content: '0.1 %',
                              active: _slippage == 0.001,
                              onPressed: () => _updateSlippage(0.001),
                            ),
                            _SlippageButton(
                              content: '0.5 %',
                              active: _slippage == 0.005,
                              onPressed: () => _updateSlippage(0.005),
                            ),
                            _SlippageButton(
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
