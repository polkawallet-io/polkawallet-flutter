import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:polka_wallet/service/api.dart';
import 'package:polka_wallet/utils/format.dart';
import 'package:polka_wallet/utils/i18n/index.dart';

import 'package:polka_wallet/store/account.dart';

class DrawerMenu extends StatelessWidget {
  DrawerMenu(this.api, this.store);

  final Api api;
  final AccountStore store;

  List<ListTile> _buildAccList(BuildContext context) {
    return store.optionalAccounts
        .map((i) => ListTile(
              leading: Container(
                width: 40,
                height: 40,
                child: Image.asset('assets/images/assets/Assets_nav_0.png'),
              ),
              title: Text(i.name ?? 'name',
                  style: TextStyle(fontSize: 16, color: Colors.white)),
              subtitle: Text(
                Fmt.address(i.address) ?? '',
                style: TextStyle(fontSize: 16, color: Colors.white70),
              ),
              onTap: () {
                Navigator.pop(context);
                store.setCurrentAccount(i);
                api.fetchBalance();
              },
            ))
        .toList();
  }

  @override
  Widget build(BuildContext context) => Observer(
        builder: (_) => Container(
          color: Colors.indigoAccent,
          child: Column(
            children: <Widget>[
              Container(
                padding: EdgeInsets.fromLTRB(16, 28, 0, 28),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(
                      I18n.of(context).home['menu'],
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                    IconButton(
                      icon: Icon(Icons.menu),
                      color: Colors.white,
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              Container(
                color: Colors.indigo,
                child: ListTile(
                  leading: Container(
                    width: 40,
                    height: 40,
                    child: Image.asset('assets/images/assets/Assets_nav_0.png'),
                  ),
                  title: Text(store.currentAccount.name ?? 'name',
                      style: TextStyle(fontSize: 16, color: Colors.white)),
                  subtitle: Text(
                    Fmt.address(store.currentAccount.address) ?? '',
                    style: TextStyle(fontSize: 16, color: Colors.white70),
                  ),
                ),
              ),
              ..._buildAccList(context),
              Divider(),
              ListTile(
                leading: Container(
                  width: 40,
                  height: 40,
                  child: Image.asset('assets/images/assets/Menu_scan.png'),
                ),
                title: Text(I18n.of(context).home['scan'],
                    style: TextStyle(fontSize: 16, color: Colors.white)),
                onTap: () => Navigator.pushNamed(context, '/account/scan',
                    arguments: 'tx'),
              ),
              ListTile(
                leading: Container(
                  width: 40,
                  height: 40,
                  child: Image.asset('assets/images/assets/Menu_create.png'),
                ),
                title: Text(I18n.of(context).home['create'],
                    style: TextStyle(fontSize: 16, color: Colors.white)),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, '/account/entry');
                },
              )
            ],
          ),
        ),
      );
}
