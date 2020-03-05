import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter/material.dart';
import 'package:polka_wallet/utils/format.dart';

class SplitChart extends StatelessWidget {
  final List<charts.Series> seriesList;
  final bool animate;

  SplitChart(this.seriesList, {this.animate});

  factory SplitChart.withData(List<Map<String, dynamic>> ls) {
    return new SplitChart(
      _formatData(ls),
      animate: false,
    );
  }
  @override
  Widget build(BuildContext context) {
    return new charts.BarChart(
      seriesList,
      animate: animate,
      vertical: false,
      barRendererDecorator: new charts.BarLabelDecorator<String>(),
      // Hide domain axis.
      domainAxis:
          new charts.OrdinalAxisSpec(renderSpec: new charts.NoneRenderSpec()),
    );
  }

  static List<charts.Series<Map<String, dynamic>, String>> _formatData(
      List<Map<String, dynamic>> ls) {
    return [
      new charts.Series<Map<String, dynamic>, String>(
        id: 'Sales',
        domainFn: (Map<String, dynamic> item, _) => item['label'],
        measureFn: (Map<String, dynamic> item, _) => item['value'],
        data: ls,
        // Set a label accessor to control the text of the bar label.
        labelAccessorFn: (Map<String, dynamic> item, _) =>
            '${Fmt.address(item['label'], pad: 6)}${item['isOwn'] ? '(Own)' : ''}: ${item['value']}%',
        fillColorFn: (Map<String, dynamic> item, _) => item['isOwn']
            ? charts.MaterialPalette.yellow.shadeDefault
            : charts.MaterialPalette.gray.shadeDefault,
      ),
    ];
  }
}
