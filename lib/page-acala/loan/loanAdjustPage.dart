import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:polka_wallet/common/components/roundedButton.dart';
import 'package:polka_wallet/common/consts/settings.dart';
import 'package:polka_wallet/common/regInputFormatter.dart';
import 'package:polka_wallet/page-acala/loan/loanInfoPanel.dart';
import 'package:polka_wallet/page/account/txConfirmPage.dart';
import 'package:polka_wallet/store/acala/types/loanType.dart';
import 'package:polka_wallet/store/app.dart';
import 'package:polka_wallet/utils/UI.dart';
import 'package:polka_wallet/utils/format.dart';
import 'package:polka_wallet/utils/i18n/index.dart';

class LoanAdjustPage extends StatefulWidget {
  LoanAdjustPage(this.store);
  static const String route = '/acala/loan/adjust';
  static const String actionTypeBorrow = 'borrow';
  static const String actionTypePayback = 'payback';
  static const String actionTypeDeposit = 'deposit';
  static const String actionTypeWithdraw = 'withdraw';

  final AppStore store;

  @override
  _LoanAdjustPageState createState() => _LoanAdjustPageState(store);
}

class LoanAdjustPageParams {
  LoanAdjustPageParams(this.actionType, this.token);
  final String actionType;
  final String token;
}

class _LoanAdjustPageState extends State<LoanAdjustPage> {
  _LoanAdjustPageState(this.store);
  final AppStore store;

  final _formKey = GlobalKey<FormState>();

  final TextEditingController _amountCtrl = new TextEditingController();
  final TextEditingController _amountCtrl2 = new TextEditingController();

  BigInt _amountCollateral = BigInt.zero;
  BigInt _amountDebit = BigInt.zero;

  double _currentRatio = 0;
  BigInt _liquidationPrice = BigInt.zero;

  bool _autoValidate = false;
  bool _paybackAndCloseChecked = false;

  void _updateState(LoanType loanType, BigInt collateral, BigInt debit) {
    final LoanAdjustPageParams params =
        ModalRoute.of(context).settings.arguments;
    BigInt tokenPrice = store.acala.prices[params.token];
    BigInt stableCoinPrice = store.acala.prices[acala_stable_coin];
    BigInt collateralInUSD = loanType.tokenToUSD(collateral, tokenPrice);
    BigInt debitInUSD = loanType.tokenToUSD(debit, stableCoinPrice);
    setState(() {
      _liquidationPrice = loanType.calcLiquidationPrice(
        debitInUSD,
        collateral,
      );
      _currentRatio = loanType.calcCollateralRatio(debitInUSD, collateralInUSD);
    });
  }

  Map _calcTotalAmount(BigInt collateral, BigInt debit) {
    final LoanAdjustPageParams params =
        ModalRoute.of(context).settings.arguments;
    BigInt collateralTotal = collateral;
    BigInt debitTotal = debit;
    LoanData loan = store.acala.loans[params.token];
    switch (params.actionType) {
      case LoanAdjustPage.actionTypeDeposit:
        collateralTotal = loan.collaterals + collateral;
        break;
      case LoanAdjustPage.actionTypeWithdraw:
        collateralTotal = loan.collaterals - collateral;
        break;
      case LoanAdjustPage.actionTypeBorrow:
        debitTotal = loan.debits + debit;
        break;
      case LoanAdjustPage.actionTypePayback:
        debitTotal = loan.debits - debit;
        break;
      default:
      // do nothing
    }

    return {
      'collateral': collateralTotal,
      'debit': debitTotal,
    };
  }

  void _onAmount1Change(
    String value,
    LoanType loanType,
    BigInt price,
    BigInt stableCoinPrice,
  ) {
    String v = value.trim();
    if (v.isEmpty) return;

    BigInt collateral = Fmt.tokenInt(v, decimals: acala_token_decimals);
    setState(() {
      _amountCollateral = collateral;
    });

    Map amountTotal = _calcTotalAmount(collateral, _amountDebit);
    _updateState(loanType, amountTotal['collateral'], amountTotal['debit']);

    _checkAutoValidate();
  }

  void _onAmount2Change(
    String value,
    LoanType loanType,
    BigInt stableCoinPrice,
    bool showCheckbox, {
    BigInt debits,
  }) {
    String v = value.trim();
    if (v.isEmpty) return;

    BigInt debitsNew =
        debits ?? Fmt.tokenInt(v, decimals: acala_token_decimals);

    setState(() {
      _amountDebit = debitsNew;
    });
    if (!showCheckbox && _paybackAndCloseChecked) {
      setState(() {
        _paybackAndCloseChecked = false;
      });
    }

    Map amountTotal = _calcTotalAmount(_amountCollateral, debitsNew);
    _updateState(loanType, amountTotal['collateral'], amountTotal['debit']);

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
    if (value1.isNotEmpty || value2.isNotEmpty) {
      setState(() {
        _autoValidate = true;
      });
    }
  }

  String _validateAmount1(String value, BigInt available) {
    final Map assetDic = I18n.of(context).assets;

    String v = value.trim();
    if (v.isEmpty || double.parse(v) == 0) {
      return assetDic['amount.error'];
    }
    if (_amountCollateral > available) {
      return assetDic['amount.low'];
    }
    return null;
  }

  String _validateAmount2(
    String value,
    BigInt max,
    String maxToBorrowView,
    BigInt balanceAUSD,
    LoanData loan,
  ) {
    final Map assetDic = I18n.of(context).assets;
    final Map dic = I18n.of(context).acala;

    String v = value.trim();
    if (v.isEmpty) {
      return assetDic['amount.error'];
    }
    final LoanAdjustPageParams params =
        ModalRoute.of(context).settings.arguments;
    if (params.actionType == LoanAdjustPage.actionTypeBorrow &&
        _amountDebit > max) {
      return '${dic['loan.max']} $maxToBorrowView';
    }
    if (params.actionType == LoanAdjustPage.actionTypePayback) {
      if (_amountDebit > balanceAUSD) {
        String balance = Fmt.token(balanceAUSD, decimals: acala_token_decimals);
        return '${assetDic['amount.low']}(${assetDic['balance']}: $balance)';
      }
      BigInt debitLeft = loan.debits - _amountDebit;
      if (debitLeft > BigInt.zero &&
          loan.type.debitToDebitShare(debitLeft) <
              loan.type.minimumDebitValue) {
        return dic['payback.small'];
      }
    }
    return null;
  }

  Map _getTxParams(LoanData loan) {
    final LoanAdjustPageParams params =
        ModalRoute.of(context).settings.arguments;
    switch (params.actionType) {
      case LoanAdjustPage.actionTypeBorrow:
        BigInt debitAdd = loan.type.debitToDebitShare(_amountDebit);
        return {
          'detail': jsonEncode({
            "amount": _amountCtrl2.text.trim(),
          }),
          'params': [
            params.token,
            0,
            debitAdd.toString(),
          ]
        };
      case LoanAdjustPage.actionTypePayback:

        /// payback all debts if user input more than debts
        BigInt debitSubtract = _amountDebit >= loan.debits
            ? loan.debitShares
            : loan.type.debitToDebitShare(_amountDebit);

        /// pay less if less than 1 share will be left,
        /// make sure tx success by leaving more than 1 share.
        if (loan.debits - _amountDebit <
            loan.type.debitShareToDebit(BigInt.one)) {
          debitSubtract = loan.debitShares - BigInt.one;
        }
        return {
          'detail': jsonEncode({
            "amount": _amountCtrl2.text.trim(),
          }),
          'params': [
            params.token,
            _paybackAndCloseChecked
                ? (BigInt.zero - loan.collaterals).toString()
                : 0,
            (BigInt.zero - debitSubtract).toString(),
          ]
        };
      case LoanAdjustPage.actionTypeDeposit:
        return {
          'detail': jsonEncode({
            "amount": _amountCtrl.text.trim(),
          }),
          'params': [
            params.token,
            _amountCollateral.toString(),
            0,
          ]
        };
      case LoanAdjustPage.actionTypeWithdraw:
        return {
          'detail': jsonEncode({
            "amount": _amountCtrl.text.trim(),
          }),
          'params': [
            params.token,
            (BigInt.zero - _amountCollateral).toString(),
            0,
          ]
        };
      default:
        return {};
    }
  }

  void _onSubmit(String pageTitle, LoanData loan) {
    Map params = _getTxParams(loan);
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
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final LoanAdjustPageParams params =
          ModalRoute.of(context).settings.arguments;
      LoanData loan = store.acala.loans[params.token];
      setState(() {
        _amountCollateral = loan.collaterals;
        _amountDebit = loan.debits;
      });
      _updateState(loan.type, loan.collaterals, loan.debits);
    });
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

    final int decimals = acala_token_decimals;
    final LoanAdjustPageParams params =
        ModalRoute.of(context).settings.arguments;
    final String symbol = params.token;
    final LoanData loan = store.acala.loans[symbol];

    final BigInt price = store.acala.prices[symbol];
    final BigInt stableCoinPrice = store.acala.prices[acala_stable_coin];

    String titleSuffix = ' $symbol';
    bool showCollateral = true;
    bool showDebit = true;

    BigInt balanceAUSD =
        Fmt.balanceInt(store.assets.tokenBalances[acala_stable_coin]);
    BigInt balance = Fmt.balanceInt(store.assets.tokenBalances[params.token]);
    BigInt available = balance;
    BigInt maxToBorrow = loan.maxToBorrow - loan.debits;
    String maxToBorrowView = Fmt.priceFloorBigInt(maxToBorrow);

    switch (params.actionType) {
      case LoanAdjustPage.actionTypeBorrow:
        maxToBorrow = Fmt.tokenInt(maxToBorrowView, decimals: decimals);
        showCollateral = false;
        titleSuffix = ' aUSD';
        break;
      case LoanAdjustPage.actionTypePayback:
        // max to payback
        maxToBorrow = loan.debits;
        maxToBorrowView = Fmt.priceCeilBigInt(maxToBorrow);
        showCollateral = false;
        titleSuffix = ' aUSD';
        break;
      case LoanAdjustPage.actionTypeDeposit:
        showDebit = false;
        break;
      case LoanAdjustPage.actionTypeWithdraw:
        available = loan.collaterals - loan.requiredCollateral;
        showDebit = false;
        break;
      default:
    }

    int maxCollateralDecimal =
        loan.debits > BigInt.zero ? 6 : acala_token_decimals;
    String availableView =
        Fmt.priceFloorBigInt(available, lengthMax: maxCollateralDecimal);

    String pageTitle = '${dic['loan.${params.actionType}']}$titleSuffix';

    bool showCheckbox = params.actionType == LoanAdjustPage.actionTypePayback &&
        _amountCtrl2.text.trim().isNotEmpty &&
        _amountDebit == loan.debits;

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
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.fromLTRB(16, 16, 16, 0),
                        child: LoanInfoPanel(
                          price: price,
                          liquidationRatio: loan.type.liquidationRatio,
                          requiredRatio: loan.type.requiredCollateralRatio,
                          currentRatio: _currentRatio,
                          liquidationPrice: _liquidationPrice,
                        ),
                      ),
                      showCollateral
                          ? Padding(
                              padding: EdgeInsets.only(left: 16, right: 16),
                              child: TextFormField(
                                decoration: InputDecoration(
                                  hintText: assetDic['amount'],
                                  labelText:
                                      '${assetDic['amount']} (${assetDic['available']}: $availableView $symbol)',
                                  suffix: GestureDetector(
                                    child: Text(
                                      dic['loan.max'],
                                      style: TextStyle(
                                          color:
                                              Theme.of(context).primaryColor),
                                    ),
                                    onTap: () async {
                                      BigInt max = Fmt.tokenInt(availableView,
                                          decimals: maxCollateralDecimal);
                                      setState(() {
                                        _amountCollateral = max;
                                        _amountCtrl.text = Fmt.bigIntToDouble(
                                          max,
                                          decimals: maxCollateralDecimal,
                                        ).toString();
                                      });
                                      _onAmount1Change(
                                        availableView,
                                        loan.type,
                                        price,
                                        stableCoinPrice,
                                      );
                                    },
                                  ),
                                ),
                                inputFormatters: [
                                  RegExInputFormatter.withRegex(
                                      '^[0-9]{0,6}(\\.[0-9]{0,$decimals})?\$')
                                ],
                                controller: _amountCtrl,
                                keyboardType: TextInputType.numberWithOptions(
                                    decimal: true),
                                validator: (v) =>
                                    _validateAmount1(v, available),
                                onChanged: (v) => _onAmount1Change(
                                    v, loan.type, price, stableCoinPrice),
                              ),
                            )
                          : Container(),
                      showDebit
                          ? Padding(
                              padding: EdgeInsets.only(left: 16, right: 16),
                              child: TextFormField(
                                decoration: InputDecoration(
                                  hintText: assetDic['amount'],
                                  labelText:
                                      '${assetDic['amount']}(${dic['loan.max']}: $maxToBorrowView)',
                                  suffix: GestureDetector(
                                    child: Text(
                                      dic['loan.max'],
                                      style: TextStyle(
                                          color:
                                              Theme.of(context).primaryColor),
                                    ),
                                    onTap: () async {
                                      double max = NumberFormat(",##0.00")
                                          .parse(maxToBorrowView);
                                      setState(() {
                                        _amountDebit = maxToBorrow;
                                        _amountCtrl2.text = max.toString();
                                      });
                                      _onAmount2Change(
                                        maxToBorrowView,
                                        loan.type,
                                        stableCoinPrice,
                                        showCheckbox,
                                        debits: maxToBorrow,
                                      );
                                    },
                                  ),
                                ),
                                inputFormatters: [
                                  RegExInputFormatter.withRegex(
                                      '^[0-9]{0,6}(\\.[0-9]{0,$decimals})?\$')
                                ],
                                controller: _amountCtrl2,
                                keyboardType: TextInputType.numberWithOptions(
                                    decimal: true),
                                validator: (v) => _validateAmount2(
                                    v,
                                    maxToBorrow,
                                    maxToBorrowView,
                                    balanceAUSD,
                                    loan),
                                onChanged: (v) => _onAmount2Change(v, loan.type,
                                    stableCoinPrice, showCheckbox),
                              ),
                            )
                          : Container(),
                      showCheckbox
                          ? Row(
                              children: <Widget>[
                                Checkbox(
                                  value: _paybackAndCloseChecked,
                                  onChanged: (v) {
                                    setState(() {
                                      _paybackAndCloseChecked = v;
                                    });
                                  },
                                ),
                                GestureDetector(
                                  child: Text(dic['loan.withdraw.all']),
                                  onTap: () {
                                    setState(() {
                                      _paybackAndCloseChecked =
                                          !_paybackAndCloseChecked;
                                    });
                                  },
                                )
                              ],
                            )
                          : Container(),
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
                      _onSubmit(pageTitle, loan);
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
