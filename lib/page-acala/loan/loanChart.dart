import 'package:flutter/material.dart';
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
    final double widthChart = MediaQuery.of(context).size.width / 4;
    double heightBorrowed = 0;
    double heightRequired = 0;
    double heightLiquidation = 0;
    if (loan.debitInUSD > BigInt.zero) {
      heightBorrowed = heightTotal * (loan.debitInUSD / loan.collateralInUSD);
      heightRequired = heightTotal / requiredCollateralRatio;
      heightLiquidation = heightTotal / liquidationRatio;
      if (heightLiquidation - heightRequired < 24) {
        heightLiquidation = heightRequired + 24;
      }
    }

    String collatoralInUSD =
        Fmt.token(loan.collateralInUSD, decimals: acala_token_decimals);

    const TextStyle textStyle = TextStyle(fontSize: 12);

    return Row(
      children: <Widget>[
//        Container(
//          margin: EdgeInsets.fromLTRB(32, 8, 0, 8),
//          child: _ChartContainer(
//            heightBorrowed,
//            heightRequired,
//            heightLiquidation,
//            collateral: Text('100%'),
//            debits: Text(
//              Fmt.ratio(loan.collateralRatio),
//              style: TextStyle(color: Colors.green),
//            ),
//            liquidation: Text(
//              Fmt.ratio(liquidationRatio),
//              style: TextStyle(color: Colors.red),
//            ),
//            required: Text(
//              Fmt.ratio(requiredCollateralRatio),
//              style: TextStyle(color: Colors.blue),
//            ),
//            alignment: AlignmentDirectional.bottomEnd,
//          ),
//        ),
        Container(
          margin: EdgeInsets.fromLTRB(32, 8, 8, 8),
          padding: EdgeInsets.only(top: 8, right: 8),
          width: widthChart,
          decoration: BoxDecoration(
            border: Border(
              left: BorderSide(color: Theme.of(context).unselectedWidgetColor),
              bottom:
                  BorderSide(color: Theme.of(context).unselectedWidgetColor),
            ),
          ),
          child: _ChartContainer(
            heightBorrowed,
            heightRequired,
            heightLiquidation,
            liquidation: Divider(color: Colors.red, height: 2, thickness: 2),
            required: Divider(color: Colors.blue, height: 2, thickness: 2),
          ),
        ),
        Expanded(
          child: Container(
            margin: EdgeInsets.fromLTRB(0, 0, 48, 8),
            child: _ChartContainer(
              heightBorrowed,
              heightRequired,
              heightLiquidation,
              collateral: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(dic['loan.collateral']),
                  Text('\$$collatoralInUSD',
                      style: Theme.of(context).textTheme.display4),
                ],
              ),
//              debits: Text(
//                dic['liquid.ratio.current'],
//                style: TextStyle(color: Colors.green),
//              ),
//              liquidation: Text(
//                dic['liquid.ratio'],
//                style: TextStyle(color: Colors.red),
//              ),
//              required: Text(
//                dic['liquid.ratio.require'],
//                style: TextStyle(color: Colors.blue),
//              ),
              debits: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(
                    dic['liquid.ratio.current'],
                    style: TextStyle(color: Theme.of(context).primaryColor),
                  ),
                  Text(
                    Fmt.ratio(loan.collateralRatio),
                    style: TextStyle(
                      color: Theme.of(context).primaryColor,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
              liquidation: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(
                    dic['liquid.ratio'],
                    style: TextStyle(color: Colors.red),
                  ),
                  Text(
                    Fmt.ratio(liquidationRatio),
                    style: TextStyle(color: Colors.red),
                  ),
                ],
              ),
              required: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(
                    dic['liquid.ratio.require'],
                    style: TextStyle(color: Colors.blue),
                  ),
                  Text(
                    Fmt.ratio(requiredCollateralRatio),
                    style: TextStyle(color: Colors.blue),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _ChartContainer extends StatelessWidget {
  _ChartContainer(
    this.heightBorrowed,
    this.heightRequired,
    this.heightLiquidation, {
    this.collateral,
    this.debits,
    this.required,
    this.liquidation,
    this.alignment,
  });

  final double heightBorrowed;
  final double heightRequired;
  final double heightLiquidation;
  final Widget collateral;
  final Widget debits;
  final Widget required;
  final Widget liquidation;
  final AlignmentGeometry alignment;

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: alignment ?? AlignmentDirectional.bottomStart,
      children: <Widget>[
        // collateral amount
        Container(
          height: 160,

          decoration: collateral == null
              ? BoxDecoration(
                  border: Border(
                    top: BorderSide(
                        color: Theme.of(context).dividerColor, width: 2),
                    right: BorderSide(
                        color: Theme.of(context).dividerColor, width: 2),
                  ),
                )
              : null,
//          color: collateral == null
//              ? Theme.of(context).dividerColor
//              : Colors.transparent,
          child: collateral,
        ),
        // borrowed amount
        Container(
          height: heightBorrowed > 30 ? heightBorrowed : 30,
          color: debits == null
              ? Theme.of(context).primaryColor
              : Colors.transparent,
          child: debits,
        ),
        // the liquidation line
        Container(
          height: heightLiquidation,
          alignment: Alignment.topLeft,
          child: liquidation,
        ),
        // the required line
        Container(
          height: heightRequired,
          alignment: Alignment.topLeft,
          child: required,
        ),
      ],
    );
  }
}
