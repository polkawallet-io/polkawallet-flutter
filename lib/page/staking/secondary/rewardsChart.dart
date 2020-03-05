import 'package:flutter/cupertino.dart';
import 'package:charts_flutter/flutter.dart' as charts;

class RewardsChart extends StatelessWidget {
  RewardsChart(this.data, this.labels, this.labelFormatter, {this.animate});

  final List<String> labels;
  final List<charts.Series> data;
  final bool animate;

  final charts.BasicNumericTickFormatterSpec labelFormatter;

  factory RewardsChart.withData(List<List<num>> ls, List<String> labels) {
    var formatter = charts.BasicNumericTickFormatterSpec((num value) {
      return labels[value.toInt()] ?? '';
    });
    return new RewardsChart(
      _formatData(ls),
      labels,
      formatter,
      // Disable animations for image tests.
      animate: false,
    );
  }

  static List<charts.Series<num, num>> _formatData(List<List<num>> ls) {
    return [
      new charts.Series<num, num>(
        id: 'Slashes',
        colorFn: (_, __) => charts.MaterialPalette.red.shadeDefault,
        domainFn: (_, int index) => index,
        measureFn: (num item, _) => item,
        data: ls[0],
      ),
      new charts.Series<num, num>(
        id: 'Rewards',
        colorFn: (_, __) => charts.MaterialPalette.blue.shadeDefault,
        domainFn: (_, int index) => index,
        measureFn: (num item, _) => item,
        data: ls[1],
      ),
      new charts.Series<num, num>(
        id: 'Average',
        colorFn: (_, __) => charts.MaterialPalette.gray.shadeDefault,
        domainFn: (_, int index) => index,
        measureFn: (num item, _) => item,
        data: ls[2],
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return new charts.LineChart(
      data,
      defaultRenderer:
          new charts.LineRendererConfig(includeArea: true, stacked: true),
      animate: animate,
      domainAxis: charts.NumericAxisSpec(
        tickProviderSpec: charts.BasicNumericTickProviderSpec(
            desiredTickCount: labels.length),
        tickFormatterSpec: labelFormatter,
      ),
    );
  }
}
