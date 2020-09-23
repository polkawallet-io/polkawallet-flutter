import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:polka_wallet/common/components/infoItemRow.dart';
import 'package:polka_wallet/common/components/roundedButton.dart';
import 'package:polka_wallet/common/consts/settings.dart';
import 'package:polka_wallet/page-laminar/margin/laminarMarginPoolDepositPage.dart';
import 'package:polka_wallet/store/laminar/types/laminarMarginData.dart';
import 'package:polka_wallet/utils/format.dart';
import 'package:polka_wallet/utils/i18n/index.dart';

class LaminarTraderInfoPanel extends StatefulWidget {
  LaminarTraderInfoPanel(
      {this.balanceInt, this.info, this.decimals = acala_token_decimals});

  final BigInt balanceInt;
  final LaminarMarginTraderInfoData info;
  final int decimals;

  @override
  _LaminarTraderInfoPanelState createState() => _LaminarTraderInfoPanelState();
}

class _LaminarTraderInfoPanelState extends State<LaminarTraderInfoPanel> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final Map dic = I18n.of(context).laminar;
    final BigInt poolBalanceInt = Fmt.balanceInt(widget.info?.balance);
    bool expanded = _expanded;
    if (poolBalanceInt == BigInt.zero) {
      expanded = true;
    }
    return Container(
      child: Column(
        children: <Widget>[
          GestureDetector(
            child: Container(
              padding: EdgeInsets.fromLTRB(16, 8, 16, 8),
              color: Theme.of(context).cardColor,
              child: Row(
                children: <Widget>[
                  Container(
                    width: 24,
                    child: Icon(
                      expanded
                          ? Icons.keyboard_arrow_up
                          : Icons.keyboard_arrow_down,
                      color: Theme.of(context).unselectedWidgetColor,
                    ),
                  ),
                  Expanded(
                    child: Text(dic['margin.balance']),
                  ),
                  Text(
                    '${Fmt.priceFloorBigInt(poolBalanceInt, widget.decimals)} aUSD',
                    style: Theme.of(context).textTheme.headline4,
                  ),
                ],
              ),
            ),
            onTap: () {
              setState(() {
                _expanded = !_expanded;
              });
            },
          ),
          expanded
              ? LaminarTraderInfoPanelExtra(
                  info: widget.info,
                  decimals: widget.decimals,
                  balanceInt: widget.balanceInt,
                )
              : Container(),
          Divider(height: 2),
        ],
      ),
    );
  }
}

class LaminarTraderInfoPanelExtra extends StatelessWidget {
  LaminarTraderInfoPanelExtra({
    this.info,
    this.balanceInt,
    this.decimals = acala_token_decimals,
  });

  final BigInt balanceInt;
  final LaminarMarginTraderInfoData info;
  final int decimals;

  @override
  Widget build(BuildContext context) {
    final Map dic = I18n.of(context).laminar;
    final double pnl = Fmt.balanceDouble(info?.unrealizedPl, decimals);
    return Container(
      padding: EdgeInsets.all(16),
      color: Colors.black12,
      child: Column(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(left: 24),
            child: Column(
              children: <Widget>[
                InfoItemRow(
                  dic['margin.hold.all'],
                  '${Fmt.balance(info?.marginHeld, decimals)} aUSD',
                  colorPrimary: true,
                ),
                InfoItemRow(
                  dic['margin.free'],
                  '${Fmt.balance(info?.freeMargin, decimals)} aUSD',
                ),
                InfoItemRow(
                  dic['margin.equity'],
                  '${Fmt.balance(info?.equity, decimals)} aUSD',
                ),
                InfoItemRow(
                  dic['margin.pnl'],
                  '${pnl.toStringAsFixed(3)} aUSD',
                  color: pnl > 0 ? Colors.green : Colors.red,
                ),
                InfoItemRow(
                  dic['margin.amount.total'],
                  '${Fmt.balance(info?.totalLeveragedPosition, decimals)} aUSD',
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.only(top: 16),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: RoundedButton(
                    text: dic['margin.deposit'],
                    onPressed: () {
                      Navigator.of(context).pushNamed(
                        LaminarMarginPoolDepositPage.route,
                        arguments: LaminarMarginPoolDepositPageParams(
                            poolId: info.poolId),
                      );
                    },
                  ),
                ),
                Container(width: 16),
                Expanded(
                  child: RoundedButton(
                    text: dic['margin.withdraw'],
                    color: Theme.of(context).unselectedWidgetColor,
                    onPressed: () {
                      Navigator.of(context).pushNamed(
                        LaminarMarginPoolDepositPage.route,
                        arguments: LaminarMarginPoolDepositPageParams(
                          poolId: info.poolId,
                          isWithdraw: true,
                        ),
                      );
                    },
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
