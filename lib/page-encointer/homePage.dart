import 'package:flutter/material.dart';
import 'package:polka_wallet/page-encointer/encointerEntry.dart';
import 'package:polka_wallet/page/assets/index.dart';
import 'package:polka_wallet/page/profile/index.dart';
import 'package:polka_wallet/service/notification.dart';
import 'package:polka_wallet/store/app.dart';

import 'package:polka_wallet/utils/i18n/index.dart';

class EncointerHomePage extends StatefulWidget {
  EncointerHomePage(this.store);

  static final String route = '/';
  final AppStore store;

  @override
  _EncointerHomePageState createState() => new _EncointerHomePageState(store);
}

class _EncointerHomePageState extends State<EncointerHomePage> {
  _EncointerHomePageState(this.store);

  final AppStore store;

  final PageController _pageController = PageController();

  NotificationPlugin _notificationPlugin;

  final List<String> _tabList = [
    'Assets',
    'Ceremonies',
//    'Governance',
    'Profile',
  ];

  List<BottomNavigationBarItem> _navBarItems(int activeItem) {
    Map<String, String> tabs = I18n.of(context).home;
    return _tabList
        .map((i) => BottomNavigationBarItem(
              icon: Image.asset(_tabList[activeItem] == i
                  ? 'assets/images/public/${i}_indigo.png'
                  : 'assets/images/public/${i}_dark.png'),
              title: Text(
                tabs[i.toLowerCase()] ?? 'Cermonies',
                style: TextStyle(
                    fontSize: 14,
                    color: _tabList[activeItem] == i
                        ? Colors.indigo
                        : Colors.grey),
              ),
            ))
        .toList();
  }

  Widget _getPage(i) {
    switch (i) {
      case 0:
        return Assets(store);
      case 1:
        return EncointerEntry(store);
//      case 2:
//        return Governance(store);
      default:
        return Profile(store);
    }
  }

  List<Widget> _buildPages() {
    return [0, 1, 2].map((i) {
      if (i == 0) {
        // return assets page
        return Stack(
          fit: StackFit.expand,
          children: <Widget>[
            Container(
              width: double.infinity,
              height: double.infinity,
              color: Theme.of(context).canvasColor,
            ),
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                image: DecorationImage(
                  alignment: Alignment.topLeft,
                  image: AssetImage("assets/images/assets/top_bg_indigo.png"),
                  fit: BoxFit.contain,
                ),
              ),
            ),
            Scaffold(
              backgroundColor: Colors.transparent,
              appBar: AppBar(
                title: Image.asset('assets/images/assets/logo.png'),
                centerTitle: false,
                backgroundColor: Colors.transparent,
                elevation: 0.0,
                actions: <Widget>[
                  IconButton(
                    icon: Icon(Icons.menu),
                    onPressed: () =>
                        Navigator.of(context).pushNamed('/network'),
                  ),
                ],
              ),
              bottomNavigationBar: BottomNavigationBar(
                  currentIndex: i,
                  iconSize: 22.0,
                  onTap: (index) {
                    _pageController.jumpToPage(index);
                  },
                  type: BottomNavigationBarType.fixed,
                  items: _navBarItems(i)),
              body: _getPage(i),
            )
          ],
        );
      }
      // return staking page
      return Stack(
        fit: StackFit.expand,
        children: <Widget>[
          Container(
            width: double.infinity,
            height: double.infinity,
            color: Theme.of(context).canvasColor,
          ),
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              image: DecorationImage(
                alignment: Alignment.topLeft,
                image: AssetImage(
                    "assets/images/${i == 1 ? 'staking' : 'assets'}/top_bg_indigo.png"),
                fit: BoxFit.contain,
              ),
            ),
          ),
          Scaffold(
            backgroundColor: Colors.transparent,
            bottomNavigationBar: BottomNavigationBar(
                currentIndex: i,
                iconSize: 22.0,
                onTap: (index) {
                  _pageController.jumpToPage(index);
                },
                type: BottomNavigationBarType.fixed,
                items: _navBarItems(i)),
            body: _getPage(i),
          )
        ],
      );
    }).toList();
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
    return PageView(
      controller: _pageController,
      children: _buildPages(),
    );
  }
}
