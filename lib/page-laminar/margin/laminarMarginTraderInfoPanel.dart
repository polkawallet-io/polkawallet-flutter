import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:polka_wallet/common/components/infoItemRow.dart';
import 'package:polka_wallet/common/components/roundedButton.dart';
import 'package:polka_wallet/common/consts/settings.dart';
import 'package:polka_wallet/store/laminar/types/laminarMarginData.dart';
import 'package:polka_wallet/utils/format.dart';
import 'package:polka_wallet/utils/i18n/index.dart';

class LaminarTraderInfoPanel extends StatelessWidget {
  LaminarTraderInfoPanel({this.info, this.decimals = acala_token_decimals});

  final LaminarMarginTraderInfoData info;
  final int decimals;

  @override
  Widget build(BuildContext context) {
    final Map dic = I18n.of(context).laminar;
    final double pnl =
        Fmt.balanceDouble(info?.unrealizedPl, decimals: decimals);
    return Container(
      color: Colors.black12,
      child: Column(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              children: <Widget>[
                InfoItemRow(
                  dic['margin.balance'],
                  '${Fmt.balance(info?.balance, decimals: decimals)} aUSD',
                ),
                InfoItemRow(
                  dic['margin.hold.all'],
                  '${Fmt.balance(info?.marginHeld, decimals: decimals)} aUSD',
                  colorPrimary: true,
                ),
                InfoItemRow(
                  dic['margin.free'],
                  '${Fmt.balance(info?.freeMargin, decimals: decimals)} aUSD',
                ),
                InfoItemRow(
                  dic['margin.equity'],
                  '${Fmt.balance(info?.equity, decimals: decimals)} aUSD',
                ),
                InfoItemRow(
                  dic['margin.pnl'],
                  '${pnl.toStringAsFixed(3)} aUSD',
                  color: pnl > 0 ? Colors.green : Colors.red,
                ),
                InfoItemRow(
                  dic['margin.free'],
                  '${Fmt.balance(info?.totalLeveragedPosition, decimals: decimals)} aUSD',
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: RoundedButton(
                    text: dic['margin.deposit'],
                    onPressed: () {
                      print('depo');
                    },
                  ),
                ),
                Container(width: 16),
                Expanded(
                  child: RoundedButton(
                    text: dic['margin.withdraw'],
                    color: Theme.of(context).unselectedWidgetColor,
                    onPressed: () {
                      print('with');
                    },
                  ),
                )
              ],
            ),
          ),
          Divider(height: 2),
        ],
      ),
    );
  }
}
