import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:provider/provider.dart';

import 'store/settings.dart';

import 'package:polka_wallet/page/home.dart';

void main() => runApp(WalletApp());

class WalletApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [
          Provider<SettingsStore>(
            create: (_) => SettingsStore(),
          ),
        ],
        child: Consumer<SettingsStore>(
          builder: (_, store, __) => Observer(
            builder: (_) => MaterialApp(
              title: 'PolkaWallet',
              initialRoute: '/',
              theme: ThemeData(
                primarySwatch: Colors.blue,
                brightness:
                    store.useDarkMode ? Brightness.dark : Brightness.light,
              ),
              routes: {
                '/': (_) => Home(),
              },
            ),
          ),
        ));
  }
}
