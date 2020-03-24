import 'package:flutter/cupertino.dart';
import 'package:charts_flutter/flutter.dart' as charts;

class BlocksChart extends StatelessWidget {
  BlocksChart(this.data, this.labels, this.labelFormatter, {this.animate});

  final List<String> labels;
  final List<charts.Series> data;
  final bool animate;

  final charts.BasicNumericTickFormatterSpec labelFormatter;

  factory BlocksChart.withData(List<List> ls, List<String> labels) {
    var formatter = charts.BasicNumericTickFormatterSpec((num value) {
      return labels[value.toInt()] ?? '';
    });
    return new BlocksChart(
      _formatData(ls),
      labels,
      formatter,
      // Disable animations for image tests.
      animate: false,
    );
  }

  static List<charts.Series<num, num>> _formatData(List<List> ls) {
    return [
      new charts.Series<num, num>(
        id: 'Blocks produced',
        colorFn: (_, __) => charts.MaterialPalette.yellow.shadeDefault,
        domainFn: (_, int index) => index,
        measureFn: (num item, _) => item,
        data: List<num>.from(ls[0]),
      ),
      new charts.Series<num, num>(
        id: 'Average',
        colorFn: (_, __) => charts.MaterialPalette.gray.shadeDefault,
        domainFn: (_, int index) => index,
        measureFn: (num item, _) => item,
        data: List<num>.from(ls[1]),
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
