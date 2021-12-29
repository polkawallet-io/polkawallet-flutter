import 'package:encointer_wallet/page-encointer/bazaar/shared/bazaarItemHorizontal.dart';
import 'package:encointer_wallet/page-encointer/bazaar/shared/data_model/demo_data/demoData.dart';
import 'package:encointer_wallet/utils/i18n/index.dart';
import 'package:flutter/material.dart';

import 'BazaarSearch/bazaarSearch.dart';

class Home extends StatelessWidget {
  final double cardHeight = 200;
  final double cardWidth = 160;

  @override
  Widget build(BuildContext context) {
    var dic = I18n.of(context).bazaar;
    return Stack(fit: StackFit.expand, children: [
      Padding(
        padding: const EdgeInsets.only(top: 54),
        child: ListView(children: [
          HorizontalBazaarItemList(newInBazaar, dic['bazaar.new'], cardHeight, cardWidth),
          HorizontalBazaarItemList(businessesInVicinity, dic['businesses.vicinity'], cardHeight, cardWidth),
          HorizontalBazaarItemList(lastVisited, dic['last.visited'], cardHeight, cardWidth),
        ]),
      ),
      BazaarSearch(),
    ]);
  }
}
