import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter/material.dart';

class RewardsChart extends StatelessWidget {
  RewardsChart(this.data, this.labels, this.labelFormatter, {this.animate});

  final List<String> labels;
  final List<charts.Series> data;
  final bool animate;

  final charts.BasicNumericTickFormatterSpec labelFormatter;

  factory RewardsChart.withData(
      List<ChartLineInfo> lines, List<List> values, List<String> labels) {
    var formatter = charts.BasicNumericTickFormatterSpec((num value) {
      return labels[value.toInt()] ?? '';
    });
    return new RewardsChart(
      _formatData(lines, values),
      labels,
      formatter,
      // Disable animations for image tests.
      animate: false,
    );
  }

  static List<charts.Series<num, num>> _formatData(
      List<ChartLineInfo> lines, List<List> ls) {
    int index = 0;
    return lines.map((i) {
      charts.Series<num, num> res = new charts.Series<num, num>(
        id: i.name,
        colorFn: (_, __) => i.color,
        domainFn: (_, int index) => index,
        measureFn: (num item, _) => item,
        data: List<num>.from(ls[index]),
      );
      index++;
      return res;
    }).toList();
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

class ChartLineInfo {
  ChartLineInfo(this.name, this.color);
  final String name;
  final charts.Color color;
}
