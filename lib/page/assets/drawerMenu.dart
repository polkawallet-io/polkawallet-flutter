import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:polka_wallet/page/account/createAccountEntryPage.dart';
import 'package:polka_wallet/page/account/scanPage.dart';
import 'package:polka_wallet/service/substrateApi/api.dart';
import 'package:polka_wallet/common/components/addressIcon.dart';
import 'package:polka_wallet/store/app.dart';
import 'package:polka_wallet/utils/UI.dart';
import 'package:polka_wallet/utils/format.dart';
import 'package:polka_wallet/utils/i18n/index.dart';

class DrawerMenu extends StatelessWidget {
  DrawerMenu(this.store);

  final AppStore store;

  List<Widget> _buildAccList(BuildContext context) {
    return store.account.optionalAccounts.map((i) {
      String address = store
          .account.pubKeyAddressMap[store.settings.endpoint.info][i.pubKey];
      return ListTile(
        leading: AddressIcon(i.address, pubKey: i.pubKey, size: 36),
        title: Text(i.name ?? 'name',
            style: TextStyle(fontSize: 16, color: Colors.white)),
        subtitle: Text(
          Fmt.address(address ?? i.address),
          style: TextStyle(fontSize: 16, color: Colors.white70),
        ),
        onTap: () {
          Navigator.pop(context);
          store.account.setCurrentAccount(i.pubKey);
          // refresh balance
          store.assets.loadAccountCache();
          globalBalanceRefreshKey.currentState.show();
          // refresh user's staking info
          store.staking.loadAccountCache();
          webApi.staking.fetchAccountStaking();
        },
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Observer(
      builder: (_) => Container(
        color: Colors.indigoAccent,
        child: Column(
          children: <Widget>[
            Container(
              padding: EdgeInsets.fromLTRB(16, 36, 0, 28),
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
                leading: AddressIcon('',
                    pubKey: store.account.currentAccount.pubKey, size: 36),
                title: Text(store.account.currentAccount.name ?? 'name',
                    style: TextStyle(fontSize: 16, color: Colors.white)),
                subtitle: Text(
                  Fmt.address(store.account.currentAddress) ?? '',
                  style: TextStyle(fontSize: 16, color: Colors.white70),
                ),
              ),
            ),
            Column(
              children: _buildAccList(context),
            ),
            Divider(),
            ListTile(
              leading: Container(
                width: 40,
                height: 40,
                child: Image.asset('assets/images/assets/Menu_scan.png'),
              ),
              title: Text(I18n.of(context).home['scan'],
                  style: TextStyle(fontSize: 16, color: Colors.white)),
              onTap: () =>
                  Navigator.pushNamed(context, ScanPage.route, arguments: 'tx'),
            ),
            ListTile(
              leading: Container(
                width: 40,
                height: 40,
                child: Image.asset('assets/images/assets/Menu_wallet.png'),
              ),
              title: Text(I18n.of(context).home['create'],
                  style: TextStyle(fontSize: 16, color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, CreateAccountEntryPage.route);
              },
            )
          ],
        ),
      ),
    );
  }
}
