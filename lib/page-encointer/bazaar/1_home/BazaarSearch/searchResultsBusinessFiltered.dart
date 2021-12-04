import 'package:encointer_wallet/page-encointer/bazaar/shared/data_model/demo_data/demoData.dart';
import 'package:encointer_wallet/page-encointer/bazaar/shared/toggleButtonsWithTitle.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SearchResultsBusinessFiltered extends StatelessWidget {
  final results;
  final categories = allCategories;
  final deliveryOptions = allDeliveryOptions;
  final productNewnessOptions = allProductNewnessOptions;
  final selectedDeliveryOptions = <bool>[];
  final selectedProductNewnessOptions = <bool>[];

  SearchResultsBusinessFiltered(this.results, {Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var titleStyle = TextStyle(fontWeight: FontWeight.bold);

    return Scaffold(
        appBar: AppBar(
          title: Text(
            "Filter found businesses",
            style: titleStyle,
          ),
        ),
        body: ListView(children: [
          ToggleButtonsWithTitle("Categories", categories, null), // TODO state management
        ]),
        floatingActionButton: ButtonBar(
          children: [
            ElevatedButton(
              onPressed: () => null, // TODO state management
              child: Text("Reset"),
            ),
            ElevatedButton(
              onPressed: () => null, //TODO state management
              child: Text("Apply"),
            ),
          ],
        ));
  }
}
