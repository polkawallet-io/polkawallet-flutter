import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:polka_wallet/common/components/outlinedButtonSmall.dart';
import 'package:polka_wallet/common/components/roundedButton.dart';
import 'package:polka_wallet/common/components/roundedCard.dart';
import 'package:polka_wallet/common/consts/settings.dart';
import 'package:polka_wallet/page-acala/earn/earnPage.dart';
import 'package:polka_wallet/page/account/txConfirmPage.dart';
import 'package:polka_wallet/service/substrateApi/api.dart';
import 'package:polka_wallet/store/acala/types/dexPoolInfoData.dart';
import 'package:polka_wallet/store/acala/types/txLiquidityData.dart';
import 'package:polka_wallet/store/app.dart';
import 'package:polka_wallet/utils/UI.dart';
import 'package:polka_wallet/utils/format.dart';
import 'package:polka_wallet/utils/i18n/index.dart';

class WithdrawLiquidityPage extends StatefulWidget {
  WithdrawLiquidityPage(this.store);

  static const String route = '/acala/earn/withdraw';

  final AppStore store;

  @override
  _WithdrawLiquidityPageState createState() =>
      _WithdrawLiquidityPageState(store);
}

class _WithdrawLiquidityPageState extends State<WithdrawLiquidityPage> {
  _WithdrawLiquidityPageState(this.store);

  final AppStore store;

  final _formKey = GlobalKey<FormState>();
  final TextEditingController _amountCtrl = new TextEditingController();

  BigInt _shareInput = BigInt.zero;
  double _price = 0;

  Future<void> _refreshData() async {
    final String poolId = ModalRoute.of(context).settings.arguments;
    webApi.assets.fetchBalance();
    await webApi.acala.fetchDexPoolInfo(poolId);

    final output = await webApi.acala.fetchTokenSwapAmount(
      '1',
      null,
      poolId.toUpperCase().split('-'),
      '0.005',
    );
    setState(() {
      _price = output.amount;
    });
  }

  void _onAmountChange(String v) {
    final int decimals = store.settings.networkState.tokenDecimals;
    String amountInput = v.trim();
    setState(() {
      _shareInput = Fmt.tokenInt(amountInput, decimals);
    });
    _formKey.currentState.validate();
  }

  void _onAmountSelect(BigInt v) {
    final int decimals = store.settings.networkState.tokenDecimals;
    setState(() {
      _shareInput = v;
      _amountCtrl.text = Fmt.bigIntToDouble(v, decimals).toStringAsFixed(2);
    });
    _formKey.currentState.validate();
  }

  void _onSubmit() {
    if (_formKey.currentState.validate()) {
      final String poolId = ModalRoute.of(context).settings.arguments;
      final pair = poolId.toUpperCase().split('-');
      String amount = _amountCtrl.text.trim();
      var args = {
        "title": I18n.of(context).acala['earn.withdraw'],
        "txInfo": {
          "module": 'dex',
          "call": 'removeLiquidity',
        },
        "detail": jsonEncode({
          "poolId": poolId,
          "amount": amount,
        }),
        "params": [
          {'Token': pair[0]},
          {'Token': pair[1]},
          _shareInput.toString(),
        ],
        "onFinish": (BuildContext txPageContext, Map res) {
          res['action'] = TxDexLiquidityData.actionWithdraw;
          res['params'] = [poolId, res['params'][2]];
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
    _amountCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(_) {
    return Observer(
      builder: (BuildContext context) {
        final Map dic = I18n.of(context).acala;
        final Map dicAssets = I18n.of(context).assets;
        final int decimals = store.settings.networkState.tokenDecimals;
        final String poolId = ModalRoute.of(context).settings.arguments;
        final pair = poolId.split('-');

        double shareTotal = 0;
        BigInt shareInt = BigInt.zero;
        BigInt shareInt10 = BigInt.zero;
        BigInt shareInt25 = BigInt.zero;
        BigInt shareInt50 = BigInt.zero;
        double share = 0;
        double shareRatioNew = 0;
        double shareInput = Fmt.bigIntToDouble(_shareInput, decimals);

        double poolToken = 0;
        double poolStableCoin = 0;
        double amountToken = 0;
        double amountStableCoin = 0;

        DexPoolInfoData poolInfo = store.acala.dexPoolInfoMap[poolId];
        if (poolInfo != null) {
          shareTotal = Fmt.bigIntToDouble(poolInfo.issuance, decimals);
          shareInt = Fmt.balanceInt(store.acala.lpTokens
              .firstWhere((e) => e.currencyId.join('-') == poolId.toUpperCase())
              .free);
          shareInt10 = BigInt.from(shareInt / BigInt.from(10));
          shareInt25 = BigInt.from(shareInt / BigInt.from(4));
          shareInt50 = BigInt.from(shareInt / BigInt.from(2));

          share = Fmt.bigIntToDouble(poolInfo.shares, decimals);

          poolToken = Fmt.bigIntToDouble(poolInfo.amountToken, decimals);
          poolStableCoin =
              Fmt.bigIntToDouble(poolInfo.amountStableCoin, decimals);

          amountToken = poolToken * shareInput / shareTotal;
          amountStableCoin = poolStableCoin * shareInput / shareTotal;

          shareRatioNew = (share - shareInput) / (shareTotal - shareInput);
        }

        return Scaffold(
          appBar: AppBar(title: Text(dic['earn.withdraw']), centerTitle: true),
          body: SafeArea(
            child: ListView(
              padding: EdgeInsets.all(16),
              children: <Widget>[
                RoundedCard(
                  padding: EdgeInsets.fromLTRB(16, 8, 16, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Form(
                        key: _formKey,
                        child: TextFormField(
                          decoration: InputDecoration(
                            hintText: dicAssets['amount'],
                            labelText:
                                '${dicAssets['amount']} (${dic['earn.available']}: ${Fmt.priceFloorBigInt(shareInt, decimals)} Shares)',
                            suffix: GestureDetector(
                              child: Icon(
                                CupertinoIcons.clear_thick_circled,
                                color: Theme.of(context).disabledColor,
                                size: 18,
                              ),
                              onTap: () {
                                WidgetsBinding.instance.addPostFrameCallback(
                                    (_) => _amountCtrl.clear());
                              },
                            ),
                          ),
                          inputFormatters: [UI.decimalInputFormatter(decimals)],
                          controller: _amountCtrl,
                          keyboardType:
                              TextInputType.numberWithOptions(decimal: true),
                          validator: (v) {
                            try {
                              if (v.trim().isEmpty ||
                                  double.parse(v.trim()) == 0) {
                                return dicAssets['amount.error'];
                              }
                            } catch (err) {
                              return dicAssets['amount.error'];
                            }
                            if (_shareInput > shareInt) {
                              return dicAssets['amount.low'];
                            }
                            return null;
                          },
                          onChanged: _onAmountChange,
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(top: 12),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: <Widget>[
                            OutlinedButtonSmall(
                              content: '10%',
                              active: _shareInput == shareInt10,
                              onPressed: () => _onAmountSelect(shareInt10),
                            ),
                            OutlinedButtonSmall(
                              content: '25%',
                              active: _shareInput == shareInt25,
                              onPressed: () => _onAmountSelect(shareInt25),
                            ),
                            OutlinedButtonSmall(
                              content: '50%',
                              active: _shareInput == shareInt50,
                              onPressed: () => _onAmountSelect(shareInt50),
                            ),
                            OutlinedButtonSmall(
                              margin: EdgeInsets.only(right: 0),
                              content: '100%',
                              active: _shareInput == shareInt,
                              onPressed: () => _onAmountSelect(shareInt),
                            )
                          ],
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(top: 16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Text(
                              '=',
                              style: Theme.of(context).textTheme.headline4,
                            ),
                            Text(
                              '${Fmt.doubleFormat(amountToken)} ${pair[0]} + ${Fmt.doubleFormat(amountStableCoin, length: 2)} ${pair[1]}',
                              style: Theme.of(context).textTheme.headline4,
                            ),
                          ],
                        ),
                      ),
                      Divider(height: 24),
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
                              '1 ${pair[0]} = ${Fmt.doubleFormat(_price, length: 2)} ${pair[1]}'),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Expanded(
                            child: Text(
                              dic['earn.pool'],
                              style: TextStyle(
                                color: Theme.of(context).unselectedWidgetColor,
                              ),
                            ),
                          ),
                          Text(
                            '${Fmt.doubleFormat(poolToken)} ${pair[0]}\n+ ${Fmt.doubleFormat(poolStableCoin, length: 2)} ${pair[1]}',
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
                                color: Theme.of(context).unselectedWidgetColor,
                              ),
                            ),
                          ),
                          Text(Fmt.ratio(shareRatioNew)),
                        ],
                      )
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 24),
                  child: RoundedButton(
                    text: dic['earn.withdraw'],
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
