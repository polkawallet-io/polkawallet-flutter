import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:polka_wallet/common/components/roundedButton.dart';
import 'package:polka_wallet/common/consts/settings.dart';
import 'package:polka_wallet/page-acala/loan/loanAdjustPage.dart';
import 'package:polka_wallet/page-acala/loan/loanInfoPanel.dart';
import 'package:polka_wallet/page/account/txConfirmPage.dart';
import 'package:polka_wallet/store/acala/types/loanType.dart';
import 'package:polka_wallet/store/app.dart';
import 'package:polka_wallet/utils/UI.dart';
import 'package:polka_wallet/utils/format.dart';
import 'package:polka_wallet/utils/i18n/index.dart';

class LoanCreatePage extends StatefulWidget {
  LoanCreatePage(this.store);
  static const String route = '/acala/loan/create';

  final AppStore store;

  @override
  _LoanCreatePageState createState() => _LoanCreatePageState(store);
}

class _LoanCreatePageState extends State<LoanCreatePage> {
  _LoanCreatePageState(this.store);
  final AppStore store;

  final _formKey = GlobalKey<FormState>();

  final TextEditingController _amountCtrl = new TextEditingController();
  final TextEditingController _amountCtrl2 = new TextEditingController();

  BigInt _amountCollateral = BigInt.zero;
  BigInt _amountDebit = BigInt.zero;

  BigInt _maxToBorrow = BigInt.zero;
  double _currentRatio = 0;
  BigInt _liquidationPrice = BigInt.zero;

  bool _autoValidate = false;

  void _updateState(LoanType loanType, BigInt collateral, BigInt debit) {
    final int decimals = store.settings.networkState.tokenDecimals;
    final LoanAdjustPageParams params =
        ModalRoute.of(context).settings.arguments;
    BigInt tokenPrice = store.acala.prices[params.token];
    BigInt stableCoinPrice = store.acala.prices[acala_stable_coin];
    BigInt collateralInUSD =
        loanType.tokenToUSD(collateral, tokenPrice, decimals);
    BigInt debitInUSD = loanType.tokenToUSD(debit, stableCoinPrice, decimals);
    setState(() {
      _liquidationPrice = loanType.calcLiquidationPrice(
        debitInUSD,
        collateral,
      );
      _currentRatio = loanType.calcCollateralRatio(debitInUSD, collateralInUSD);
    });
  }

  void _onAmount1Change(
    String value,
    LoanType loanType,
    BigInt price,
    BigInt stableCoinPrice,
    int decimals,
  ) {
    String v = value.trim();
    if (v.isEmpty) return;

    BigInt collateral = Fmt.tokenInt(v, decimals);
    setState(() {
      _amountCollateral = collateral;
      _maxToBorrow = loanType.calcMaxToBorrow(
          collateral, price, stableCoinPrice, decimals);
    });
//    print(_maxToBorrow.toString());

    if (_amountDebit > BigInt.zero) {
      _updateState(loanType, collateral, _amountDebit);
    }

    _checkAutoValidate();
  }

  void _onAmount2Change(String value, LoanType loanType, int decimals) {
    String v = value.trim();
    if (v.isEmpty) return;

    BigInt debits = Fmt.tokenInt(v, decimals);

    setState(() {
      _amountDebit = debits;
    });

    if (_amountCollateral > BigInt.zero) {
      _updateState(loanType, _amountCollateral, debits);
    }

    _checkAutoValidate();
  }

  void _checkAutoValidate({String value1, String value2}) {
    if (_autoValidate) return;
    if (value1 == null) {
      value1 = _amountCtrl.text.trim();
    }
    if (value2 == null) {
      value2 = _amountCtrl2.text.trim();
    }
    if (value1.isNotEmpty && value2.isNotEmpty) {
      setState(() {
        _autoValidate = true;
      });
    }
  }

  String _validateAmount1(String value, BigInt available, int decimals) {
    final Map assetDic = I18n.of(context).assets;

    String v = value.trim();
    try {
      if (v.isEmpty || double.parse(v) == 0) {
        return assetDic['amount.error'];
      }
    } catch (err) {
      return assetDic['amount.error'];
    }
    BigInt collateral = Fmt.tokenInt(v, decimals);
    if (collateral > available) {
      return assetDic['amount.low'];
    }
    return null;
  }

  String _validateAmount2(String value, max, int decimals) {
    final Map assetDic = I18n.of(context).assets;
    final Map dic = I18n.of(context).acala;

    String v = value.trim();
    try {
      if (v.isEmpty || double.parse(v) < 1) {
        return assetDic['amount.error'];
      }
    } catch (err) {
      return assetDic['amount.error'];
    }
    BigInt debits = Fmt.tokenInt(v, decimals);
    if (debits >= _maxToBorrow) {
      return '${dic['loan.max']} $max';
    }
    return null;
  }

  Map _getTxParams(LoanType loanType, int decimals) {
    final LoanAdjustPageParams params =
        ModalRoute.of(context).settings.arguments;
    BigInt debitShare = loanType.debitToDebitShare(_amountDebit, decimals);
    return {
      'detail': jsonEncode({
        "colleterals": Fmt.token(_amountCollateral, decimals),
        "debits": Fmt.token(_amountDebit, decimals),
      }),
      'params': [
        params.token,
        _amountCollateral.toString(),
        debitShare.toString(),
      ]
    };
  }

  void _onSubmit(String pageTitle, LoanType loanType, int decimals) {
    Map params = _getTxParams(loanType, decimals);
    var args = {
      "title": pageTitle,
      "txInfo": {
        "module": 'honzon',
        "call": 'adjustLoan',
      },
      "detail": params['detail'],
      "params": params['params'],
      'onFinish': (BuildContext txPageContext, Map res) {
        store.acala.setLoanTxs([res]);
        Navigator.popUntil(txPageContext, ModalRoute.withName('/acala/loan'));
        globalLoanRefreshKey.currentState.show();
      }
    };
    Navigator.of(context).pushNamed(TxConfirmPage.route, arguments: args);
  }

  @override
  void dispose() {
    _amountCtrl.dispose();
    _amountCtrl2.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var dic = I18n.of(context).acala;
    var assetDic = I18n.of(context).assets;
    final int decimals = store.settings.networkState.tokenDecimals;
    final LoanAdjustPageParams params =
        ModalRoute.of(context).settings.arguments;
    String symbol = params.token;

    String pageTitle = '${dic['loan.create']} $symbol';

    BigInt price = store.acala.prices[symbol];
    BigInt stableCoinPrice = store.acala.prices[acala_stable_coin];

    LoanType loanType =
        store.acala.loanTypes.firstWhere((i) => i.token == symbol);
    BigInt balance = Fmt.balanceInt(store.assets.tokenBalances[params.token]);
    BigInt available = balance;

    String balanceView = Fmt.token(available, decimals);
    String maxToBorrow = Fmt.token(_maxToBorrow, decimals);

    return Scaffold(
      appBar: AppBar(
        title: Text(pageTitle),
        centerTitle: true,
      ),
      body: Builder(builder: (BuildContext context) {
        return SafeArea(
          child: Column(
            children: <Widget>[
              Expanded(
                child: Form(
                  key: _formKey,
                  autovalidate: _autoValidate,
                  child: ListView(
                    padding: EdgeInsets.all(16),
                    children: <Widget>[
                      LoanInfoPanel(
                        price: price,
                        liquidationRatio: loanType.liquidationRatio,
                        requiredRatio: loanType.requiredCollateralRatio,
                        currentRatio: _currentRatio,
                        liquidationPrice: _liquidationPrice,
                        decimals: decimals,
                      ),
                      Padding(
                        padding: EdgeInsets.only(top: 16),
                        child: Text(dic['loan.amount.collateral']),
                      ),
                      TextFormField(
                        decoration: InputDecoration(
                          hintText: assetDic['amount'],
                          labelText:
                              '${assetDic['amount']} (${assetDic['available']}: $balanceView $symbol)',
                        ),
                        inputFormatters: [UI.decimalInputFormatter(decimals)],
                        controller: _amountCtrl,
                        keyboardType:
                            TextInputType.numberWithOptions(decimal: true),
                        validator: (v) =>
                            _validateAmount1(v, available, decimals),
                        onChanged: (v) => _onAmount1Change(
                            v, loanType, price, stableCoinPrice, decimals),
                      ),
                      Padding(
                        padding: EdgeInsets.only(top: 16),
                        child: Text(dic['loan.amount.debit']),
                      ),
                      TextFormField(
                        decoration: InputDecoration(
                          hintText: assetDic['amount'],
                          labelText:
                              '${assetDic['amount']}(${dic['loan.max']}: $maxToBorrow)',
                        ),
                        inputFormatters: [UI.decimalInputFormatter(decimals)],
                        controller: _amountCtrl2,
                        keyboardType:
                            TextInputType.numberWithOptions(decimal: true),
                        validator: (v) =>
                            _validateAmount2(v, maxToBorrow, decimals),
                        onChanged: (v) =>
                            _onAmount2Change(v, loanType, decimals),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(16),
                child: RoundedButton(
                  text: I18n.of(context).home['submit.tx'],
                  onPressed: () {
                    if (_formKey.currentState.validate()) {
                      _onSubmit(pageTitle, loanType, decimals);
                    }
                  },
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}
