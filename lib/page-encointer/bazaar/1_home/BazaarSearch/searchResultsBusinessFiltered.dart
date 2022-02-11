import 'package:encointer_wallet/page-encointer/bazaar/shared/data_model/demo_data/demoData.dart';
import 'package:encointer_wallet/page-encointer/bazaar/shared/toggleButtonsWithTitle.dart';
import 'package:encointer_wallet/utils/translations/index.dart';
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
            "Filter ${I18n.of(context).translationsForLocale().bazaar.businessesFound}",
            style: titleStyle,
          ),
        ),
        body: ListView(children: [
          ToggleButtonsWithTitle(I18n.of(context).translationsForLocale().bazaar.categories, categories, null),
        ]),
        floatingActionButton: ButtonBar(
          children: [
            ElevatedButton(
              onPressed: () => null, // TODO state management
              child: Text(I18n.of(context).translationsForLocale().bazaar.reset),
            ),
            ElevatedButton(
              onPressed: () => null, //TODO state management
              child: Text(I18n.of(context).translationsForLocale().bazaar.apply),
            ),
          ],
        ));
  }
}
