import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:polka_wallet/store/assets.dart';
import 'package:provider/provider.dart';

import 'package:flutter_liquidcore/liquidcore.dart';

import 'package:polka_wallet/page/home.dart';
import 'package:polka_wallet/page/assets/secondary/createAccount.dart';

void main() => runApp(WalletApp());

class WalletApp extends StatefulWidget {
  const WalletApp();

  @override
  State<StatefulWidget> createState() => _WalletAppState();
}

class _WalletAppState extends State<WalletApp> with TickerProviderStateMixin {
  final AssetsStore assetsStore = AssetsStore();

  MicroService service;

  @override
  void initState() {
    Map<String, Function> msgHandlers = {
      '/account/gen': assetsStore.setNewAccount,
    };
    _initService(msgHandlers);

    super.initState();
  }

  Future<void> _initService(Map<String, Function> messageHandlers) async {
    if (service == null) {
      String uri = "@flutter_assets/lib/polkadot_js_service/liquid.bundle";

      service = new MicroService(uri);
      await service.addEventListener('ready', (service, event, payload) {
        // The service is ready.
        print('js service ready');
      });
      await service.addEventListener('pong', (service, event, payload) {
        print(DateTime.now());
      });
      await service.addEventListener('res', (service, event, payload) {
        print("received res: $payload | type: ${payload.runtimeType}");
        messageHandlers[payload['path'] as String](
            new Map<String, dynamic>.from(payload));
      });

      // Start the service.
      await service.start();
    }
    return service;
  }

  void emitMsg(String event, dynamic msg) {
    service.emit(event, msg);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PolkaWallet',
      initialRoute: '/',
      theme: ThemeData(
        primarySwatch: Colors.pink,
//                brightness:
//                    store.useDarkMode ? Brightness.dark : Brightness.light,
      ),
      routes: {
        '/': (_) => Home(),
        '/account/create': (_) => CreateAccount(emitMsg),
      },
    );
  }
}