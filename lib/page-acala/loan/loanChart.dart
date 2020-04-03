import 'package:flutter/material.dart';
import 'package:polka_wallet/common/components/roundedCard.dart';
import 'package:polka_wallet/common/consts/settings.dart';
import 'package:polka_wallet/common/theme.dart';
import 'package:polka_wallet/store/acala/acala.dart';
import 'package:polka_wallet/utils/format.dart';
import 'package:polka_wallet/utils/i18n/index.dart';

class LoanChart extends StatelessWidget {
  LoanChart(this.loan);
  final LoanData loan;
  @override
  Widget build(BuildContext context) {
    final Map dic = I18n.of(context).acala;
    double requiredCollateralRatio = double.parse(Fmt.token(
        loan.type.requiredCollateralRatio,
        decimals: acala_token_decimals));
    double liquidationRatio = double.parse(
        Fmt.token(loan.type.liquidationRatio, decimals: acala_token_decimals));

    const double heightTotal = 160;
    double heightBorrowed = 0;
    double heightRequired = 0;
    double heightLiquidation = 0;
    if (loan.debitAmount > BigInt.zero) {
      heightBorrowed = heightTotal * (loan.debitAmount / loan.collateralAmount);
      heightRequired = heightTotal / requiredCollateralRatio;
      heightLiquidation = heightTotal / liquidationRatio;
    }

//    String borrowed =
//        Fmt.token(loan.debitAmount, decimals: acala_token_decimals);

    const TextStyle textStyle = TextStyle(fontSize: 12);
    return RoundedCard(
      margin: EdgeInsets.fromLTRB(16, 8, 16, 32),
      padding: EdgeInsets.all(16),
      child: Container(
        padding: EdgeInsets.only(top: 8, right: 8),
        decoration: BoxDecoration(
          border: Border(
            left: BorderSide(),
            bottom: BorderSide(),
          ),
        ),
        child: Stack(
          alignment: AlignmentDirectional.bottomStart,
          children: <Widget>[
            // borrowed amount
            Container(
              color: color_green_45,
              height: 20 + heightBorrowed,
              child: Padding(
                padding: EdgeInsets.fromLTRB(4, 4, 4, 0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(Fmt.ratio(loan.collateralRatio), style: textStyle),
                    Text(dic['loan.borrowed'], style: textStyle)
                  ],
                ),
              ),
            ),
            // the liquidation line
            Container(
              height: 150,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Divider(color: Colors.red, height: 8),
                  Padding(
                    padding: EdgeInsets.fromLTRB(4, 0, 4, 0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text(Fmt.ratio(liquidationRatio), style: textStyle),
                        Text(dic['liquid.ratio'], style: textStyle),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // the required line
            Container(
              height: 120,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Divider(color: Colors.orange, height: 8),
                  Padding(
                    padding: EdgeInsets.fromLTRB(4, 0, 4, 0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text(Fmt.ratio(requiredCollateralRatio),
                            style: textStyle),
                        Text(dic['liquid.ratio.require'], style: textStyle)
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Container(
              height: 160,
              decoration: BoxDecoration(
                color: color_green_26,
              ),
              child: Padding(
                padding: EdgeInsets.fromLTRB(4, 4, 4, 0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text('100%', style: textStyle),
                    Text(dic['loan.collateral'], style: textStyle),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
