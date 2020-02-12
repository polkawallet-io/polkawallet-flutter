import 'dart:async';
import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
import 'package:polka_wallet/service/polkascan.dart';
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

  Map<String, Function> _msgHandlers = {};
  FlutterWebviewPlugin _web;

  void init() {
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

    _web.launch('about:blank',
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
//        withLocalUrl: true,
//        localUrlScope: 'lib/polkadot_js_service/dist/',
        hidden: true);
  }

  Future<dynamic> evalJavascript(String code) async {
    Completer c = new Completer();
    void onComplete(res) {
      c.complete(res);
    }

    String method = code.split('(')[0];
    _msgHandlers[method] = onComplete;

    String script = '$code.then(function(res) {'
        '  PolkaWallet.postMessage(JSON.stringify({ path: "$method", data: res }));'
        '}).catch(function(err) {'
        '  PolkaWallet.postMessage(JSON.stringify({ path: "log", data: err.message }));'
        '})';
    _web.evalJavascript(script);

    return c.future;
  }

  Future<void> fetchNetworkProps() async {
    String accounts = jsonEncode(
        accountStore.accountList.map((i) => Account.toJson(i)).toList());

    List<dynamic> info = await Future.wait([
      evalJavascript('settings.getNetworkConst()'),
      evalJavascript('api.rpc.system.properties()'),
      evalJavascript('api.rpc.system.chain()'),
      evalJavascript('account.initKeys($accounts)'),
      fetchBalance(),
    ]);

    settingsStore.setNetworkConst(info[0]);
    settingsStore.setNetworkState(info[1]);
    settingsStore.setNetworkName(info[2]);
  }

  Future<void> connectNode() async {
    String value =
        settingsStore.endpoint.value ?? 'wss://kusama-rpc.polkadot.io/';
    String res = await evalJavascript('settings.connect("$value")');
    if (res == null) {
      print('connect failed');
      settingsStore.setNetworkName(null);
      return;
    }
    fetchNetworkProps();
  }

  Future<void> changeNode(String endpoint) async {
    settingsStore.setNetworkLoading(true);
    String res = await evalJavascript('settings.changeEndpoint("$endpoint")');
    if (res == null) {
      print('connect failed');
      settingsStore.setNetworkName(null);
      return;
    }
    fetchNetworkProps();
  }

  Future<void> fetchBalance() async {
    String address = accountStore.currentAccount.address;
    if (address.length > 0) {
      var res = await evalJavascript('account.getBalance("$address")');
      accountStore.assetsState.setAccountBalance(res);
    }
  }

  Future<void> generateAccount() async {
    Map<String, dynamic> acc = await evalJavascript('account.gen()');
    accountStore.setNewAccountKey(acc['mnemonic']);
  }

  Future<void> importAccount(
      {String keyType = 'Mnemonic', String cryptoType = 'sr25519'}) async {
    String key = accountStore.newAccount.key;
    String pass = accountStore.newAccount.password;
    String code = 'account.recover("$keyType", "$cryptoType", "$key", "$pass")';
    Map<String, dynamic> acc = await evalJavascript(code);

    acc['name'] = accountStore.newAccount.name;
    await accountStore.addAccount(acc);
    fetchBalance();
  }

  Future<void> updateTxs() async {
    accountStore.assetsState.setLoading(true);
    String data =
        await PolkaScanApi.fetchTxs(accountStore.currentAccount.address);
    List ls = jsonDecode(data)['data'];

    await accountStore.assetsState.setTxs(ls);

    await updateBlocks();
    accountStore.assetsState.setLoading(false);

    fetchBalance();
  }

  Future<void> updateBlocks() async {
    Map<int, bool> blocksNeedUpdate = Map<int, bool>();
    accountStore.assetsState.txs.forEach((i) {
      if (accountStore.assetsState.blockMap[i.block] == null) {
        blocksNeedUpdate[i.block] = true;
      }
    });
    String blocks = blocksNeedUpdate.keys.join(',');
    var data = await evalJavascript('account.getBlockTime([$blocks])');

    accountStore.assetsState.setBlockMap(data);
  }

  Future<Map<String, dynamic>> checkAccountPassword(String pass) async {
    String address = accountStore.currentAccount.address;
    return evalJavascript('account.checkPassword("$address", "$pass")');
  }
}
