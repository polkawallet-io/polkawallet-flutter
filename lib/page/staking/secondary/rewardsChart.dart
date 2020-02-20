import 'package:flutter/cupertino.dart';
import 'package:charts_flutter/flutter.dart' as charts;

class RewardsChart extends StatelessWidget {
  RewardsChart(this.data, this.labels, this.labelFormatter, {this.animate});

  final List<String> labels;
  final List<charts.Series> data;
  final bool animate;

  final charts.BasicNumericTickFormatterSpec labelFormatter;

  factory RewardsChart.withData(
      List<Map<String, dynamic>> ls, List<String> labels) {
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

  static List<charts.Series<Map<String, dynamic>, num>> _formatData(
      List<Map<String, dynamic>> ls) {
    return [
      new charts.Series<Map<String, dynamic>, num>(
        id: 'Rewards',
        colorFn: (_, __) => charts.MaterialPalette.blue.shadeDefault,
        domainFn: (Map<String, dynamic> item, _) => item['label'],
        measureFn: (Map<String, dynamic> item, _) => item['value'],
        data: ls,
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
