import 'package:encointer_wallet/page-encointer/bazaar/shared/toggleButtonsWithTitle.dart';
import 'package:encointer_wallet/page-encointer/bazaar/shared/data_model/demo_data/demoData.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SearchResultsOfferingFiltered extends StatelessWidget {
  final results;
  final categories = allCategories;
  final deliveryOptions = allDeliveryOptions;
  final productNewnessOptions = allProductNewnessOptions;
  final selectedDeliveryOptions = <bool>[];
  final selectedProductNewnessOptions = <bool>[];
  final _currentRangeValues = const RangeValues(40, 80);

  SearchResultsOfferingFiltered(this.results, {Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var titleStyle = TextStyle(fontWeight: FontWeight.bold, height: 2.5);

    return Scaffold(
      appBar: AppBar(
        title: Text("Filter found offerings"),
      ),
      body: ListView(children: [
        ToggleButtonsWithTitle("Categories", categories, null), // TODO state management
        Text(
          "Price",
          style: titleStyle,
        ),
        RangeSlider(
          values: _currentRangeValues,
          min: 0,
          max: 100,
          divisions: 5,
          labels: RangeLabels(
            _currentRangeValues.start.round().toString(),
            _currentRangeValues.end.round().toString(),
          ),
          onChanged: (RangeValues values) {
            // TODO state management
          },
        ),
        Text(
          "Delivery",
          style: titleStyle,
        ),
        ToggleButtons(
            children: deliveryOptions.map((option) => Text(option)).toList(), isSelected: selectedDeliveryOptions),
        Text(
          "Product Newness",
          style: titleStyle,
        ),
        ToggleButtons(
            children: productNewnessOptions.map((option) => Text(option)).toList(),
            isSelected: selectedProductNewnessOptions),
      ]),
      floatingActionButton: ButtonBar(
        children: [
          ElevatedButton(
              onPressed: () => null, // TODO state management
              child: Text("Reset")),
          ElevatedButton(
              onPressed: () => null, //TODO state management
              child: Text("Apply")),
        ],
      ),
    );
  }
}
