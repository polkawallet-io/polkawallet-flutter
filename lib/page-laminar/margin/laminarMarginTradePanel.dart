import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:polka_wallet/common/components/infoItemRow.dart';
import 'package:polka_wallet/common/components/roundedButton.dart';
import 'package:polka_wallet/common/consts/settings.dart';
import 'package:polka_wallet/page-laminar/margin/laminarMarginPage.dart';
import 'package:polka_wallet/page-laminar/margin/laminarMarginTradePrice.dart';
import 'package:polka_wallet/page/account/txConfirmPage.dart';
import 'package:polka_wallet/service/substrateApi/api.dart';
import 'package:polka_wallet/store/laminar/types/laminarCurrenciesData.dart';
import 'package:polka_wallet/store/laminar/types/laminarMarginData.dart';
import 'package:polka_wallet/utils/UI.dart';
import 'package:polka_wallet/utils/format.dart';
import 'package:polka_wallet/utils/i18n/index.dart';

class LaminarMarginTradePanel extends StatefulWidget {
  LaminarMarginTradePanel({
    this.poolId,
    this.pairData,
    this.info,
    this.priceMap,
    this.decimals = acala_token_decimals,
    this.leverageIndex,
    this.onLeverageChange,
  });

  final String poolId;
  final LaminarMarginPairData pairData;
  final LaminarMarginTraderInfoData info;
  final Map<String, LaminarPriceData> priceMap;
  final int decimals;
  final int leverageIndex;
  final Function(int) onLeverageChange;

  @override
  _LaminarMarginTradePanelState createState() =>
      _LaminarMarginTradePanelState();
}

class _LaminarMarginTradePanelState extends State<LaminarMarginTradePanel> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _amountCtrl = new TextEditingController();

  double _calcCost(double value, BigInt price, double leverage) {
    return value * Fmt.bigIntToDouble(price, widget.decimals) / leverage;
  }

  Future<void> _onSelectLeverage(List<String> leverages) async {
    showCupertinoModalPopup(
      context: context,
      builder: (_) {
        return Container(
          height: MediaQuery.of(context).copyWith().size.height / 3,
          child: CupertinoPicker(
            backgroundColor: Colors.white,
            itemExtent: 56,
            scrollController:
                FixedExtentScrollController(initialItem: widget.leverageIndex),
            children: leverages
                .map((i) => Padding(
                    padding: EdgeInsets.all(12),
                    child: Text(
                      laminar_leverage_map[i],
                      style: TextStyle(fontSize: 16),
                    )))
                .toList(),
            onSelectedItemChanged: widget.onLeverageChange,
          ),
        );
      },
    );
  }

  Future<void> _onTrade(String leverage, {bool isSell = false}) async {
    if (_formKey.currentState.validate()) {
      print('trade: $isSell');
      final String amt = _amountCtrl.text.trim();
      final String lev = '${isSell ? 'Short' : 'Long'}$leverage';
      final Map pair = {
        'base': widget.pairData.pair.base,
        'quote': widget.pairData.pair.quote,
      };
      var args = {
        "title":
            I18n.of(context).laminar[isSell ? 'margin.sell' : 'margin.buy'],
        "txInfo": {
          "module": 'marginProtocol',
          "call": 'openPosition',
        },
        "detail": jsonEncode({
          "pool": margin_pool_name_map[widget.pairData.poolId],
          "pair": pair,
          "leverage": lev,
          "amount": '$amt ${widget.pairData.pair.base}',
        }),
        "params": [
          // params.poolId
          widget.pairData.poolId,
          // params.pair
          pair,
          // params.leverage
          lev,
          // params.amount
          Fmt.tokenInt(amt, widget.decimals).toString(),
          // params.price
          isSell ? '0' : Fmt.tokenInt('100000000', widget.decimals).toString(),
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
  Widget build(BuildContext context) {
    final Map dic = I18n.of(context).laminar;
    final Map dicAssets = I18n.of(context).assets;
    final bool isUSDBasedPair = widget.pairData.pair.base == acala_stable_coin;
    final String baseToken = Fmt.tokenView(widget.pairData.pair.base);
    final List<String> leverages = laminar_leverage_map.keys.toList();
    leverages.retainWhere((e) =>
        widget.pairData.enabledTrades.indexWhere((i) => i.contains(e)) >= 0);
    final BigInt freeInt = Fmt.balanceInt(widget.info?.freeMargin);
    final double free = Fmt.bigIntToDouble(freeInt, widget.decimals);
    final BigInt priceBuy = webApi.laminar.getTradePriceInt(
      prices: widget.priceMap,
      pairData: widget.pairData,
      direction: 'long',
    );
    final BigInt priceSell = webApi.laminar.getTradePriceInt(
      prices: widget.priceMap,
      pairData: widget.pairData,
      direction: 'short',
    );
    final double rawPriceQuote = Fmt.balanceDouble(
        widget.priceMap[widget.pairData.pair.quote]?.value, widget.decimals);
    final double leverage = double.parse(
        laminar_leverage_map[leverages[widget.leverageIndex]].substring(1));
    double amountBuyMax = freeInt / priceBuy * leverage;
    double amountSellMax = freeInt / priceSell * leverage;
    if (isUSDBasedPair) {
      amountBuyMax = amountBuyMax / rawPriceQuote;
      amountSellMax = amountSellMax / rawPriceQuote;
    }
    double costBuy = 0;
    double costSell = 0;
    if (_amountCtrl.text.trim().isNotEmpty) {
      try {
        final double input = double.parse(_amountCtrl.text.trim());
        costBuy = _calcCost(input, priceBuy, leverage);
        costSell = _calcCost(input, priceSell, leverage);
        if (isUSDBasedPair) {
          costBuy = costBuy * rawPriceQuote;
          costSell = costSell * rawPriceQuote;
        }
      } catch (err) {
        print('calc cost error');
      }
    }
    return Container(
      padding: EdgeInsets.all(16),
      child: Column(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(bottom: 16),
            child: InfoItemRow(
              dic['margin.free'],
              '${Fmt.token(freeInt, widget.decimals)} aUSD',
            ),
          ),
          GestureDetector(
            child: InfoItemRow(
              dic['margin.leverage'],
              laminar_leverage_map[leverages[widget.leverageIndex]],
              colorPrimary: true,
            ),
            onTap: () => _onSelectLeverage(leverages),
          ),
          Form(
            key: _formKey,
            child: TextFormField(
              decoration: InputDecoration(
                hintText: dicAssets['amount'],
                labelText: '${dicAssets['amount']} ($baseToken)',
                suffix: GestureDetector(
                  child: Icon(
                    CupertinoIcons.clear_thick_circled,
                    color: Theme.of(context).disabledColor,
                    size: 18,
                  ),
                  onTap: () {
                    WidgetsBinding.instance
                        .addPostFrameCallback((_) => _amountCtrl.clear());
                  },
                ),
              ),
              inputFormatters: [UI.decimalInputFormatter(widget.decimals)],
              controller: _amountCtrl,
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              validator: (v) {
                if (v.isEmpty) {
                  return dicAssets['amount.error'];
                }
//                double input = 0;
//                try {
//                  input = double.parse(v.trim());
//                } catch (err) {
//                  return dicAssets['amount.error'];
//                }
                if (costBuy > free || costSell > free) {
                  return dicAssets['amount.low'];
                }
                return null;
              },
            ),
          ),
          Padding(
            padding: EdgeInsets.only(bottom: 4, top: 12),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(dic['margin.ask']),
                      LaminarMarginTradePrice(
                        decimals: widget.decimals,
                        direction: 'long',
                        priceInt: priceBuy,
                        fontSize: 18,
                      )
                    ],
                  ),
                ),
                Container(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(dic['margin.bid']),
                      LaminarMarginTradePrice(
                        decimals: widget.decimals,
                        direction: 'short',
                        priceInt: priceSell,
                        fontSize: 18,
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
          Row(
            children: <Widget>[
              Expanded(
                child: RoundedButton(
                  text: dic['margin.buy'],
                  color: Colors.green,
                  onPressed: () => _onTrade(leverages[widget.leverageIndex]),
                ),
              ),
              Container(width: 16),
              Expanded(
                child: RoundedButton(
                  text: dic['margin.sell'],
                  color: Colors.red,
                  onPressed: () =>
                      _onTrade(leverages[widget.leverageIndex], isSell: true),
                ),
              )
            ],
          ),
          Padding(
            padding: EdgeInsets.only(top: 8, bottom: 8),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: Text(
                      '${dic['margin.cost']} ${costBuy.toStringAsFixed(2)} aUSD'),
                ),
                Container(width: 16),
                Expanded(
                  child: Text(
                      '${dic['margin.cost']} ${costSell.toStringAsFixed(2)} aUSD'),
                )
              ],
            ),
          ),
          Row(
            children: <Widget>[
              Expanded(
                child: Text(
                    '${dic['margin.max']} ${amountBuyMax.toStringAsFixed(isUSDBasedPair ? 2 : 5)} $baseToken'),
              ),
              Container(width: 16),
              Expanded(
                child: Text(
                    '${dic['margin.max']} ${amountSellMax.toStringAsFixed(isUSDBasedPair ? 2 : 5)} $baseToken'),
              )
            ],
          ),
        ],
      ),
    );
  }
}
