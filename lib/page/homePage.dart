import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:polka_wallet/common/consts/settings.dart';
import 'package:polka_wallet/page-laminar/laminarEntry.dart';
import 'package:polka_wallet/page/assets/index.dart';
import 'package:polka_wallet/page/staking/index.dart';
import 'package:polka_wallet/page/governance/index.dart';
import 'package:polka_wallet/page/profile/index.dart';
import 'package:polka_wallet/service/notification.dart';
import 'package:polka_wallet/store/app.dart';

import 'package:polka_wallet/utils/i18n/index.dart';

class HomePage extends StatefulWidget {
  HomePage(this.store);

  static final String route = '/';
  final AppStore store;

  @override
  _HomePageState createState() => new _HomePageState(store);
}

class _HomePageState extends State<HomePage> {
  _HomePageState(this.store);

  final AppStore store;

  final PageController _pageController = PageController();

  NotificationPlugin _notificationPlugin;

  List<String> _tabList = [];

  final List<String> _tabListKusama = [
    'Assets',
    'Staking',
    'Governance',
    'Profile',
  ];

  final List<String> _tabListLaminar = [
    'Assets',
    'Flow',
    'Profile',
  ];

  List<BottomNavigationBarItem> _navBarItems(int activeItem) {
    Map<String, String> tabs = I18n.of(context).home;
    return _tabList.map((i) {
      String icon = i == 'Flow' ? 'Acala' : i;
      return BottomNavigationBarItem(
        icon: Image.asset(_tabList[activeItem] == i
            ? 'assets/images/public/${icon}_${store.settings.endpoint.color ?? 'pink'}.png'
            : 'assets/images/public/${icon}_dark.png'),
        title: Text(
          tabs[i.toLowerCase()],
          style: TextStyle(
              fontSize: 14,
              color: _tabList[activeItem] == i
                  ? Theme.of(context).primaryColor
                  : Colors.grey),
        ),
      );
    }).toList();
  }

  Widget _getPage(i) {
    final isLaminar =
        networkEndpointLaminar.info == store.settings.endpoint.info;
    if (isLaminar) {
      switch (i) {
        case 0:
          return Assets(store);
        case 1:
          return LaminarEntry(store);
        default:
          return Profile(store);
      }
    }
    switch (i) {
      case 0:
        return Assets(store);
      case 1:
        return Staking(store);
      case 2:
        return Governance(store);
      default:
        return Profile(store);
    }
  }

  List<Widget> _buildPages() {
    String imageColor = store.settings.endpoint.color ?? 'pink';
    return _tabList.asMap().keys.map((i) {
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
                  image:
                      AssetImage("assets/images/assets/top_bg_$imageColor.png"),
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
                image:
                    AssetImage("assets/images/staking/top_bg_$imageColor.png"),
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
  void didChangeDependencies() {
    super.didChangeDependencies();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final isLaminar =
          networkEndpointLaminar.info == store.settings.endpoint.info;
      if (isLaminar && _tabList.length != _tabListLaminar.length) {
        setState(() {
          _tabList = _tabListLaminar;
        });
      }
      if (!isLaminar && _tabList.length != _tabListKusama.length) {
        setState(() {
          _tabList = _tabListKusama;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return PageView(
      controller: _pageController,
      children: _buildPages(),
    );
  }
}
