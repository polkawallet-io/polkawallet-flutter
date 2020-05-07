import 'dart:convert';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:polka_wallet/common/components/currencyWithIcon.dart';
import 'package:polka_wallet/common/components/roundedButton.dart';
import 'package:polka_wallet/common/components/roundedCard.dart';
import 'package:polka_wallet/common/consts/settings.dart';
import 'package:polka_wallet/common/regInputFormatter.dart';
import 'package:polka_wallet/page-acala/swap/swapHistoryPage.dart';
import 'package:polka_wallet/page/account/txConfirmPage.dart';
import 'package:polka_wallet/service/substrateApi/api.dart';
import 'package:polka_wallet/store/app.dart';
import 'package:polka_wallet/utils/format.dart';
import 'package:polka_wallet/utils/i18n/index.dart';

class MintPage extends StatefulWidget {
  MintPage(this.store);

  static const String route = '/acala/homa/mint';
  final AppStore store;

  @override
  _MintPageState createState() => _MintPageState(store);
}

class _MintPageState extends State<MintPage> {
  _MintPageState(this.store);

  final AppStore store;

  final GlobalKey<RefreshIndicatorState> _refreshKey =
      new GlobalKey<RefreshIndicatorState>();

  final _formKey = GlobalKey<FormState>();
  final TextEditingController _amountPayCtrl = new TextEditingController();

  Future<void> _refreshData() async {
    String pubKey = store.account.currentAccount.pubKey;
    webApi.assets.fetchBalance(pubKey);
    webApi.acala.fetchTokenSwapRatio();

    // then fetch txs history
  }

  void _onSupplyAmountChange(String v) {
    String supply = v.trim();
    if (supply.isEmpty) {
      return;
    }
    _calcSwapAmount(supply, null);
  }

  Future<void> _calcSwapAmount(String supply, String target) async {
    List<String> swapPair = store.acala.currentSwapPair;
    if (supply == null) {
      if (target.isNotEmpty) {
        String output = await webApi.acala
            .fetchTokenSwapAmount(supply, target, swapPair, '0');
        setState(() {
          _amountPayCtrl.text = output;
        });
        _formKey.currentState.validate();
      }
    } else if (target == null) {
      if (supply.isNotEmpty) {
        String output = await webApi.acala
            .fetchTokenSwapAmount(supply, target, swapPair, '0');
        _formKey.currentState.validate();
      }
    }
  }

  void _onSubmit() {
    if (_formKey.currentState.validate()) {
      int decimals = store.settings.networkState.tokenDecimals;
      List<String> swapPair = store.acala.currentSwapPair;
      String pay = _amountPayCtrl.text.trim();
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
        }),
        "params": [
          // params.supply
          swapPair[0],
          Fmt.tokenInt(pay, decimals: decimals).toString(),
          // params.target
          swapPair[1],
        ],
        "onFinish": (BuildContext txPageContext, Map res) {
//          print(res);
          store.acala.setSwapTxs([res]);
          Navigator.popUntil(
              txPageContext, ModalRoute.withName(MintPage.route));
          _refreshKey.currentState.show();
        }
      };
      Navigator.of(context).pushNamed(TxConfirmPage.route, arguments: args);
    }
  }

  @override
  void initState() {
    super.initState();
    List currencyIds = store.acala.swapTokens;
    if (currencyIds != null) {
      store.acala
          .setSwapPair([store.acala.swapTokens[0], acala_stable_coin_view]);
      _refreshData();
    }
  }

  @override
  void dispose() {
    _amountPayCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(_) {
    return Observer(
      builder: (BuildContext context) {
        final Map dic = I18n.of(context).acala;
        final Map dicAssets = I18n.of(context).assets;
        int decimals = store.settings.networkState.tokenDecimals;
        List<String> swapPair = store.acala.currentSwapPair;

        final double inputWidth = MediaQuery.of(context).size.width / 3;

        BigInt balance = BigInt.zero;
        if (store.acala.swapTokens != null && swapPair.length > 0) {
          balance = Fmt.balanceInt(
              store.assets.tokenBalances[swapPair[0].toUpperCase()]);
        }

        Color primary = Theme.of(context).primaryColor;
        Color grey = Theme.of(context).unselectedWidgetColor;
        Color lightGrey = Theme.of(context).dividerColor;

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
                    child: swapPair.length == 2
                        ? Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  CurrencyWithIcon(
                                    'DOT',
                                    textWidth: 48,
                                    textStyle:
                                        Theme.of(context).textTheme.display4,
                                    trailing: Icon(Icons.keyboard_arrow_down),
                                  ),
                                  Icon(
                                    Icons.repeat,
                                    color: Theme.of(context).primaryColor,
                                  ),
                                  CurrencyWithIcon(
                                    'LDOT',
                                    textWidth: 48,
                                    textStyle:
                                        Theme.of(context).textTheme.display4,
                                    trailing: Icon(Icons.keyboard_arrow_down),
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
                                      child: Text('10。03'),
                                    )
                                  ],
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.only(top: 8),
                                child: Text(
                                  '${dicAssets['balance']}: ${Fmt.token(balance, decimals: decimals)} DOT}',
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
                                            '1 DOT = ${store.acala.swapRatio} L-DOT'),
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
                  Padding(
                    padding: EdgeInsets.only(top: 24),
                    child: RoundedButton(
                      text: dic['homa.mint'],
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
