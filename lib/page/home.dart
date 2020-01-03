import 'package:flutter/material.dart';
import 'package:polka_wallet/page/asset/assets.dart';
import 'package:polka_wallet/page/democracy/democracy.dart';
import 'package:polka_wallet/page/profile/profile.dart';
import 'package:polka_wallet/page/staking/staking.dart';

class Home extends StatefulWidget {
  @override
  _HomePageState createState() => new _HomePageState();
}

class _HomePageState extends State<Home> {
  int _curIndex = 0;

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      bottomNavigationBar: BottomNavigationBar(
          currentIndex: _curIndex,
//          iconSize: 22.0,
          onTap: (index) {
            setState(() {
              _curIndex = index;
            });
          },
          type: BottomNavigationBarType.fixed,
          items: [
            BottomNavigationBarItem(
              icon: Image.asset(_curIndex == 0
                  ? 'assets/images/public/Assets.png'
                  : 'assets/images/public/Assets_dark.png'),
              title: Text(
                'Assets',
                style: TextStyle(
                    color: _curIndex == 0 ? Colors.red : Colors.black),
              ),
            ),
            BottomNavigationBarItem(
              icon: Image.asset(_curIndex == 1
                  ? 'assets/images/public/Staking.png'
                  : 'assets/images/public/Staking_dark.png'),
              title: Text(
                'Staking',
                style: TextStyle(
                    color: _curIndex == 1 ? Colors.red : Colors.black),
              ),
            ),
            BottomNavigationBarItem(
              icon: Image.asset(_curIndex == 2
                  ? 'assets/images/public/Democracy.png'
                  : 'assets/images/public/Democracy_dark.png'),
              title: Text(
                'Democracy',
                style: TextStyle(
                    color: _curIndex == 2 ? Colors.red : Colors.black),
              ),
            ),
            BottomNavigationBarItem(
              icon: Image.asset(_curIndex == 3
                  ? 'assets/images/public/Profile.png'
                  : 'assets/images/public/Profile_dark.png'),
              title: Text(
                'Profile',
                style: TextStyle(
                    color: _curIndex == 3 ? Colors.red : Colors.black),
              ),
            ),
          ]),
      body: new Center(
        child: _getWidget(),
      ),
    );
  }

  Widget _getWidget() {
    switch (_curIndex) {
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
}
