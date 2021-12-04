import 'package:encointer_wallet/page-encointer/bazaar/shared/bazaarItemHorizontal.dart';
import 'package:encointer_wallet/page-encointer/bazaar/shared/data_model/demo_data/demoData.dart';
import 'package:flutter/material.dart';

import 'BazaarSearch/bazaarSearch.dart';

class Home extends StatelessWidget {
  final double cardHeight = 200;
  final double cardWidth = 160;

  @override
  Widget build(BuildContext context) {
    return Stack(fit: StackFit.expand, children: [
      Padding(
        padding: const EdgeInsets.only(top: 54),
        child: ListView(children: [
          HorizontalBazaarItemList(newInBazaar, "New in Bazaar", cardHeight, cardWidth),
          HorizontalBazaarItemList(businessesInVicinity, "Businesses in my Vicinity", cardHeight, cardWidth),
          HorizontalBazaarItemList(lastVisited, "Last visited", cardHeight, cardWidth),
        ]),
      ),
      BazaarSearch(),
    ]);
  }
}
