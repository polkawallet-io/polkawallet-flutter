import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:polka_wallet/common/components/roundedButton.dart';
import 'package:polka_wallet/page-acala/earn/earnPage.dart';
import 'package:polka_wallet/page/account/txConfirmPage.dart';
import 'package:polka_wallet/store/acala/types/dexPoolInfoData.dart';
import 'package:polka_wallet/store/acala/types/txLiquidityData.dart';
import 'package:polka_wallet/store/app.dart';
import 'package:polka_wallet/utils/UI.dart';
import 'package:polka_wallet/utils/format.dart';
import 'package:polka_wallet/utils/i18n/index.dart';

class LPStakePageParams {
  LPStakePageParams(this.poolId, this.action);
  final String action;
  final String poolId;
}

class LPStakePage extends StatefulWidget {
  LPStakePage(this.store);

  static const String route = '/acala/earn/stake';
  static const String actionStake = 'stake';
  static const String actionUnStake = 'unStake';
  final AppStore store;

  @override
  _LPStakePage createState() => _LPStakePage();
}

class _LPStakePage extends State<LPStakePage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _amountCtrl = new TextEditingController();

  bool _isMax = false;

  String _validateAmount(String value, BigInt available, int decimals) {
    final Map assetDic = I18n.of(context).assets;

    String v = value.trim();
    try {
      if (v.isEmpty || double.parse(v) == 0) {
        return assetDic['amount.error'];
      }
    } catch (err) {
      return assetDic['amount.error'];
    }
    BigInt input = Fmt.tokenInt(v, decimals);
    if (!_isMax && input > available) {
      return assetDic['amount.low'];
    }
    return null;
  }

  void _onSetMax(BigInt max, int decimals) {
    setState(() {
      _amountCtrl.text = Fmt.priceFloorBigInt(max, decimals);
      _isMax = true;
    });
  }

  void _onSubmit(BigInt max, int decimals) {
    final dic = I18n.of(context).acala;
    final LPStakePageParams params = ModalRoute.of(context).settings.arguments;
    final isStake = params.action == LPStakePage.actionStake;
    final pool = params.poolId.split('-').map((e) => e.toUpperCase()).toList();
    String input = _amountCtrl.text.trim();
    BigInt amount = Fmt.tokenInt(input, decimals);
    if (_isMax || max - amount < BigInt.one) {
      amount = max;
      input = Fmt.token(max, decimals);
    }
    final args = {
      "title":
          '${dic['earn.${params.action}']} ${Fmt.tokenView(params.poolId)}',
      "txInfo": {
        "module": 'incentives',
        "call": isStake ? 'depositDexShare' : 'withdrawDexShare',
      },
      "detail": jsonEncode({
        "poolId": params.poolId,
        "amount": input,
      }),
      "params": [
        {'DEXShare': pool},
        amount.toString()
      ],
      "onFinish": (BuildContext txPageContext, Map res) {
        res['action'] = isStake
            ? TxDexLiquidityData.actionStake
            : TxDexLiquidityData.actionUnStake;
        res['params'] = [params.poolId, amount.toString()];
        widget.store.acala.setDexLiquidityTxs([res]);
        Navigator.popUntil(txPageContext, ModalRoute.withName(EarnPage.route));
        globalDexLiquidityRefreshKey.currentState.show();
      }
    };
    Navigator.of(context).pushNamed(TxConfirmPage.route, arguments: args);
  }

  @override
  Widget build(BuildContext context) {
    final dic = I18n.of(context).acala;
    final assetDic = I18n.of(context).assets;
    final LPStakePageParams args = ModalRoute.of(context).settings.arguments;
    final decimals = widget.store.settings.networkState.tokenDecimals;
    return Scaffold(
      appBar: AppBar(
        title:
            Text('${dic['earn.${args.action}']} ${Fmt.tokenView(args.poolId)}'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Observer(
          builder: (_) {
            final DexPoolInfoData poolInfo =
                widget.store.acala.dexPoolInfoMap[args.poolId];
            final isStake = args.action == LPStakePage.actionStake;

            BigInt balance = BigInt.zero;
            if (!isStake) {
              balance = poolInfo.shares;
            } else {
              final balanceIndex = widget.store.acala.lpTokens.indexWhere(
                  (e) => e.currencyId.join('-') == args.poolId.toUpperCase());
              if (balanceIndex >= 0) {
                balance = Fmt.balanceInt(
                    widget.store.acala.lpTokens[balanceIndex].free);
              }
            }

            final balanceView =
                Fmt.priceFloorBigInt(balance, decimals, lengthMax: 6);
            return Column(
              children: [
                Expanded(
                  child: Form(
                    key: _formKey,
                    child: ListView(
                      padding: EdgeInsets.only(left: 16, right: 16),
                      children: [
                        TextFormField(
                          decoration: InputDecoration(
                            hintText: assetDic['amount'],
                            labelText:
                                '${assetDic['amount']} (${assetDic['available']}: $balanceView)',
                            suffix: GestureDetector(
                              child: Text(
                                dic['loan.max'],
                                style: TextStyle(
                                    color: Theme.of(context).primaryColor),
                              ),
                              onTap: () => _onSetMax(balance, decimals),
                            ),
                          ),
                          inputFormatters: [UI.decimalInputFormatter(decimals)],
                          controller: _amountCtrl,
                          keyboardType:
                              TextInputType.numberWithOptions(decimal: true),
                          validator: (v) =>
                              _validateAmount(v, balance, decimals),
                          onChanged: (_) {
                            if (_isMax) {
                              setState(() {
                                _isMax = false;
                              });
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(16),
                  child: RoundedButton(
                    text: dic['earn.${args.action}'],
                    onPressed: () => _onSubmit(balance, decimals),
                  ),
                )
              ],
            );
          },
        ),
      ),
    );
  }
}
