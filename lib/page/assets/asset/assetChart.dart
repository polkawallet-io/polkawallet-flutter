import 'package:flutter/cupertino.dart';
import 'package:charts_flutter/flutter.dart' as charts;

class AssetChart extends StatelessWidget {
  AssetChart(this.data, {this.animate});

  final List<charts.Series> data;
  final bool animate;

  factory AssetChart.withData(List<Map<String, dynamic>> ls) {
    return new AssetChart(
      _formatData(ls),
      // Disable animations for image tests.
      animate: false,
    );
  }

  static List<charts.Series<Map<String, dynamic>, DateTime>> _formatData(
      List<Map<String, dynamic>> ls) {
    return [
      new charts.Series<Map<String, dynamic>, DateTime>(
        id: 'asset',
        colorFn: (_, __) => charts.MaterialPalette.pink.shadeDefault,
        domainFn: (Map<String, dynamic> item, _) => item['time'],
        measureFn: (Map<String, dynamic> item, _) => item['value'],
        data: ls,
      )
    ];
  }

  @override
  Widget build(BuildContext context) {
    return new charts.TimeSeriesChart(
      data,
      dateTimeFactory: const charts.LocalDateTimeFactory(),
    );
  }
}
