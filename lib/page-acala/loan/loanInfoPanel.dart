import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:polka_wallet/common/components/infoItemRow.dart';
import 'package:polka_wallet/utils/format.dart';
import 'package:polka_wallet/utils/i18n/index.dart';

class LoanInfoPanel extends StatelessWidget {
  LoanInfoPanel({
    this.price,
    this.liquidationRatio,
    this.requiredRatio,
    this.currentRatio,
    this.liquidationPrice,
    this.decimals,
  });
  final BigInt price;
  final BigInt liquidationRatio;
  final BigInt requiredRatio;
  final double currentRatio;
  final BigInt liquidationPrice;
  final int decimals;
  @override
  Widget build(BuildContext context) {
    final Map dic = I18n.of(context).acala;
    String priceString = Fmt.token(price, decimals);
    String liquidationPriceString = Fmt.token(liquidationPrice, decimals);
    return Column(
      children: <Widget>[
        InfoItemRow(
          dic['collateral.price'],
          '\$$priceString',
        ),
//        LoanInfoItem(
//          dic['liquid.ratio'],
//          Fmt.ratio(
//            double.parse(
//              Fmt.token(liquidationRatio, decimals),
//            ),
//          ),
//        ),
        InfoItemRow(
          dic['liquid.ratio.require'],
          Fmt.ratio(
            double.parse(
              Fmt.token(requiredRatio, decimals),
            ),
          ),
        ),
        InfoItemRow(
          dic['liquid.ratio.current'],
          Fmt.ratio(currentRatio),
          colorPrimary: true,
        ),
        InfoItemRow(
          dic['liquid.price'],
          '\$$liquidationPriceString',
          colorPrimary: true,
        ),
      ],
    );
  }
}
