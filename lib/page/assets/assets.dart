import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:polka_wallet/store/app.dart';
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

  Widget _buildTopCard(BuildContext context) {
    var dic = I18n.of(context).assets;
    String network = store.settings.loading
        ? dic['node.connecting']
        : store.settings.networkName ?? dic['node.failed'];

    AccountData acc = store.account.currentAccount;
    return Container(
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
            title: Text(acc.name ?? ''),
            subtitle: Text(network),
          ),
          ListTile(
            title: Text(Fmt.address(acc.address) ?? ''),
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
    store.api.fetchBalance();
    super.initState();
  }

  @override
  Widget build(BuildContext context) => Observer(
        builder: (_) => ListView(
          padding: EdgeInsets.only(left: 16, right: 16),
          children: <Widget>[
            _buildTopCard(context),
            Container(padding: EdgeInsets.only(top: 32)),
            Container(
              padding: EdgeInsets.only(left: 8),
              decoration: BoxDecoration(
                border: Border(left: BorderSide(width: 3, color: Colors.pink)),
              ),
              child: Text(I18n.of(context).home['assets'],
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                      color: Colors.black54)),
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
                              'No Data',
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
                            child: Image.asset('assets/images/assets/KSC.png'),
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
      );
}
