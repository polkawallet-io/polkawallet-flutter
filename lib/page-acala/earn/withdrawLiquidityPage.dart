import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:polka_wallet/common/components/outlinedButtonSmall.dart';
import 'package:polka_wallet/common/components/roundedButton.dart';
import 'package:polka_wallet/common/components/roundedCard.dart';
import 'package:polka_wallet/common/regInputFormatter.dart';
import 'package:polka_wallet/page-acala/earn/earnPage.dart';
import 'package:polka_wallet/page/account/txConfirmPage.dart';
import 'package:polka_wallet/service/substrateApi/api.dart';
import 'package:polka_wallet/store/app.dart';
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

  final GlobalKey<RefreshIndicatorState> _refreshKey =
      new GlobalKey<RefreshIndicatorState>();

  final _formKey = GlobalKey<FormState>();
  final TextEditingController _amountCtrl = new TextEditingController();

  double _shareInput = 0;

  Future<void> _refreshData() async {
    String token = ModalRoute.of(context).settings.arguments;
    String pubKey = store.account.currentAccount.pubKey;
    webApi.acala.fetchTokens(pubKey);
    webApi.acala.fetchDexLiquidityPoolSwapRatios();
    webApi.acala.fetchDexLiquidityPool();
    webApi.acala.fetchDexLiquidityPoolShare(token);
  }

  void _onAmountChange(String v) {
    String amountInput = v.trim();
    setState(() {
      _shareInput = double.parse(amountInput.isEmpty ? '0' : amountInput);
    });
    _formKey.currentState.validate();
  }

  void _onAmountSelect(double v) {
    setState(() {
      _shareInput = v;
      _amountCtrl.text = v.toInt().toString();
    });
  }

  void _onSubmit() {
    if (_formKey.currentState.validate()) {
      String token = ModalRoute.of(context).settings.arguments;
      int decimals = store.settings.networkState.tokenDecimals;
      String amount = _amountCtrl.text.trim();
      var args = {
        "title": I18n.of(context).acala['earn.withdraw'],
        "txInfo": {
          "module": 'dex',
          "call": 'withdrawLiquidity',
        },
        "detail": jsonEncode({
          "currencyId": token,
          "amountOfShare": amount,
        }),
        "params": [
          token,
          Fmt.tokenInt(amount, decimals: decimals).toString(),
        ],
        "onFinish": (BuildContext txPageContext, Map res) {
//          print(res);
          store.acala.setDexLiquidityTxs([res]);
          Navigator.popUntil(
              txPageContext, ModalRoute.withName(EarnPage.route));
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
        int decimals = store.settings.networkState.tokenDecimals;
        String token = ModalRoute.of(context).settings.arguments;

        double shareTotal = Fmt.balanceDouble(
            (store.acala.swapPoolSharesTotal[token] ?? BigInt.zero).toString(),
            decimals: decimals);
        double share = Fmt.balanceDouble(
            (store.acala.swapPoolShares[token] ?? BigInt.zero).toString(),
            decimals: decimals);

        List pool = store.acala.swapPool[token];
        double poolToken = Fmt.balanceDouble(
            pool != null ? pool[0].toString() : '',
            decimals: decimals);
        double poolStableCoin = Fmt.balanceDouble(
            pool != null ? pool[1].toString() : '',
            decimals: decimals);

        print(_shareInput);
        double userShareRatio =
            (share - _shareInput) / (shareTotal - _shareInput);

        double amountToken = poolToken * _shareInput / shareTotal;
        double amountBaseCoin = poolStableCoin * _shareInput / shareTotal;

        double swapRatio =
            double.parse(store.acala.swapPoolRatios[token].toString());

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
                            hintText: dic['dex.pay'],
                            labelText:
                                '${dic['dex.pay']} (${dic['earn.available']}: ${Fmt.priceFloor(store.acala.swapPoolShares[token], lengthFixed: 0)})',
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
                          inputFormatters: [
                            RegExInputFormatter.withRegex(
                                '^[0-9]{0,$decimals}\$')
                          ],
                          controller: _amountCtrl,
                          keyboardType:
                              TextInputType.numberWithOptions(decimal: false),
                          validator: (v) {
                            if (v.isEmpty) {
                              return dicAssets['amount.error'];
                            }
                            if (double.parse(v.trim()) > share) {
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
                              active: _shareInput == share / 10,
                              onPressed: () => _onAmountSelect(share / 10),
                            ),
                            OutlinedButtonSmall(
                              content: '25%',
                              active: _shareInput == share / 4,
                              onPressed: () => _onAmountSelect(share / 4),
                            ),
                            OutlinedButtonSmall(
                              content: '50%',
                              active: _shareInput == share / 2,
                              onPressed: () => _onAmountSelect(share / 2),
                            ),
                            OutlinedButtonSmall(
                              margin: EdgeInsets.only(right: 0),
                              content: '100%',
                              active: _shareInput == share,
                              onPressed: () => _onAmountSelect(share),
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
                              style: Theme.of(context).textTheme.display4,
                            ),
                            Text(
                              '${Fmt.doubleFormat(amountToken)} $token + ${Fmt.doubleFormat(amountBaseCoin, length: 2)} ${store.acala.acalaBaseCoin}',
                              style: Theme.of(context).textTheme.display4,
                            ),
                          ],
                        ),
                      ),
                      Divider(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Text(
                            dic['dex.rate'],
                            style: TextStyle(
                                color: Theme.of(context).unselectedWidgetColor),
                          ),
                          Text(
                              '1 $token = ${Fmt.doubleFormat(swapRatio, length: 2)} ${store.acala.acalaBaseCoin}'),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Text(
                            dic['earn.pool'],
                            style: TextStyle(
                                color: Theme.of(context).unselectedWidgetColor),
                          ),
                          Text(
                              '${Fmt.doubleFormat(poolToken)} $token + ${Fmt.doubleFormat(poolStableCoin, length: 2)} ${store.acala.acalaBaseCoin}'),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Text(
                            dic['earn.share'],
                            style: TextStyle(
                                color: Theme.of(context).unselectedWidgetColor),
                          ),
                          Text(Fmt.ratio(userShareRatio)),
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
