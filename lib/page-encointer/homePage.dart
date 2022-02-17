import 'package:encointer_wallet/common/theme.dart';
import 'package:encointer_wallet/page-encointer/encointerEntry.dart';
import 'package:encointer_wallet/page/account/scanPage.dart';
import 'package:encointer_wallet/page/assets/index.dart';
import 'package:encointer_wallet/page/profile/contacts/contactsPage.dart';
import 'package:encointer_wallet/page/profile/index.dart';
import 'package:encointer_wallet/service/notification.dart';
import 'package:encointer_wallet/store/app.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

import 'bazaar/0_main/bazaarMain.dart';

class EncointerHomePage extends StatefulWidget {
  EncointerHomePage(this.store);

  static final GlobalKey encointerHomePageKey = GlobalKey();
  static const String route = '/';
  final AppStore store;

  @override
  _EncointerHomePageState createState() => new _EncointerHomePageState(store);
}

class _EncointerHomePageState extends State<EncointerHomePage> {
  _EncointerHomePageState(this.store);

  final AppStore store;

  final PageController _pageController = PageController();

  NotificationPlugin _notificationPlugin;

  List<TabData> _tabList;
  int _tabIndex = 0;

  List<BottomNavigationBarItem> _navBarItems(int activeItem) {
    return _tabList
        .map(
          (i) => BottomNavigationBarItem(
            icon: _tabList[activeItem] == i
                ? ShaderMask(
                    blendMode: BlendMode.srcIn,
                    shaderCallback: (bounds) => primaryGradient.createShader(
                      Rect.fromLTWH(0, 0, bounds.width, bounds.height),
                    ),
                    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                      Icon(
                        i.iconData,
                        key: Key('${i.key.toString()}'),
                      ),
                      Container(
                        height: 4,
                        width: 16,
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(width: 2.0),
                          ),
                        ),
                      )
                    ]),
                  )
                : Icon(
                    i.iconData,
                    key: Key('${i.key.toString()}'),
                    color: i.key == TabKey.Scan ? ZurichLion.shade900 : encointerGrey,
                  ),
            label: '',
          ),
        )
        .toList();
  }

  @override
  void initState() {
    if (_notificationPlugin == null) {
      _notificationPlugin = NotificationPlugin();
      _notificationPlugin.init(context);
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    _tabList = <TabData>[
      TabData(
        TabKey.Wallet,
        Iconsax.home_2,
      ),
      if (store.settings.endpointIsGesell)
        TabData(
          TabKey.Bazaar,
          Iconsax.shop,
        ), // dart collection if
      TabData(
        TabKey.Ceremonies,
        Iconsax.calendar,
      ),
      TabData(
        TabKey.Scan,
        Iconsax.scan_barcode,
      ),
      TabData(
        TabKey.Contacts,
        Iconsax.profile_2user,
      ),
      TabData(
        TabKey.Profile,
        Iconsax.profile_circle,
      ),
    ];

    return Scaffold(
      key: EncointerHomePage.encointerHomePageKey,
      backgroundColor: Colors.white,
      body: PageView(
        controller: _pageController,
        children: [
          Assets(store),
          if (store.settings.endpointIsGesell) BazaarMain(store), // dart collection if
          EncointerEntry(store), // #272 we leave it in for now until we have a replacement
          ScanPage(store),
          ContactsPage(store),
          Profile(store),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _tabIndex,
        iconSize: 22.0,
        onTap: (index) async {
          if (_tabList[index].key == TabKey.Scan) {
            // Push `ScanPage.Route`instead of changing the Page.
            Navigator.of(context).pushNamed(ScanPage.route);
          } else {
            setState(() {
              _tabIndex = index;
              _pageController.jumpToPage(index);
            });
          }
        },
        type: BottomNavigationBarType.fixed,
        items: _navBarItems(_tabIndex),
        showSelectedLabels: false,
        showUnselectedLabels: false,
      ),
    );
  }
}

class TabData {
  /// used for our integration tests to click on a UI element
  final TabKey key;

  /// used for our integration tests to click on a UI element
  final IconData iconData;

  TabData(this.key, this.iconData);
}

enum TabKey {
  Wallet,
  Bazaar,
  Ceremonies,
  Scan,
  Contacts,
  Profile,
}
