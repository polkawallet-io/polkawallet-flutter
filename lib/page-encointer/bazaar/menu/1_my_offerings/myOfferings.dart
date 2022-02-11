import 'package:encointer_wallet/page-encointer/bazaar/menu/1_my_offerings/offeringForm.dart';
import 'package:encointer_wallet/page-encointer/bazaar/shared/bazaarItemVertical.dart';
import 'package:encointer_wallet/page-encointer/bazaar/shared/data_model/demo_data/demoData.dart';
import 'package:encointer_wallet/page-encointer/bazaar/shared/toggleButtonsWithTitle.dart';
import 'package:encointer_wallet/utils/translations/index.dart';
import 'package:flutter/material.dart';

class MyOfferings extends StatelessWidget {
  final data = myOfferings;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(I18n.of(context).translationsForLocale().bazaar.offeringsMy),
      ),
      body: Column(children: [
        ToggleButtonsWithTitle(I18n.of(context).translationsForLocale().bazaar.categories, allCategories, null),
        Expanded(
          child: ListView.builder(
            itemCount: data.length,
            itemBuilder: (context, index) => BazaarItemVertical(
              data: data,
              index: index,
              cardHeight: 125,
            ),
          ),
        ),
      ]),
      floatingActionButton: FloatingActionButton(
          child: Icon(Icons.add),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => OfferingForm(),
              ),
            );
          }),
    );
  }
}
