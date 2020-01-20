import 'package:flutter/material.dart';
import 'package:polka_wallet/page/assets/assets.dart';
import 'package:polka_wallet/page/assets/drawerMenu.dart';
import 'package:polka_wallet/page/democracy/democracy.dart';
import 'package:polka_wallet/page/profile/profile.dart';
import 'package:polka_wallet/page/staking/staking.dart';
import 'package:polka_wallet/store/account.dart';

import 'package:polka_wallet/utils/i18n/index.dart';

class Home extends StatefulWidget {
  Home(this.accountStore);

  final AccountStore accountStore;

  @override
  _HomePageState createState() => new _HomePageState(accountStore);
}

class _HomePageState extends State<Home> {
  _HomePageState(this.accountStore);

  final AccountStore accountStore;

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
        return Assets(accountStore);
        break;
      case 1:
        return Staking();
        break;
      case 2:
        return Democracy();
        break;
      default:
        return Profile(accountStore);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    Map<String, String> tabs = I18n.of(context).home;
    return _curIndex == 0
        ? Stack(
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
                  backgroundColor: Colors.transparent,
                  elevation: 0.0,
                ),
                endDrawer: Drawer(
                  child: DrawerMenu(accountStore),
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
                    items: _navBarItems(tabs)),
                body: _getPage(_curIndex),
              )
            ],
          )
        : Scaffold(
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
            body: _getPage(_curIndex),
          );
  }
}
