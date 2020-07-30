import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:polka_wallet/common/components/roundedButton.dart';
import 'package:polka_wallet/common/consts/settings.dart';
import 'package:polka_wallet/common/regInputFormatter.dart';
import 'package:polka_wallet/page-laminar/margin/laminarMarginTradePrice.dart';
import 'package:polka_wallet/store/laminar/types/laminarCurrenciesData.dart';
import 'package:polka_wallet/store/laminar/types/laminarMarginData.dart';
import 'package:polka_wallet/utils/format.dart';
import 'package:polka_wallet/utils/i18n/index.dart';

class LaminarMarginTradePanel extends StatefulWidget {
  LaminarMarginTradePanel({
    this.poolId,
    this.pairData,
    this.info,
    this.priceMap,
    this.decimals = acala_token_decimals,
  });

  final String poolId;
  final LaminarMarginPairData pairData;
  final LaminarMarginTraderInfoData info;
  final Map<String, LaminarPriceData> priceMap;
  final int decimals;

  @override
  _LaminarMarginTradePanelState createState() =>
      _LaminarMarginTradePanelState();
}

class _LaminarMarginTradePanelState extends State<LaminarMarginTradePanel> {
  final GlobalKey<RefreshIndicatorState> _refreshKey =
      new GlobalKey<RefreshIndicatorState>();

  final _formKey = GlobalKey<FormState>();
  final TextEditingController _amountCtrl = new TextEditingController();

  @override
  Widget build(BuildContext context) {
    final Map dic = I18n.of(context).laminar;
    final Map dicAssets = I18n.of(context).assets;
    final double free =
        Fmt.balanceDouble(widget.info?.freeMargin, decimals: widget.decimals);
    return Container(
      padding: EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: Column(
        children: <Widget>[
          Form(
            key: _formKey,
            child: TextFormField(
              decoration: InputDecoration(
                hintText: dicAssets['amount'],
                labelText:
                    '${dicAssets['amount']} (${dic['margin.free']} ${free.toStringAsFixed(3)})',
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
              inputFormatters: [
                RegExInputFormatter.withRegex(
                    '^[0-9]{0,6}(\\.[0-9]{0,$widget.decimals})?\$')
              ],
              controller: _amountCtrl,
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              validator: (v) {
                if (v.isEmpty) {
                  return dicAssets['amount.error'];
                }
                if (double.parse(v.trim()) > free) {
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
                        pairData: widget.pairData,
                        direction: 'long',
                        priceMap: widget.priceMap,
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
                        pairData: widget.pairData,
                        direction: 'short',
                        priceMap: widget.priceMap,
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
                  onPressed: () {
                    print('depo');
                  },
                ),
              ),
              Container(width: 16),
              Expanded(
                child: RoundedButton(
                  text: dic['margin.sell'],
                  color: Colors.red,
                  onPressed: () {
                    print('with');
                  },
                ),
              )
            ],
          ),
        ],
      ),
    );
  }
}
