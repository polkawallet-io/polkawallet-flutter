import 'package:encointer_wallet/page-encointer/bazaar/menu/2_my_businesses/businessesOnMap.dart';
import 'package:encointer_wallet/page-encointer/bazaar/shared/bazaarItemVertical.dart';
import 'package:encointer_wallet/page-encointer/bazaar/shared/data_model/demo_data/demoData.dart';
import 'package:encointer_wallet/page-encointer/bazaar/shared/toggleButtonsWithTitle.dart';
import 'package:flutter/material.dart';
import 'package:encointer_wallet/utils/i18n/index.dart';

class Businesses extends StatelessWidget {
  final data = allBusinesses;

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      ToggleButtonsWithTitle(I18n.of(context).bazaar['categories'], allCategories, null), // TODO state management
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
      ElevatedButton(
        onPressed: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => BusinessesOnMap(),
              ));
        },
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            new Icon(Icons.map),
            new Text(I18n.of(context).bazaar['map']),
          ],
        ),
      )
    ]);
  }
}
