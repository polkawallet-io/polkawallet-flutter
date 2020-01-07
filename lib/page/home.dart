import 'package:flutter/material.dart';
import 'package:polka_wallet/page/assets/assets.dart';
import 'package:polka_wallet/page/assets/drawerMenu.dart';
import 'package:polka_wallet/page/democracy/democracy.dart';
import 'package:polka_wallet/page/profile/profile.dart';
import 'package:polka_wallet/page/staking/staking.dart';

import 'package:polka_wallet/utils/i18n.dart';

class Home extends StatefulWidget {
  @override
  _HomePageState createState() => new _HomePageState();
}

class _HomePageState extends State<Home> {
  int _curIndex = 0;

  List<BottomNavigationBarItem> _navBarItems(Map<String, String> tabs) {
    return [
      BottomNavigationBarItem(
        icon: Image.asset(_curIndex == 0
            ? 'assets/images/public/Assets.png'
            : 'assets/images/public/Assets_dark.png'),
        title: Text(
          tabs['assets'],
          style: TextStyle(
              fontSize: 14, color: _curIndex == 0 ? Colors.pink : Colors.grey),
        ),
      ),
      BottomNavigationBarItem(
        icon: Image.asset(_curIndex == 1
            ? 'assets/images/public/Staking.png'
            : 'assets/images/public/Staking_dark.png'),
        title: Text(
          tabs['staking'],
          style: TextStyle(
              fontSize: 14, color: _curIndex == 1 ? Colors.pink : Colors.grey),
        ),
      ),
      BottomNavigationBarItem(
        icon: Image.asset(_curIndex == 2
            ? 'assets/images/public/Democracy.png'
            : 'assets/images/public/Democracy_dark.png'),
        title: Text(
          tabs['democracy'],
          style: TextStyle(
              fontSize: 14, color: _curIndex == 2 ? Colors.pink : Colors.grey),
        ),
      ),
      BottomNavigationBarItem(
        icon: Image.asset(_curIndex == 3
            ? 'assets/images/public/Profile.png'
            : 'assets/images/public/Profile_dark.png'),
        title: Text(
          tabs['profile'],
          style: TextStyle(
              fontSize: 14, color: _curIndex == 3 ? Colors.pink : Colors.grey),
        ),
      ),
    ];
  }

  Widget _getPage(i) {
    switch (i) {
      case 0:
        return Container(
          child: Assets(),
        );
        break;
      case 1:
        return Container(
          child: Staking(),
        );
        break;
      case 2:
        return Container(
          child: Democracy(),
        );
        break;
      default:
        return Container(
          child: Profile(),
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    Map<String, String> tabs = I18n.of(context).home;
    return new Scaffold(
      appBar: _curIndex == 0
          ? AppBar(
              title: Image.asset('assets/images/assets/logo.png'),
            )
          : null,
      endDrawer: _curIndex == 0
          ? Drawer(
              child: DrawerMenu(),
            )
          : null,
      bottomNavigationBar: BottomNavigationBar(
          currentIndex: _curIndex,
          iconSize: 22.0,
          onTap: (index) {
            setState(() {
              _curIndex = index;
            });
          },
          type: BottomNavigationBarType.fixed,
          items: _navBarItems(tabs)),
      body: new Center(
        child: _getPage(_curIndex),
      ),
    );
  }
}
