import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:polka_wallet/common/components/currencyWithIcon.dart';
import 'package:polka_wallet/common/components/roundedButton.dart';
import 'package:polka_wallet/common/components/roundedCard.dart';
import 'package:polka_wallet/page-acala/earn/earnPage.dart';
import 'package:polka_wallet/page/account/txConfirmPage.dart';
import 'package:polka_wallet/service/substrateApi/api.dart';
import 'package:polka_wallet/store/acala/types/dexPoolInfoData.dart';
import 'package:polka_wallet/store/acala/types/txLiquidityData.dart';
import 'package:polka_wallet/store/app.dart';
import 'package:polka_wallet/utils/UI.dart';
import 'package:polka_wallet/utils/format.dart';
import 'package:polka_wallet/utils/i18n/index.dart';

class AddLiquidityPage extends StatefulWidget {
  AddLiquidityPage(this.store);

  static const String route = '/acala/earn/deposit';
  static const String actionDeposit = 'deposit';

  final AppStore store;

  @override
  _AddLiquidityPageState createState() => _AddLiquidityPageState(store);
}

class _AddLiquidityPageState extends State<AddLiquidityPage> {
  _AddLiquidityPageState(this.store);

  final AppStore store;

  final _formKey = GlobalKey<FormState>();
  final TextEditingController _amountTokenCtrl = new TextEditingController();
  final TextEditingController _amountBaseCoinCtrl = new TextEditingController();

  double _price = 0;

  Future<void> _refreshData() async {
    final String poolId = ModalRoute.of(context).settings.arguments;
    webApi.acala.fetchTokens(store.account.currentAccount.pubKey);
    await webApi.acala.fetchDexPoolInfo(poolId);

    final output = await webApi.acala.fetchTokenSwapAmount(
      '1',
      null,
      poolId.toUpperCase().split('-'),
      '0.005',
    );
    if (mounted) {
      setState(() {
        _price = output.amount;
      });
    }
  }

  Future<void> _onSupplyAmountChange(String v) async {
    String supply = v.trim();
    try {
      if (supply.isEmpty || double.parse(supply) == 0) {
        return;
      }
    } catch (err) {
      return;
    }
    setState(() {
      _amountBaseCoinCtrl.text =
          (double.parse(supply) * _price).toStringAsFixed(6);
    });
    _formKey.currentState.validate();
  }

  Future<void> _onTargetAmountChange(String v) async {
    String target = v.trim();
    try {
      if (target.isEmpty || double.parse(target) == 0) {
        return;
      }
    } catch (err) {
      return;
    }
    setState(() {
      _amountTokenCtrl.text =
          (double.parse(target) / _price).toStringAsFixed(6);
    });
    _formKey.currentState.validate();
  }

  void _onSubmit() {
    if (_formKey.currentState.validate()) {
      final String poolId = ModalRoute.of(context).settings.arguments;
      final pair = poolId.toUpperCase().split('-');
      int decimals = store.settings.networkState.tokenDecimals;
      String amountToken = _amountTokenCtrl.text.trim();
      String amountBaseCoin = _amountBaseCoinCtrl.text.trim();
      var args = {
        "title": I18n.of(context).acala['earn.deposit'],
        "txInfo": {
          "module": 'dex',
          "call": 'addLiquidity',
        },
        "detail": jsonEncode({
          "poolId": poolId,
          "amount": [amountToken, amountBaseCoin],
        }),
        "params": [
          {'Token': pair[0]},
          {'Token': pair[1]},
          Fmt.tokenInt(amountToken, decimals).toString(),
          Fmt.tokenInt(amountBaseCoin, decimals).toString(),
        ],
        "onFinish": (BuildContext txPageContext, Map res) {
          res['action'] = TxDexLiquidityData.actionDeposit;
          res['params'] = [poolId, res['params'][2], res['params'][3]];
          store.acala.setDexLiquidityTxs([res]);
          Navigator.popUntil(
              txPageContext, ModalRoute.withName(EarnPage.route));
          globalDexLiquidityRefreshKey.currentState.show();
        }
      };
      Navigator.of(context).pushNamed(TxConfirmPage.route, arguments: args);
    }
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refreshData();
    });
  }

  @override
  void dispose() {
    _amountTokenCtrl.dispose();
    _amountBaseCoinCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(_) {
    return Observer(
      builder: (BuildContext context) {
        final Map dic = I18n.of(context).acala;
        final Map dicAssets = I18n.of(context).assets;
        int decimals = store.settings.networkState.tokenDecimals;
        final String poolId = ModalRoute.of(context).settings.arguments;
        final tokenPair = poolId.split('-');

        final double inputWidth = MediaQuery.of(context).size.width / 3;

        double userShare = 0;
        double userShareNew = 0;

        double amountToken = 0;
        double amountStableCoin = 0;
        double amountTokenUser = 0;
        BigInt balanceTokenUser = Fmt.balanceInt(
            store.assets.tokenBalances[tokenPair[0].toUpperCase()]);
        BigInt balanceStableCoinUser = Fmt.balanceInt(
            store.assets.tokenBalances[tokenPair[1].toUpperCase()]);

        DexPoolInfoData poolInfo = store.acala.dexPoolInfoMap[poolId];
        if (poolInfo != null) {
          userShare = poolInfo.proportion;

          amountToken = Fmt.bigIntToDouble(poolInfo.amountToken, decimals);
          amountStableCoin =
              Fmt.bigIntToDouble(poolInfo.amountStableCoin, decimals);
          amountTokenUser = amountToken * userShare;

          String input = _amountTokenCtrl.text.trim();
          try {
            final double amountInput =
                double.parse(input.isEmpty ? '0' : input);
            userShareNew =
                (amountInput + amountTokenUser) / (amountInput + amountToken);
          } catch (_) {
            // parse double failed
          }
        }

        return Scaffold(
          appBar: AppBar(title: Text(dic['earn.deposit']), centerTitle: true),
          body: SafeArea(
            child: ListView(
              padding: EdgeInsets.all(16),
              children: <Widget>[
                RoundedCard(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Container(
                            width: inputWidth,
                            child: CurrencyWithIcon(
                              tokenPair[0],
                              textStyle: Theme.of(context).textTheme.headline4,
                            ),
                          ),
                          Expanded(
                            child: Icon(
                              Icons.add,
                            ),
                          ),
                          Container(
                            width: inputWidth,
                            child: CurrencyWithIcon(
                              tokenPair[1],
                              textStyle: Theme.of(context).textTheme.headline4,
                            ),
                          ),
                        ],
                      ),
                      Form(
                        key: _formKey,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Container(
                              width: inputWidth,
                              child: TextFormField(
                                decoration: InputDecoration(
                                  hintText: dicAssets['amount'],
                                  labelText: dicAssets['amount'],
                                  suffix: GestureDetector(
                                    child: Icon(
                                      CupertinoIcons.clear_thick_circled,
                                      color: Theme.of(context).disabledColor,
                                      size: 18,
                                    ),
                                    onTap: () {
                                      WidgetsBinding.instance
                                          .addPostFrameCallback(
                                              (_) => _amountTokenCtrl.clear());
                                    },
                                  ),
                                ),
                                inputFormatters: [
                                  UI.decimalInputFormatter(decimals)
                                ],
                                controller: _amountTokenCtrl,
                                keyboardType: TextInputType.numberWithOptions(
                                    decimal: true),
                                validator: (v) {
                                  try {
                                    if (v.trim().isEmpty ||
                                        double.parse(v.trim()) == 0) {
                                      return dicAssets['amount.error'];
                                    }
                                  } catch (err) {
                                    return dicAssets['amount.error'];
                                  }
                                  if (Fmt.tokenInt(v.trim(), decimals) >
                                      balanceTokenUser) {
                                    return dicAssets['amount.low'];
                                  }
                                  return null;
                                },
                                onChanged: (v) => _onSupplyAmountChange(v),
                              ),
                            ),
                            Container(
                              width: inputWidth,
                              child: TextFormField(
                                decoration: InputDecoration(
                                  hintText: dicAssets['amount'],
                                  labelText: dicAssets['amount'],
                                  suffix: GestureDetector(
                                    child: Icon(
                                      CupertinoIcons.clear_thick_circled,
                                      color: Theme.of(context).disabledColor,
                                      size: 18,
                                    ),
                                    onTap: () {
                                      WidgetsBinding.instance
                                          .addPostFrameCallback((_) =>
                                              _amountBaseCoinCtrl.clear());
                                    },
                                  ),
                                ),
                                inputFormatters: [
                                  UI.decimalInputFormatter(decimals)
                                ],
                                controller: _amountBaseCoinCtrl,
                                keyboardType: TextInputType.numberWithOptions(
                                    decimal: true),
                                validator: (v) {
                                  try {
                                    if (v.trim().isEmpty ||
                                        double.parse(v.trim()) == 0) {
                                      return dicAssets['amount.error'];
                                    }
                                  } catch (err) {
                                    return dicAssets['amount.error'];
                                  }
                                  if (Fmt.tokenInt(v.trim(), decimals) >
                                      balanceStableCoinUser) {
                                    return dicAssets['amount.low'];
                                  }
                                  return null;
                                },
                                onChanged: (v) => _onTargetAmountChange(v),
                              ),
                            )
                          ],
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(top: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Container(
                              width: inputWidth,
                              child: Text(
                                '${dicAssets['balance']}: ${Fmt.priceFloorBigInt(
                                  balanceTokenUser,
                                  decimals,
                                  lengthMax: 3,
                                )}',
                                style: TextStyle(
                                  fontSize: 14,
                                  color:
                                      Theme.of(context).unselectedWidgetColor,
                                ),
                              ),
                            ),
                            Container(
                              width: inputWidth,
                              child: Text(
                                '${dicAssets['balance']}: ${Fmt.priceFloorBigInt(
                                  balanceStableCoinUser,
                                  decimals,
                                  lengthMax: 2,
                                )}',
                                style: TextStyle(
                                  fontSize: 14,
                                  color:
                                      Theme.of(context).unselectedWidgetColor,
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                      Divider(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Expanded(
                            child: Text(
                              dic['dex.rate'],
                              style: TextStyle(
                                color: Theme.of(context).unselectedWidgetColor,
                              ),
                            ),
                          ),
                          Text(
                              '1 ${tokenPair[0]} = ${Fmt.doubleFormat(_price)} ${tokenPair[1]}'),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Expanded(
                            child: Text(
                              dic['earn.pool'],
                              style: TextStyle(
                                  color:
                                      Theme.of(context).unselectedWidgetColor),
                            ),
                          ),
                          Text(
                            '${Fmt.doubleFormat(amountToken)} ${tokenPair[0]}\n+ ${Fmt.doubleFormat(amountStableCoin, length: 2)} ${tokenPair[1]}',
                            textAlign: TextAlign.right,
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Expanded(
                            child: Text(
                              dic['earn.share'],
                              style: TextStyle(
                                  color:
                                      Theme.of(context).unselectedWidgetColor),
                            ),
                          ),
                          Text(Fmt.ratio(userShareNew)),
                        ],
                      )
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 24),
                  child: RoundedButton(
                    text: dic['earn.deposit'],
                    onPressed: _onSubmit,
                  ),
                )
              ],
            ),
          ),
        );
      },
    );
  }
}
