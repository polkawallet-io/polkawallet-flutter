import 'package:flutter/material.dart';
import 'package:polka_wallet/page/assets/assets.dart';
import 'package:polka_wallet/page/assets/drawerMenu.dart';
import 'package:polka_wallet/page/democracy/democracy.dart';
import 'package:polka_wallet/page/profile/profile.dart';
import 'package:polka_wallet/page/staking/staking.dart';
import 'package:polka_wallet/store/app.dart';

import 'package:polka_wallet/utils/i18n/index.dart';

class Home extends StatefulWidget {
  Home(this.store);

  final AppStore store;

  @override
  _HomePageState createState() => new _HomePageState(store);
}

class _HomePageState extends State<Home> {
  _HomePageState(this.store);

  final AppStore store;

  final List<String> _tabList = [
    'Assets',
    'Staking',
//    'Democracy',
    'Profile',
  ];

  int _curIndex = 0;

  List<BottomNavigationBarItem> _navBarItems() {
    Map<String, String> tabs = I18n.of(context).home;
    return _tabList
        .map((i) => BottomNavigationBarItem(
              icon: Image.asset(_tabList[_curIndex] == i
                  ? 'assets/images/public/$i.png'
                  : 'assets/images/public/${i}_dark.png'),
              title: Text(
                tabs[i.toLowerCase()],
                style: TextStyle(
                    fontSize: 14,
                    color:
                        _tabList[_curIndex] == i ? Colors.pink : Colors.grey),
              ),
            ))
        .toList();
  }

  Widget _getPage(i) {
    switch (i) {
      case 0:
        return Assets(store);
        break;
      case 1:
        return Staking(store);
        break;
//      case 2:
//        return Democracy();
//        break;
      default:
        return Profile(store.account);
    }
  }

  @override
  void initState() {
    super.initState();
    if (!store.settings.loading) {
      store.api.fetchBalance();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_curIndex == 0) {
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
                image: AssetImage("assets/images/assets/Assets_bg.png"),
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
            ),
            endDrawer: Drawer(
              child: DrawerMenu(store),
            ),
            bottomNavigationBar: BottomNavigationBar(
                currentIndex: _curIndex,
                iconSize: 22.0,
                onTap: (index) {
                  setState(() {
                    _curIndex = index;
                  });
                },
                type: BottomNavigationBarType.fixed,
                items: _navBarItems()),
            body: _getPage(_curIndex),
          )
        ],
      );
    }
    if (_curIndex == 1) {
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
                image: AssetImage("assets/images/staking/top_bg.png"),
                fit: BoxFit.contain,
              ),
            ),
          ),
          Scaffold(
            backgroundColor: Colors.transparent,
            appBar: AppBar(
              title: Text(I18n.of(context).home['staking']),
              centerTitle: true,
              backgroundColor: Colors.transparent,
              elevation: 0.0,
            ),
            bottomNavigationBar: BottomNavigationBar(
                currentIndex: _curIndex,
                iconSize: 22.0,
                onTap: (index) {
                  setState(() {
                    _curIndex = index;
                  });
                },
                type: BottomNavigationBarType.fixed,
                items: _navBarItems()),
            body: _getPage(_curIndex),
          )
        ],
      );
    }
    return Scaffold(
      bottomNavigationBar: BottomNavigationBar(
          currentIndex: _curIndex,
          iconSize: 22.0,
          onTap: (index) {
            if (index == 0) {
              store.api.fetchBalance();
            }
            setState(() {
              _curIndex = index;
            });
          },
          type: BottomNavigationBarType.fixed,
          items: _navBarItems()),
      body: _getPage(_curIndex),
    );
  }
}
