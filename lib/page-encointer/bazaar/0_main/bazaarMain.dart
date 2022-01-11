import 'package:encointer_wallet/page-encointer/bazaar/1_home/home.dart';
import 'package:encointer_wallet/page-encointer/bazaar/2_offerings/offerings.dart';
import 'package:encointer_wallet/page-encointer/bazaar/3_businesses/businesses.dart';
import 'package:encointer_wallet/page-encointer/bazaar/4_favorites/favorites.dart';
import 'package:encointer_wallet/utils/i18n/index.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:encointer_wallet/store/app.dart';

import 'bazaarMainState.dart';
import 'bazaarMenu.dart';
import 'bazaarTabBar.dart';

class BazaarMain extends StatelessWidget {
  static final String route = '/bazaar';

  final AppStore store;

  BazaarMain(this.store);

  @override
  Widget build(BuildContext context) => Provider<BazaarMainState>(
        create: (_) => BazaarMainState(),
        child: DefaultTabController(
          length: bazaarTabBar.length,
          child: Scaffold(
            appBar: AppBar(
              title: Text(I18n.of(context).bazaar['bazaar.title']),
              centerTitle: true,
              // leading: IconButton(icon: Image.asset('assets/images/assets/ERT.png'), onPressed: () => _chooseCommunity()), // TODO
              leading: IconButton(icon: Image.asset('assets/images/assets/ERT.png'), onPressed: () => null),
              bottom: TabBar(
                tabs: <Widget>[
                  Tab(icon: Icon(Icons.home), text: "Home"),
                  Tab(icon: Icon(Icons.local_offer), text: I18n.of(context).bazaar['offerings']),
                  Tab(icon: Icon(Icons.business), text: I18n.of(context).bazaar['businesses']),
                  Tab(icon: Icon(Icons.favorite, color: Colors.pink), text: I18n.of(context).bazaar['favorites']),
                ],
              ),
            ),
            endDrawer: BazaarMenu(),
            body: TabBarView(
              children: [
                Home(),
                Offerings(),
                Businesses(),
                Favorites(),
              ],
            ),
          ),
        ),
      );
}
