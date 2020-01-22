import 'package:flutter/material.dart';
import 'package:polka_wallet/page/assets/assets.dart';
import 'package:polka_wallet/page/assets/drawerMenu.dart';
import 'package:polka_wallet/page/democracy/democracy.dart';
import 'package:polka_wallet/page/profile/profile.dart';
import 'package:polka_wallet/page/staking/staking.dart';
import 'package:polka_wallet/service/api.dart';
import 'package:polka_wallet/store/account.dart';
import 'package:polka_wallet/store/settings.dart';

import 'package:polka_wallet/utils/i18n/index.dart';

class Home extends StatefulWidget {
  Home(this.api, this.settingStore, this.accountStore);

  final Api api;
  final SettingsStore settingStore;
  final AccountStore accountStore;

  @override
  _HomePageState createState() =>
      new _HomePageState(api, settingStore, accountStore);
}

class _HomePageState extends State<Home> {
  _HomePageState(this.api, this.settingsStore, this.accountStore);

  final Api api;
  final SettingsStore settingsStore;
  final AccountStore accountStore;

  final List<String> _tabList = [
    'Assets',
    'Staking',
    'Democracy',
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
        return Assets(settingsStore, accountStore);
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
  void initState() {
    api.fetchBalance();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
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
                  child: DrawerMenu(api, accountStore),
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
          )
        : Scaffold(
            bottomNavigationBar: BottomNavigationBar(
                currentIndex: _curIndex,
                iconSize: 22.0,
                onTap: (index) {
                  if (index == 0) {
                    api.fetchBalance();
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
