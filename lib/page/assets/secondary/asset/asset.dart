import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:polka_wallet/store/account.dart';
import 'package:polka_wallet/store/settings.dart';
import 'package:polka_wallet/utils/i18n/index.dart';

class AssetPage extends StatelessWidget {
  AssetPage(this.accountStore, this.settingsStore);

  final AccountStore accountStore;
  final SettingsStore settingsStore;

  @override
  Widget build(BuildContext context) {
    return Observer(
        builder: (_) => Scaffold(
              appBar: AppBar(
                title: Text(settingsStore.networkState.tokenSymbol),
                centerTitle: true,
              ),
              body: Column(
                children: <Widget>[
                  Expanded(
                    child: ListView(
                      children: <Widget>[
                        Padding(
                          padding: EdgeInsets.all(32),
                          child: Text(
                              'test: ${accountStore.assetsState.txs.length}'),
                        ),
                      ],
                    ),
                  ),
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: Container(
                          color: Colors.lightBlue,
                          child: FlatButton(
                            padding: EdgeInsets.all(16),
                            child: Text(
                              I18n.of(context).assets['transfer'],
                              style: TextStyle(color: Colors.white),
                            ),
                            onPressed: () {
                              Navigator.pushNamed(context, '/assets/transfer');
                            },
                          ),
                        ),
                      ),
                      Expanded(
                        child: Container(
                          color: Colors.lightGreen,
                          child: FlatButton(
                            padding: EdgeInsets.all(16),
                            child: Text(
                              I18n.of(context).assets['receive'],
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                      )
                    ],
                  )
                ],
              ),
            ));
  }
}
