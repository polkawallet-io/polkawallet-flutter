import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:polka_wallet/service/substrateApi/api.dart';
import 'package:polka_wallet/common/components/BorderedTitle.dart';
import 'package:polka_wallet/common/components/addressIcon.dart';
import 'package:polka_wallet/common/components/roundedCard.dart';
import 'package:polka_wallet/store/app.dart';
import 'package:polka_wallet/utils/UI.dart';
import 'package:polka_wallet/utils/format.dart';

import 'package:polka_wallet/store/account.dart';
import 'package:polka_wallet/utils/i18n/index.dart';

class Assets extends StatefulWidget {
  Assets(this.store);

  final AppStore store;

  @override
  _AssetsState createState() => _AssetsState(store);
}

class _AssetsState extends State<Assets> {
  _AssetsState(this.store);

  final AppStore store;

  bool _test = true;

  Widget _buildTopCard(BuildContext context) {
    var dic = I18n.of(context).assets;
    String network = store.settings.loading
        ? dic['node.connecting']
        : store.settings.networkName ?? dic['node.failed'];

    AccountData acc = store.account.currentAccount;
    String address = store.account.currentAddress;
    Map accInfo = store.account.accountIndexMap[address];

    return RoundedCard(
      padding: EdgeInsets.all(8),
      child: Column(
        children: <Widget>[
          ListTile(
            leading: AddressIcon(address: address),
            title: Text(acc.name ?? ''),
            subtitle: Text(
                accInfo == null ? network : accInfo['accountIndex'] ?? network),
          ),
          ListTile(
            title: Text(Fmt.address(address) ?? ''),
            trailing: IconButton(
              icon: Image.asset('assets/images/assets/Assets_nav_code.png'),
              onPressed: () {
                if (acc.address != '') {
                  Navigator.pushNamed(context, '/assets/receive');
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    if (!store.settings.loading && store.settings.networkName == null) {
      store.settings.setNetworkLoading(true);
      webApi.connectNode();
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) => Observer(
        builder: (_) => RefreshIndicator(
          key: globalBalanceRefreshKey,
          onRefresh: () async =>
              webApi.assets.fetchBalance(store.account.currentAddress),
          child: ListView(
            padding: EdgeInsets.only(left: 16, right: 16),
            children: <Widget>[
              _buildTopCard(context),
              Padding(
                padding: EdgeInsets.only(top: 32),
                child: BorderedTitle(
                  title: I18n.of(context).home['assets'],
                ),
              ),
              store.settings.loading
                  ? Padding(
                      padding: EdgeInsets.all(24),
                      child: CupertinoActivityIndicator())
                  : store.settings.networkName == null
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Padding(
                              padding: EdgeInsets.all(24),
                              child: Text(
                                I18n.of(context).home['data.empty'],
                                style: TextStyle(
                                    fontSize: 18, color: Colors.black38),
                              ),
                            )
                          ],
                        )
                      : Container(
                          margin: EdgeInsets.fromLTRB(0, 16, 0, 16),
                          decoration: BoxDecoration(
                              borderRadius: const BorderRadius.all(
                                  const Radius.circular(8)),
                              color: Colors.white,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black12,
                                  blurRadius:
                                      32.0, // has the effect of softening the shadow
                                  spreadRadius:
                                      2.0, // has the effect of extending the shadow
                                  offset: Offset(
                                    2.0, // horizontal, move right 10
                                    2.0, // vertical, move down 10
                                  ),
                                )
                              ]),
                          child: ListTile(
                            leading: Container(
                              width: 40,
                              height: 40,
                              child: Image.asset(
                                  'assets/images/public/${store.settings.endpoint.info}.png'),
                            ),
                            title: Text(
                                store.settings.networkState.tokenSymbol ?? ''),
                            subtitle: Text(store.settings.networkName ?? ''),
                            trailing: Text(
                              Fmt.balance(store.assets.balance),
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                  color: Colors.black54),
                            ),
                            onTap: () {
                              Navigator.pushNamed(context, '/assets/detail');
                            },
                          ),
                        ),
            ],
          ),
        ),
      );
}
