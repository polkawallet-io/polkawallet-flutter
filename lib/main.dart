import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';

import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'utils/i18n.dart';
import 'common/theme.dart';

import 'package:polka_wallet/store/assets.dart';

import 'package:polka_wallet/page/home.dart';
import 'package:polka_wallet/page/assets/secondary/createAccount/createAccount.dart';
import 'package:polka_wallet/page/assets/secondary/createAccount/backupAccount.dart';
import 'package:polka_wallet/page/assets/secondary/importAccount.dart';

void main() => runApp(WalletApp());

class WalletApp extends StatefulWidget {
  const WalletApp();

  @override
  _WalletAppState createState() => _WalletAppState();
}

class _WalletAppState extends State<WalletApp> {
  final _assetsStore = AssetsStore();

  FlutterWebviewPlugin webview;

  Map<String, Function> _msgHandlers;

  @override
  void initState() {
    _msgHandlers = {
      'ready': (data) {
        String address = _assetsStore.currentAccount['address'];
        if (address.length > 0) {
          evalJavascript('api.query.balances.freeBalance("$address")');
        }
      },
      'account.gen': _assetsStore.setNewAccount
    };

    _initWebView();

    _assetsStore.loadAccount();

    super.initState();
  }

  void evalJavascript(String code) {
    String method = code.split('(')[0];
    String script = '$code.then(function(res) {'
        '  PolkaWallet.postMessage(JSON.stringify({ path: "$method", data: res }));'
        '}).catch(function(err) {'
        '  PolkaWallet.postMessage(JSON.stringify({ path: "log", data: err }));'
        '})';
    webview.evalJavascript(script);
  }

  void _initWebView() async {
    webview = new FlutterWebviewPlugin();

    webview.onStateChanged.listen((viewState) async {
      if (viewState.type == WebViewState.finishLoad) {
        print('webview loaded');

        DefaultAssetBundle.of(context)
            .loadString('lib/polkadot_js_service/dist/main.js')
            .then((String js) {
          print('js file loaded');
          webview.evalJavascript(js);
        });
      }
    });

    webview.launch('_blank',
        javascriptChannels: [
          JavascriptChannel(
              name: 'PolkaWallet',
              onMessageReceived: (JavascriptMessage message) {
                print('received msg: ${message.message}');
                final msg = jsonDecode(message.message);
                var handler = _msgHandlers[msg['path'] as String];
                if (handler == null) {
//                  print("no msg res handler");
                  return;
                }
                handler(msg['data']);
              }),
        ].toSet(),
        withLocalUrl: true,
        hidden: true);
  }

  @override
  void dispose() {
    webview.dispose();
    webview.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PolkaWallet',
      localizationsDelegates: [
        const AppLocalizationsDelegate(),
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: [
        const Locale('en', ''),
        const Locale('zh', ''),
      ],
      initialRoute: '/',
      theme: appTheme,
      routes: {
        '/': (_) => Home(_assetsStore),
        '/account/create': (_) => CreateAccount(_assetsStore.setNewAccount),
        '/account/backup': (_) => Observer(builder: (_) {
              print('route');
              print(_assetsStore.newAccount['address']);
              return BackupAccount(evalJavascript, _assetsStore);
            }),
        '/account/import': (_) => Observer(builder: (_) {
              print('route');
              print(_assetsStore.newAccount['address']);
              return ImportAccount(evalJavascript, _assetsStore.newAccount);
            }),
      },
    );
  }
}
