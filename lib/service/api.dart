import 'dart:async';
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
          connectNode();
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
      evalJavascript('api.rpc.system.properties()');
      evalJavascript('api.rpc.system.chain()');

      String accounts = jsonEncode(
          accountStore.accountList.map((i) => Account.toJson(i)).toList());
      evalJavascript('account.initKeys($accounts)');

      fetchBalance();
    }

    void onWebConnectError(_) {
      print('connect failed');
      settingsStore.setNetworkName(null);
    }

    void onAccountGen(Map<String, dynamic> acc) {
      accountStore.setNewAccountKey(acc['mnemonic']);
    }

    void onAccountRecover(Map<String, dynamic> acc) async {
      acc['name'] = accountStore.newAccount.name;
      await accountStore.addAccount(acc);
      fetchBalance();
    }

    void onBlockTime(String data) {
      accountStore.assetsState.setBlockMap(data);
    }

    _msgHandlers = {
      'settings.connect': onWebReady,
      'settings.connect.error': onWebConnectError,
      'settings.changeEndpoint': onWebReady,
      'settings.changeEndpoint.error': onWebConnectError,
      'settings.getNetworkConst': settingsStore.setNetworkConst,
      'api.rpc.system.chain': settingsStore.setNetworkName,
      'api.rpc.system.properties': settingsStore.setNetworkState,
      'account.gen': onAccountGen,
      'account.recover': onAccountRecover,
      'account.getBalance': accountStore.assetsState.setAccountBalance,
      'account.getBlockTime': onBlockTime,
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

  void connectNode() {
    String value =
        settingsStore.endpoint.value ?? 'wss://kusama-rpc.polkadot.io/';
    _web.evalJavascript('settings.connect("$value")');
  }

  void changeNode(String endpoint) {
    settingsStore.setNetworkLoading(true);
    _web.evalJavascript('settings.changeEndpoint("$endpoint")');
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
    String pass = accountStore.newAccount.password;
    String code = 'account.recover("$keyType", "$cryptoType", "$key", "$pass")';
    evalJavascript(code);
  }

  void updateTxs() {
    accountStore.assetsState
        .getTxs(accountStore.currentAccount.address)
        .then((ids) {
      Map<int, bool> blocksNeedUpdate = Map<int, bool>();
      ids.forEach((i) {
        if (accountStore.assetsState.blockMap[i] == null) {
          blocksNeedUpdate[i] = true;
        }
      });
      String blocks = blocksNeedUpdate.keys.join(',');
      evalJavascript('account.getBlockTime([$blocks])');
    });

    fetchBalance();
  }

  void transfer(String to, double amount, String password, Function onSuccess,
      Function onError) {
    _msgHandlers['account.transfer'] = onSuccess;
    _msgHandlers['account.transfer.error'] = onError;

    String from = accountStore.currentAccount.address;
    double amt = amount * pow(10, settingsStore.networkState.tokenDecimals);
    evalJavascript(
        'account.transfer("$from", "$to", ${amt.toString()}, "$password")');
  }

  Future<dynamic> changeAccountPassword(String passOld, String passNew) async {
    Completer c = new Completer();
    void onComplete(Map<String, dynamic> res) {
      c.complete(res);
    }

    _msgHandlers['account.changePassword'] = onComplete;

    String address = accountStore.currentAccount.address;
    evalJavascript(
        'account.changePassword("$address", "$passOld", "$passNew")');
    return c.future;
  }

  Future<dynamic> checkAccountPassword(String pass) async {
    Completer c = new Completer();
    void onComplete(Map<String, dynamic> res) {
      c.complete(res);
    }

    _msgHandlers['account.checkPassword'] = onComplete;

    String address = accountStore.currentAccount.address;
    evalJavascript('account.checkPassword("$address", "$pass")');
    return c.future;
  }
}
