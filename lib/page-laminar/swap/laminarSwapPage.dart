import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:polka_wallet/common/components/currencyWithIcon.dart';
import 'package:polka_wallet/common/components/roundedButton.dart';
import 'package:polka_wallet/common/components/roundedCard.dart';
import 'package:polka_wallet/common/consts/settings.dart';
import 'package:polka_wallet/page-laminar/swap/laminarSwapHistoryPage.dart';
import 'package:polka_wallet/page/account/txConfirmPage.dart';
import 'package:polka_wallet/page/assets/transfer/currencySelectPage.dart';
import 'package:polka_wallet/service/substrateApi/api.dart';
import 'package:polka_wallet/store/app.dart';
import 'package:polka_wallet/store/laminar/types/laminarSyntheticData.dart';
import 'package:polka_wallet/utils/UI.dart';
import 'package:polka_wallet/utils/format.dart';
import 'package:polka_wallet/utils/i18n/index.dart';

class LaminarSwapPage extends StatefulWidget {
  LaminarSwapPage(this.store);

  static const String route = '/laminar/swap';
  final AppStore store;

  @override
  _LaminarSwapPageState createState() => _LaminarSwapPageState();
}

class _LaminarSwapPageState extends State<LaminarSwapPage> {
  final GlobalKey<RefreshIndicatorState> _refreshKey =
      new GlobalKey<RefreshIndicatorState>();

  final _formKey = GlobalKey<FormState>();
  final TextEditingController _amountPayCtrl = new TextEditingController();
  final TextEditingController _amountReceiveCtrl = new TextEditingController();

  final _maxPrice = '1000000000000000000000000';

  String _tokenPay = acala_stable_coin;
  String _tokenReceive;
  LaminarSyntheticPoolTokenData _tokenPool;
  bool _isRedeem = false;

  Future<void> _fetchData() async {
    webApi.assets.fetchBalance();
    final Map res = await webApi.laminar.subscribeSyntheticPools();

    if (_tokenPool == null) {
      final LaminarSyntheticPoolTokenData token =
          LaminarSyntheticPoolTokenData.fromJson(res['options'][0]);
      setState(() {
        _tokenPool = token;
        _tokenReceive = token.tokenId;
      });
    }
  }

  Future<void> _switchPair() async {
    final List<String> swapPair = [_tokenPay, _tokenReceive].toList();
    setState(() {
      _isRedeem = !_isRedeem;
      _tokenPay = swapPair[1];
      _tokenReceive = swapPair[0];
    });
    await _calcSwapAmount(_amountPayCtrl.text.trim(), null);
  }

  Future<void> _selectCurrencyPay() async {
    if (!_isRedeem) return;
    var selected = await Navigator.of(context).pushNamed(
      CurrencySelectPage.route,
      arguments:
          widget.store.laminar.syntheticTokens.map((e) => e.tokenId).toList(),
    );
    if (selected != null) {
      setState(() {
        _tokenPay = selected;
        _tokenPool = widget.store.laminar.syntheticTokens
            .firstWhere((e) => e.tokenId == selected);
      });
    }
  }

  Future<void> _selectCurrencyReceive() async {
    if (_isRedeem) return;
    var selected = await Navigator.of(context).pushNamed(
      CurrencySelectPage.route,
      arguments:
          widget.store.laminar.syntheticTokens.map((e) => e.tokenId).toList(),
    );
    if (selected != null) {
      setState(() {
        _tokenReceive = selected;
        _tokenPool = widget.store.laminar.syntheticTokens
            .firstWhere((e) => e.tokenId == selected);
      });
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
    final int decimals = widget.store.settings.networkState.tokenDecimals;
    if (supply == null) {
      if (target.isNotEmpty) {
        double price = Fmt.balanceDouble(
          widget.store.laminar
              .tokenPrices[_isRedeem ? _tokenPay : _tokenReceive]?.value,
          decimals,
        );
        if (price == 0.0) return;
        double output = _isRedeem
            ? double.parse(target) / price
            : double.parse(target) * price;
        setState(() {
          _amountPayCtrl.text = output.toStringAsFixed(2);
        });
        _formKey.currentState.validate();
      }
    } else if (target == null) {
      if (supply.isNotEmpty) {
        double price = Fmt.balanceDouble(
          widget.store.laminar
              .tokenPrices[_isRedeem ? _tokenPay : _tokenReceive]?.value,
          decimals,
        );
        if (price == 0.0) return;
        double output = _isRedeem
            ? double.parse(supply) * price
            : double.parse(supply) / price;
        setState(() {
          _amountReceiveCtrl.text = output.toStringAsFixed(2);
        });
        _formKey.currentState.validate();
      }
    }
  }

  void _onSubmit() {
    if (_formKey.currentState.validate()) {
      int decimals = widget.store.settings.networkState.tokenDecimals;
      String pay = _amountPayCtrl.text.trim();
      var args = {
        "title": I18n.of(context).acala['dex.title'],
        "txInfo": {
          "module": 'syntheticProtocol',
          "call": _isRedeem ? 'redeem' : 'mint',
        },
        "detail": jsonEncode({
          "amountPay": pay,
          "currencyPay": _tokenPay,
          "currencyReceive": _tokenReceive,
        }),
        "params": [
          // params.poolId
          _tokenPool.poolId,

          // params.currencyId
          _isRedeem ? _tokenPay : _tokenReceive,
          // params.amount
          Fmt.tokenInt(pay, decimals).toString(),
          // params.maxPrice
          _isRedeem ? '0' : _maxPrice
        ],
        "onFinish": (BuildContext txPageContext, Map res) {
//          print(res);
          res['call'] = _isRedeem ? 'redeem' : 'mint';
          widget.store.laminar.setSwapTxs([res]);
          Navigator.popUntil(
              txPageContext, ModalRoute.withName(LaminarSwapPage.route));
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
      _refreshKey.currentState.show();
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
        final int decimals = widget.store.settings.networkState.tokenDecimals;
        final List tokens = widget.store.settings.networkConst['currencyIds'];

        BigInt balance = BigInt.zero;
        if (tokens.length > 0) {
          balance =
              Fmt.balanceInt(widget.store.assets.tokenBalances[_tokenPay]);
        }
        final double price = Fmt.balanceDouble(
            widget.store.laminar
                .tokenPrices[_isRedeem ? _tokenPay : _tokenReceive]?.value,
            decimals);
        final double swapRatio = _isRedeem ? price : 1 / price;

        int rateDecimal = 2;
        if (!_isRedeem && _tokenPool?.poolId == '1') {
          rateDecimal = 8;
        } else if (swapRatio < 0.01) {
          rateDecimal = 6;
        }

        final Color primary = Theme.of(context).primaryColor;

        return Scaffold(
          appBar: AppBar(title: Text(dic['dex.title']), centerTitle: true),
          body: SafeArea(
            child: RefreshIndicator(
              key: _refreshKey,
              onRefresh: _fetchData,
              child: ListView(
                padding: EdgeInsets.all(16),
                children: <Widget>[
                  RoundedCard(
                    padding: EdgeInsets.all(16),
                    child: _tokenPool == null
                        ? CupertinoActivityIndicator()
                        : Column(
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
                                              _tokenPay,
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
                                              if (v.isEmpty) {
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
                                              '${dicAssets['balance']}: ${Fmt.token(balance, decimals)} ${Fmt.tokenView(_tokenPay)}',
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
                                              _tokenReceive,
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
                                              if (v.isEmpty) {
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
                                            '1 ${Fmt.tokenView(_tokenPay)} = ${swapRatio.toStringAsFixed(rateDecimal)} ${Fmt.tokenView(_tokenReceive)}'),
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
                                      onTap: () {
                                        Navigator.of(context).pushNamed(
                                            LaminarSwapHistoryPage.route);
                                      },
                                    ),
                                  ])
                            ],
                          ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 24),
                    child: RoundedButton(
                      text: dic['dex.title'],
                      onPressed: price == 0.0 ? null : _onSubmit,
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
