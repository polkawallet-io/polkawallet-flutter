import 'dart:convert';
import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
import 'package:polka_wallet/store/account.dart';
import 'package:polka_wallet/store/settings.dart';

class Api {
  Api(
      {@required this.context,
      @required this.accountStore,
      @required this.settingsStore});

  final BuildContext context;
  final AccountStore accountStore;
  final SettingsStore settingsStore;

  Map<String, Function> _msgHandlers;
  FlutterWebviewPlugin _web;

  void init() {
    _initWebMsgHandler();

    _web = FlutterWebviewPlugin();

    _web.onStateChanged.listen((viewState) async {
      if (viewState.type == WebViewState.finishLoad) {
        print('webview loaded');

        DefaultAssetBundle.of(context)
            .loadString('lib/polkadot_js_service/dist/main.js')
            .then((String js) {
          print('js file loaded');
          _web.evalJavascript(js);
        });
      }
    });

    _web.launch('_blank',
        javascriptChannels: [
          JavascriptChannel(
              name: 'PolkaWallet',
              onMessageReceived: (JavascriptMessage message) {
                print('received msg: ${message.message}');
                final msg = jsonDecode(message.message);
                var handler = _msgHandlers[msg['path'] as String];
                if (handler == null) {
                  return;
                }
                handler(msg['data']);
              }),
        ].toSet(),
        withLocalUrl: true,
        localUrlScope: 'lib/polkadot_js_service/dist/',
        hidden: true);
  }

  void _initWebMsgHandler() {
    // fetch data after polkadotjs api ready
    void onWebReady(_) {
      evalJavascript('settings.getNetworkConst()');
      evalJavascript('api.rpc.system.chain()');
      evalJavascript('api.rpc.system.properties()');

      String accounts = jsonEncode(
          accountStore.accountList.map((i) => Account.toJson(i)).toList());
      evalJavascript('account.initKeys($accounts)');

      fetchBalance();
    }

    void onAccountGen(Map<String, dynamic> acc) {
      accountStore.setNewAccountKey(acc['mnemonic']);
    }

    void onAccountRecover(Map<String, dynamic> acc) async {
      await accountStore.addAccount(acc);
      fetchBalance();
    }

    void onTransfer(String hash) {
      print(hash);
    }

    _msgHandlers = {
      'ready': onWebReady,
      'settings.getNetworkConst': settingsStore.setNetworkConst,
      'api.rpc.system.chain': settingsStore.setNetworkName,
      'api.rpc.system.properties': settingsStore.setNetworkState,
      'account.gen': onAccountGen,
      'account.recover': onAccountRecover,
      'account.getBalance': accountStore.setAccountBalance,
      'account.transfer': onTransfer,
    };
  }

  void evalJavascript(String code) {
    String method = code.split('(')[0];
    String script = '$code.then(function(res) {'
        '  PolkaWallet.postMessage(JSON.stringify({ path: "$method", data: res }));'
        '}).catch(function(err) {'
        '  PolkaWallet.postMessage(JSON.stringify({ path: "log", data: err.message }));'
        '})';
    _web.evalJavascript(script);
  }

  void fetchBalance() async {
    String address = accountStore.currentAccount.address;
    if (address.length > 0) {
      evalJavascript('account.getBalance("$address")');
    }
  }

  void generateAccount() {
    evalJavascript('account.gen()');
  }

  void importAccount(
      {String keyType = 'Mnemonic', String cryptoType = 'sr25519'}) {
    String key = accountStore.newAccount.key;
    String name = accountStore.newAccount.name;
    String pass = accountStore.newAccount.password;
    String code =
        'account.recover("$keyType", "$cryptoType", "$key", "$name", "$pass")';
    evalJavascript(code);
  }

  void transfer(String to, double amount, String password) {
    String from = accountStore.currentAccount.address;
    double amt = amount * pow(10, settingsStore.networkState.tokenDecimals);
    evalJavascript(
        'account.transfer("$from", "$to", ${amt.toString()}, "$password")');
  }
}
