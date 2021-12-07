import 'package:encointer_wallet/page-encointer/bazaar/1_home/home.dart';
import 'package:encointer_wallet/page-encointer/bazaar/2_offerings/offerings.dart';
import 'package:encointer_wallet/page-encointer/bazaar/3_businesses/businesses.dart';
import 'package:encointer_wallet/page-encointer/bazaar/4_favorites/favorites.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'bazaarMainState.dart';
import 'bazaarMenu.dart';
import 'bazaarTabBar.dart';

class BazaarMain extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Provider<BazaarMainState>(
        create: (_) => BazaarMainState(),
        child: DefaultTabController(
          length: bazaarTabBar.length,
          child: Scaffold(
            appBar: AppBar(
              title: Text("The Bazaar"),
              centerTitle: true,
              // leading: IconButton(icon: Image.asset('assets/images/assets/ERT.png'), onPressed: () => _chooseCommunity()), // TODO
              leading: IconButton(icon: Image.asset('assets/images/assets/ERT.png'), onPressed: () => null),
              bottom: TabBar(
                tabs: bazaarTabBar,
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