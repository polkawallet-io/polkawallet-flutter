import 'dart:async';
import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
import 'package:polka_wallet/service/substrateApi/apiAccount.dart';
import 'package:polka_wallet/service/substrateApi/apiAssets.dart';
import 'package:polka_wallet/service/substrateApi/apiGov.dart';
import 'package:polka_wallet/service/substrateApi/apiStaking.dart';
import 'package:polka_wallet/store/app.dart';

// global api instance
Api webApi;

class Api {
  Api(this.context, this.store);

  final BuildContext context;
  final AppStore store;

  ApiAccount account;
  ApiAssets assets;
  ApiStaking staking;
  ApiGovernance gov;

  Map<String, Function> _msgHandlers = {};
  Map<String, Completer> _msgCompleters = {};
  FlutterWebviewPlugin _web;
  int _evalJavascriptUID = 0;

  void init() {
    account = ApiAccount(this);
    assets = ApiAssets(this);
    staking = ApiStaking(this);
    gov = ApiGovernance(this);

    _msgHandlers['txStatusChange'] = store.account.setTxStatus;

    _web = FlutterWebviewPlugin();

    _web.onStateChanged.listen((viewState) async {
      if (viewState.type == WebViewState.finishLoad) {
        print('webview loaded');
        DefaultAssetBundle.of(context)
            .loadString('lib/polkadot_js_service/dist/main.js')
            .then((String js) {
          print('js file loaded');
          // inject js file to webview
          _web.evalJavascript(js);

          // load keyPairs from local data
          account.initAccounts();
          // connect remote node
          connectNode();
        });
      }
    });

    _web.launch(
      'about:blank',
      javascriptChannels: [
        JavascriptChannel(
            name: 'PolkaWallet',
            onMessageReceived: (JavascriptMessage message) {
              print('received msg: ${message.message}');
              compute(jsonDecode, message.message).then((msg) {
                final msg = jsonDecode(message.message);
                final String path = msg['path'];
                if (_msgCompleters[path] != null) {
                  Completer handler = _msgCompleters[path];
                  handler.complete(msg['data']);
                  if (path.contains('uid=')) {
                    _msgCompleters.remove(path);
                  }
                }
                if (_msgHandlers[path] != null) {
                  Function handler = _msgHandlers[path];
                  handler(msg['data']);
                  if (path.contains('uid=')) {
                    _msgHandlers.remove(path);
                  }
                }
              });
            }),
      ].toSet(),
      ignoreSSLErrors: true,
//        withLocalUrl: true,
//        localUrlScope: 'lib/polkadot_js_service/dist/',
      hidden: true,
    );
  }

  int _getEvalJavascriptUID() {
    return _evalJavascriptUID++;
  }

  Future<dynamic> evalJavascript(String code) async {
    // check if there's a same request loading
    for (String i in _msgCompleters.keys) {
      String call = code.split('(')[0];
      if (i.contains(call)) {
        print('request $call loading');
        return _msgCompleters[i].future;
      }
    }

    Completer c = new Completer();

    String method = 'uid=${_getEvalJavascriptUID()};${code.split('(')[0]}';
    _msgCompleters[method] = c;

    String script = '$code.then(function(res) {'
        '  PolkaWallet.postMessage(JSON.stringify({ path: "$method", data: res }));'
        '}).catch(function(err) {'
        '  PolkaWallet.postMessage(JSON.stringify({ path: "log", data: err.message }));'
        '})';
    _web.evalJavascript(script);

    return c.future;
  }

  Future<void> connectNode() async {
    String endpoint = store.settings.endpoint.value;
    print(endpoint);
    // do connect
    String res = await evalJavascript('settings.connect("$endpoint")');
    if (res == null) {
      print('connect failed');
      store.settings.setNetworkName(null);
      return;
    }
    fetchNetworkProps();
  }

  Future<void> changeNode(String endpoint) async {
    store.settings.setNetworkLoading(true);
    store.staking.clearState();
    store.gov.clearSate();
    String res = await evalJavascript('settings.changeEndpoint("$endpoint")');
    if (res == null) {
      print('connect failed');
      store.settings.setNetworkName(null);
      return;
    }
    fetchNetworkProps();
  }

  Future<void> fetchNetworkProps() async {
    // fetch network info
    List<dynamic> info = await Future.wait([
      evalJavascript('settings.getNetworkConst()'),
      evalJavascript('api.rpc.system.properties()'),
      evalJavascript('api.rpc.system.chain()'),
    ]);
    store.settings.setNetworkConst(info[0]);
    store.settings.setNetworkState(info[1]);
    store.settings.setNetworkName(info[2]);

    // fetch account balance
    if (store.account.accountList.length > 0) {
      // reset account address format
      if (store.settings.customSS58Format['info'] == 'default') {
        account.setSS58Format(info[1]['ss58Format'] ?? 42);
      }

      // fetch account balance
      await Future.wait([
        assets.fetchBalance(store.account.currentAccount.pubKey),
        staking.fetchAccountStaking(store.account.currentAccount.pubKey),
        account.fetchAccountsBonded(
            store.account.accountList.map((i) => i.pubKey).toList()),
      ]);
    }

    // fetch staking overview data as initializing
    staking.fetchStakingOverview();
  }

  Future<void> updateBlocks(List txs) async {
    Map<int, bool> blocksNeedUpdate = Map<int, bool>();
    txs.forEach((i) {
      int block = i['attributes']['block_id'];
      if (store.assets.blockMap[block] == null) {
        blocksNeedUpdate[block] = true;
      }
    });
    String blocks = blocksNeedUpdate.keys.join(',');
    var data = await evalJavascript('account.getBlockTime([$blocks])');

    store.assets.setBlockMap(data);
  }

  Future<void> subscribeBestNumber() async {
    _msgHandlers['bestNumber'] = (data) {
      store.gov.setBestNumber(data as int);
    };
    evalJavascript('gov.subBestNumber()');
  }

  Future<void> unsubscribeBestNumber() async {
    _web.evalJavascript('unsubBestNumber()');
  }
}
