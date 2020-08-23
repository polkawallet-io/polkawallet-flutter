import 'package:flutter/material.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:polka_wallet/store/acala/types/loanType.dart';
import 'package:polka_wallet/utils/format.dart';
import 'package:polka_wallet/utils/i18n/index.dart';

class LoanDonutChart extends StatelessWidget {
  LoanDonutChart(this.loan, this.decimals);
  final LoanData loan;
  final int decimals;
  @override
  Widget build(BuildContext context) {
    final Map dic = I18n.of(context).acala;
    double requiredCollateralRatio =
        double.parse(Fmt.token(loan.type.requiredCollateralRatio, decimals));
    double liquidationRatio =
        double.parse(Fmt.token(loan.type.liquidationRatio, decimals));

    const double heightTotal = 160;
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

    String collatoralInUSD = Fmt.token(loan.collateralInUSD, decimals);

    const TextStyle textStyle = TextStyle(fontSize: 12);

    final dataCollateral = [1, 0];
    final dataDebit = [
      Fmt.bigIntToDouble(loan.debitInUSD, decimals),
      Fmt.bigIntToDouble(loan.collateralInUSD - loan.debitInUSD, decimals),
    ];

    List<charts.Series> seriesListCollateral = [
      new charts.Series<num, int>(
        id: 'Sales',
        domainFn: (_, i) => i,
        colorFn: (_, __) => charts.MaterialPalette.cyan.shadeDefault,
        measureFn: (num i, _) => i,
        data: dataCollateral,
      )
    ];

    List<charts.Series> seriesListDebit = [
      new charts.Series<num, int>(
        id: 'Sales',
        domainFn: (_, i) => i,
        colorFn: (_, i) => i == 0
            ? charts.MaterialPalette.blue.shadeDefault
            : charts.MaterialPalette.transparent,
        measureFn: (num i, _) => i,
        data: dataDebit,
      )
    ];

    double chartHeight = MediaQuery.of(context).size.width / 2;
    const int arcWidth = 24;

    return Stack(
      children: <Widget>[
        Container(
          margin: EdgeInsets.all(16),
          height: chartHeight,
          child: charts.PieChart(seriesListCollateral,
              animate: true,
              // Configure the width of the pie slices to 60px. The remaining space in
              // the chart will be left as a hole in the center.
              defaultRenderer:
                  new charts.ArcRendererConfig(arcWidth: arcWidth)),
        ),
        Container(
          margin: EdgeInsets.fromLTRB(16, 18 + arcWidth.toDouble(), 16, 16),
          height: chartHeight - 52,
          child: charts.PieChart(seriesListDebit,
              animate: true,
              defaultRenderer:
                  new charts.ArcRendererConfig(arcWidth: arcWidth)),
        ),
      ],
    );
  }
}
