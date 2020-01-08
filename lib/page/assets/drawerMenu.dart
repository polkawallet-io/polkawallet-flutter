import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:polka_wallet/utils/i18n.dart';

import 'package:polka_wallet/store/assets.dart';

class DrawerMenu extends StatelessWidget {
  List<ListTile> _buildAccList() {
    return [
      ListTile(
        leading: Icon(
          Icons.account_circle,
          color: Colors.white,
        ),
        title: Text('Address',
            style: TextStyle(fontSize: 16, color: Colors.white)),
      )
    ];
  }

  @override
  Widget build(BuildContext context) => Provider<AssetsStore>(
      create: (_) => AssetsStore(),
      child: Container(
        color: Colors.indigo,
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
            ..._buildAccList(),
            ListTile(
              leading: Icon(
                Icons.scanner,
                color: Colors.white,
              ),
              title: Text(I18n.of(context).home['scan'],
                  style: TextStyle(fontSize: 16, color: Colors.white)),
            ),
            ListTile(
              leading: Icon(
                Icons.account_balance_wallet,
                color: Colors.white,
              ),
              title: Text(I18n.of(context).home['create'],
                  style: TextStyle(fontSize: 16, color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/account/create');
              },
            )
          ],
        ),
      ));
}
