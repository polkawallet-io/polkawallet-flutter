import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:polka_wallet/utils/format.dart';

import 'package:polka_wallet/store/account.dart';

class Assets extends StatelessWidget {
  Assets(this.store);

  final AccountStore store;

  @override
  Widget build(BuildContext context) => Observer(
        builder: (_) => ListView(
          padding: EdgeInsets.only(left: 16, right: 16),
          children: <Widget>[
            _TopCard(store.currentAccount),
            Container(padding: EdgeInsets.only(top: 32)),
            Container(
              padding: EdgeInsets.only(left: 8),
              decoration: BoxDecoration(
                border: Border(left: BorderSide(width: 3, color: Colors.pink)),
              ),
              child: Text('Assets',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                      color: Colors.black54)),
            ),
            RaisedButton(
              child: Text('test', style: Theme.of(context).textTheme.display2),
              onPressed: () => Navigator.pushNamed(context, '/account/backup'),
            )
          ],
        ),
      );
}

class _TopCard extends StatelessWidget {
  _TopCard(this.account);

  final Account account;

  @override
  Widget build(BuildContext context) => Container(
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(
            borderRadius: const BorderRadius.all(const Radius.circular(8)),
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 16.0, // has the effect of softening the shadow
                spreadRadius: 4.0, // has the effect of extending the shadow
                offset: Offset(
                  2.0, // horizontal, move right 10
                  2.0, // vertical, move down 10
                ),
              )
            ]),
        child: Column(
          children: <Widget>[
            ListTile(
              leading: Image.asset('assets/images/assets/Assets_nav_0.png'),
              title: Text(account.name ?? ''),
              subtitle: Text(account.name ?? ''),
            ),
            ListTile(
              title: Text(Fmt.address(account.address) ?? ''),
              trailing: Image.asset('assets/images/assets/Assets_nav_code.png'),
            ),
          ],
        ),
      );
}
