import 'dart:async';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:polka_wallet/common/components/currencyWithIcon.dart';
import 'package:polka_wallet/common/components/roundedButton.dart';
import 'package:polka_wallet/common/components/roundedCard.dart';
import 'package:polka_wallet/common/consts/settings.dart';
import 'package:polka_wallet/page-acala/homa/homaHistoryPage.dart';
import 'package:polka_wallet/page-acala/homa/homaPage.dart';
import 'package:polka_wallet/page/account/txConfirmPage.dart';
import 'package:polka_wallet/service/substrateApi/api.dart';
import 'package:polka_wallet/store/acala/types/stakingPoolInfoData.dart';
import 'package:polka_wallet/store/acala/types/txHomaData.dart';
import 'package:polka_wallet/store/app.dart';
import 'package:polka_wallet/utils/UI.dart';
import 'package:polka_wallet/utils/format.dart';
import 'package:polka_wallet/utils/i18n/index.dart';

class HomaRedeemPage extends StatefulWidget {
  HomaRedeemPage(this.store);

  static const String route = '/acala/homa/redeem';
  final AppStore store;

  @override
  _HomaRedeemPageState createState() => _HomaRedeemPageState(store);
}

class _HomaRedeemPageState extends State<HomaRedeemPage> {
  _HomaRedeemPageState(this.store);

  final AppStore store;

  final GlobalKey<RefreshIndicatorState> _refreshKey =
      new GlobalKey<RefreshIndicatorState>();

  final _formKey = GlobalKey<FormState>();
  final TextEditingController _amountPayCtrl = new TextEditingController();
  final TextEditingController _amountReceiveCtrl = new TextEditingController();

  int _radioSelect = 0;
  int _eraSelected = 0;
  double _fee = 0;

  Timer _timer;

  Future<void> _refreshData() async {
    webApi.acala.fetchTokens(store.account.currentAccount.pubKey);
    await webApi.acala.fetchHomaStakingPool();
    // if (_amountReceiveCtrl.text.isEmpty) {
    //   await _updateReceiveAmount(0);
    // }
  }

  Future<void> _updateReceiveAmount(double input) async {
    if (input == null || input == 0) return;

    final era = store.acala.stakingPoolInfo.freeList[_eraSelected].era;
    final res = await webApi.evalJavascript(
      'acala.queryHomaRedeemAmount($input, $_radioSelect, $era)',
      allowRepeat: true,
    );
    double fee = 0;
    double amount = 0;
    if (res['fee'] != null) {
      fee = res['fee'];
      amount = res['received'];
    } else {
      amount = res['amount'];
    }

    if (mounted) {
      setState(() {
        _amountReceiveCtrl.text = amount.toStringAsFixed(6);
        _fee = fee;
      });
      _formKey.currentState.validate();
    }
  }

  void _onSupplyAmountChange(String v) {
    String supply = v.trim();
    if (supply.isEmpty) {
      return;
    }

    if (_timer != null) {
      _timer.cancel();
    }
    _timer = Timer(Duration(seconds: 1), () {
      _updateReceiveAmount(double.parse(supply));
    });
  }

  Future<void> _onRadioChange(int value) async {
    if (value == 1) {
      final Map dic = I18n.of(context).acala;
      StakingPoolInfoData pool = store.acala.stakingPoolInfo;
      if (pool.freeList.length == 0) return;

      if (pool.freeList.length > 1) {
        await showCupertinoModalPopup(
          context: context,
          builder: (_) => Container(
            height: MediaQuery.of(context).copyWith().size.height / 3,
            child: CupertinoPicker(
              backgroundColor: Colors.white,
              itemExtent: 58,
              scrollController: FixedExtentScrollController(
                initialItem: _eraSelected,
              ),
              children: pool.freeList.map((i) {
                return Padding(
                  padding: EdgeInsets.all(16),
                  child: Text(
                    'Era ${i.era}, ${dic['homa.redeem.free']} ${Fmt.priceFloor(i.free)}',
                    style: TextStyle(fontSize: 14),
                  ),
                );
              }).toList(),
              onSelectedItemChanged: (v) {
                setState(() {
                  _eraSelected = v;
                });
              },
            ),
          ),
        );
      }
    }
    setState(() {
      _radioSelect = value;
    });
    _updateReceiveAmount(double.parse(_amountPayCtrl.text.trim()));
  }

  void _onSubmit() {
    if (_formKey.currentState.validate()) {
      int decimals = store.settings.networkState.tokenDecimals;
      String pay = _amountPayCtrl.text.trim();
      String receive = Fmt.priceFloor(
        double.parse(_amountReceiveCtrl.text),
        lengthMax: 4,
      );
      String strategy = TxHomaData.redeemTypeNow;
      if (_radioSelect == 2) {
        strategy = TxHomaData.redeemTypeWait;
      }
      int era = 0;
      StakingPoolInfoData pool = store.acala.stakingPoolInfo;
      if (pool.freeList.length > 0) {
        era = pool.freeList[_eraSelected].era;
      }
      var args = {
        "title": I18n.of(context).acala['homa.redeem'],
        "txInfo": {
          "module": 'homa',
          "call": 'redeem',
        },
        "detail": jsonEncode({
          "amountPay": pay,
          "amountReceive": receive,
          "strategy": _radioSelect == 1 ? 'Era $era' : strategy,
        }),
        "params": [
          Fmt.tokenInt(pay, decimals).toString(),
          _radioSelect == 1 ? {"Target": era} : strategy
        ],
        "onFinish": (BuildContext txPageContext, Map res) {
//          print(res);
          res['action'] = TxHomaData.actionRedeem;
          res['amountReceive'] = receive;
          store.acala.setHomaTxs([res]);
          Navigator.popUntil(
              txPageContext, ModalRoute.withName(HomaPage.route));
          globalHomaRefreshKey.currentState.show();
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
        int decimals = store.settings.networkState.tokenDecimals;

        BigInt balance = Fmt.balanceInt(store.assets.tokenBalances['LDOT']);

        StakingPoolInfoData pool = store.acala.stakingPoolInfo;

        Color primary = Theme.of(context).primaryColor;
        Color grey = Theme.of(context).unselectedWidgetColor;

        final availableNow = pool.communalTotal * pool.communalFreeRatio;
        double available = 0;
        String eraSelectText = dic['homa.era'];
        String eraSelectTextTail = '';
        if (pool.freeList.length > 0) {
          StakingPoolFreeItemData item = pool.freeList[_eraSelected];
          available = item.free;
          eraSelectText += ': ${item.era}';
          eraSelectTextTail =
              '(≈ ${(item.era - pool.currentEra).toInt()}${dic['homa.redeem.day']}, ${dicAssets['available']}: ${Fmt.priceFloor(pool.freeList[_eraSelected].free, lengthMax: 3)} DOT)';
        }

        return Scaffold(
          appBar: AppBar(title: Text(dic['homa.redeem']), centerTitle: true),
          body: SafeArea(
            child: RefreshIndicator(
              key: _refreshKey,
              onRefresh: _refreshData,
              child: ListView(
                padding: EdgeInsets.all(16),
                children: <Widget>[
                  RoundedCard(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Form(
                          key: _formKey,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    CurrencyWithIcon(
                                      'LDOT',
                                      textStyle:
                                          Theme.of(context).textTheme.headline4,
                                    ),
                                    TextFormField(
                                      decoration: InputDecoration(
                                        hintText: dic['dex.pay'],
                                        labelText: dic['dex.pay'],
                                        suffix: GestureDetector(
                                          child: Icon(
                                            CupertinoIcons.clear_thick_circled,
                                            color:
                                                Theme.of(context).disabledColor,
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
                                        UI.decimalInputFormatter(decimals)
                                      ],
                                      controller: _amountPayCtrl,
                                      keyboardType:
                                          TextInputType.numberWithOptions(
                                              decimal: true),
                                      validator: (v) {
                                        double amt;
                                        try {
                                          amt = double.parse(v.trim());
                                          if (v.trim().isEmpty || amt == 0) {
                                            return dicAssets['amount.error'];
                                          }
                                        } catch (err) {
                                          return dicAssets['amount.error'];
                                        }
                                        if (amt >=
                                            Fmt.bigIntToDouble(
                                                balance, decimals)) {
                                          return dicAssets['amount.low'];
                                        }
                                        final input = double.parse(v.trim()) *
                                            pool.liquidExchangeRate;
                                        if (_radioSelect == 0 &&
                                            input > availableNow) {
                                          return dic['homa.pool.low'];
                                        }
                                        if (_radioSelect == 1 &&
                                            input > available) {
                                          return dic['homa.pool.low'];
                                        }
                                        return null;
                                      },
                                      onChanged: _onSupplyAmountChange,
                                    ),
                                    Padding(
                                      padding: EdgeInsets.only(top: 8),
                                      child: Text(
                                        '${dicAssets['balance']}: ${Fmt.token(balance, decimals)} LDOT',
                                        style: TextStyle(
                                            color: Theme.of(context)
                                                .unselectedWidgetColor),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.fromLTRB(8, 2, 8, 0),
                                child: Icon(
                                  Icons.repeat,
                                  color: Theme.of(context).primaryColor,
                                ),
                              ),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    CurrencyWithIcon(
                                      'DOT',
                                      textStyle:
                                          Theme.of(context).textTheme.headline4,
                                    ),
                                    TextFormField(
                                      decoration: InputDecoration(
                                        labelText: dic['dex.receive'],
                                        suffix: Container(
                                          height: 16,
                                          width: 8,
                                        ),
                                      ),
                                      controller: _amountReceiveCtrl,
                                      readOnly: true,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        Divider(),
                        Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text(
                                    dic['dex.rate'],
                                    style: TextStyle(
                                        color: Theme.of(context)
                                            .unselectedWidgetColor),
                                  ),
                                  Text(
                                      '1 LDOT = ${Fmt.priceFloor(pool.liquidExchangeRate, lengthMax: 3)} DOT'),
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
                                    .pushNamed(HomaHistoryPage.route),
                              ),
                            ])
                      ],
                    ),
                  ),
                  RoundedCard(
                    margin: EdgeInsets.only(top: 16),
                    padding: EdgeInsets.fromLTRB(0, 8, 16, 8),
                    child: Column(
                      children: <Widget>[
                        Container(
                          padding: EdgeInsets.fromLTRB(16, 16, 0, 8),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Text('${dic['homa.redeem.fee']}:'),
                              Text('(≈ ${Fmt.doubleFormat(_fee)} DOT)'),
                            ],
                          ),
                        ),
                        Divider(height: 4),
                        GestureDetector(
                          child: Row(
                            children: <Widget>[
                              Radio(
                                value: 0,
                                groupValue: _radioSelect,
                                onChanged: (v) => _onRadioChange(v),
                              ),
                              Expanded(
                                child: Text(dic['homa.now']),
                              ),
                              Text(
                                '(${dic['homa.redeem.free']}: ${Fmt.priceFloor(availableNow)} DOT)',
                                style: TextStyle(fontSize: 14),
                              ),
                            ],
                          ),
                          onTap: () => _onRadioChange(0),
                        ),
                        GestureDetector(
                          child: Row(
                            children: <Widget>[
                              Radio(
                                value: 1,
                                groupValue: _radioSelect,
                                onChanged: (v) => _onRadioChange(v),
                              ),
                              Expanded(
                                child: Text(
                                  eraSelectText,
                                  style: pool.freeList.length == 0
                                      ? TextStyle(color: grey)
                                      : null,
                                ),
                              ),
                              Text(
                                eraSelectTextTail,
                                style: pool.freeList.length == 0
                                    ? TextStyle(color: grey)
                                    : null,
                              ),
                            ],
                          ),
                          onTap: () => _onRadioChange(1),
                        ),
                        GestureDetector(
                          child: Row(
                            children: <Widget>[
                              Radio(
                                value: 2,
                                groupValue: _radioSelect,
                                onChanged: (v) => _onRadioChange(v),
                              ),
                              Expanded(
                                child: Text(dic['homa.unbond']),
                              ),
                              Text(
                                '(${pool.bondingDuration.toInt() + 1} Era ≈ ${(pool.unbondingDuration / 1000 ~/ SECONDS_OF_DAY) + 1} ${dic['homa.redeem.day']})',
                                style: TextStyle(fontSize: 14),
                              ),
                            ],
                          ),
                          onTap: () => _onRadioChange(2),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 24),
                    child: RoundedButton(
                      text: dic['homa.redeem'],
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
