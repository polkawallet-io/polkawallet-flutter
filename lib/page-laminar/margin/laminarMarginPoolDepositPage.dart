import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:polka_wallet/common/components/addressFormItem.dart';
import 'package:polka_wallet/common/components/infoItemRow.dart';
import 'package:polka_wallet/common/components/roundedButton.dart';
import 'package:polka_wallet/common/consts/settings.dart';
import 'package:polka_wallet/page-laminar/margin/laminarMarginPage.dart';
import 'package:polka_wallet/page/account/txConfirmPage.dart';
import 'package:polka_wallet/service/substrateApi/api.dart';
import 'package:polka_wallet/store/app.dart';
import 'package:polka_wallet/utils/UI.dart';
import 'package:polka_wallet/utils/format.dart';
import 'package:polka_wallet/utils/i18n/index.dart';

class LaminarMarginPoolDepositPageParams {
  LaminarMarginPoolDepositPageParams({this.poolId, this.isWithdraw = false});
  String poolId;
  bool isWithdraw;
}

class LaminarMarginPoolDepositPage extends StatefulWidget {
  LaminarMarginPoolDepositPage(this.store);

  static const String route = '/laminar/margin/pool';
  final AppStore store;

  @override
  _LaminarMarginPoolDepositPageState createState() =>
      _LaminarMarginPoolDepositPageState();
}

class _LaminarMarginPoolDepositPageState
    extends State<LaminarMarginPoolDepositPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _amountCtrl = new TextEditingController();

  Future<void> _onSubmit() async {
    if (_formKey.currentState.validate()) {
      final LaminarMarginPoolDepositPageParams params =
          ModalRoute.of(context).settings.arguments;
      final String amt = _amountCtrl.text.trim();
      var args = {
        "title": I18n.of(context)
            .laminar[params.isWithdraw ? 'margin.withdraw' : 'margin.deposit'],
        "txInfo": {
          "module": 'marginProtocol',
          "call": params.isWithdraw ? 'withdraw' : 'deposit',
        },
        "detail": jsonEncode({
          "pool": margin_pool_name_map[params.poolId],
          "amount": '$amt aUSD',
        }),
        "params": [
          // params.poolId
          params.poolId,
          // params.amount
          Fmt.tokenInt(amt, widget.store.settings.networkState.tokenDecimals)
              .toString(),
        ],
        "onFinish": (BuildContext txPageContext, Map res) {
//          print(res);
          Navigator.popUntil(
              txPageContext, ModalRoute.withName(LaminarMarginPage.route));
          globalMarginRefreshKey.currentState.show();
        }
      };
      Navigator.of(context).pushNamed(TxConfirmPage.route, arguments: args);
    }
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final LaminarMarginPoolDepositPageParams params =
          ModalRoute.of(context).settings.arguments;
      if (params.isWithdraw) {
        webApi.laminar.subscribeMarginTraderInfo();
      } else {
        webApi.assets.fetchBalance();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final Map dic = I18n.of(context).laminar;
    final Map dicAssets = I18n.of(context).assets;
    final LaminarMarginPoolDepositPageParams params =
        ModalRoute.of(context).settings.arguments;
    final int decimals = widget.store.settings.networkState.tokenDecimals;
    final double balance = params.isWithdraw
        ? Fmt.balanceDouble(
            widget.store.laminar.marginTraderInfo[params.poolId].freeMargin,
            decimals)
        : Fmt.balanceDouble(
            widget.store.assets.tokenBalances[acala_stable_coin], decimals);
    return Scaffold(
      appBar: AppBar(
        title: Text(
            params.isWithdraw ? dic['margin.withdraw'] : dic['margin.deposit']),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Expanded(
              child: ListView(
                padding: EdgeInsets.all(16),
                children: <Widget>[
                  AddressFormItem(
                    widget.store.account.currentAccount,
                    label:
                        params.isWithdraw ? dicAssets['to'] : dicAssets['from'],
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 16),
                    child: InfoItemRow(
                      dic['margin.pool'],
                      margin_pool_name_map[params.poolId],
                    ),
                  ),
                  Form(
                    key: _formKey,
                    child: TextFormField(
                      decoration: InputDecoration(
                        hintText: dicAssets['amount'],
                        labelText:
                            '${dicAssets['amount']} (${dicAssets['available']} ${balance.toStringAsFixed(3)} aUSD)',
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
                        if (v.isEmpty) {
                          return dicAssets['amount.error'];
                        }
                        if (double.parse(v.trim()) > balance) {
                          return dicAssets['amount.low'];
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.all(16),
              child: RoundedButton(
                text: I18n.of(context).home['submit.tx'],
                onPressed: () => _onSubmit(),
              ),
            )
          ],
        ),
      ),
    );
  }
}
