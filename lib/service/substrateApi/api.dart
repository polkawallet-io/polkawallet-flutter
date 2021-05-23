import 'dart:async';
import 'dart:convert';

import 'package:encointer_wallet/config/node.dart';
import 'package:encointer_wallet/service/ipfsApi/httpApi.dart';
import 'package:encointer_wallet/service/subscan.dart';
import 'package:encointer_wallet/service/substrateApi/apiAccount.dart';
import 'package:encointer_wallet/service/substrateApi/apiAssets.dart';
import 'package:encointer_wallet/service/substrateApi/encointer/apiEncointer.dart';
import 'package:encointer_wallet/service/substrateApi/chainApi.dart';
import 'package:encointer_wallet/service/substrateApi/types/genExternalLinksParams.dart';
import 'package:encointer_wallet/store/app.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
import 'package:get_storage/get_storage.dart';

// global api instance
Api webApi;

class Api {
  Api(this.context, this.store);

  final BuildContext context;
  final AppStore store;
  var jsStorage;

  ApiAccount account;
  ApiEncointer encointer;
  ApiAssets assets;
  ChainApi chain;

  Ipfs ipfs;

  SubScanApi subScanApi = SubScanApi();

  Map<String, Function> _msgHandlers = {};
  Map<String, Completer> _msgCompleters = {};
  FlutterWebviewPlugin _web;
  StreamSubscription _subscription;

  int _evalJavascriptUID = 0;

  Function _connectFunc;

  Future<void> init() async {
    jsStorage = GetStorage();

    account = ApiAccount(this);
    encointer = ApiEncointer(this);
    assets = ApiAssets(this);
    chain = ChainApi(this);
    ipfs = Ipfs(gateway: store.settings.ipfsGateway);

    print("first launch of webview");
    await launchWebview();

    //TODO: fix this properly!
    // hack to allow hot-restart with re-loaded webview
    // the problem is that hot-restart doesn't call dispose(),
    // so the webview will not be closed properly. Therefore,
    // the first call to launchWebView will crash. The second
    // one seems to succeed
    print("second launch of webview");
    await launchWebview();
  }

  Future<void> launchWebview({bool customNode = false}) async {
    _msgHandlers = {};
    _msgCompleters = {};
    _evalJavascriptUID = 0;

    _connectFunc = customNode ? connectNode : connectNodeAll;

    final bool needLaunch = _web == null;
    if (needLaunch) {
      _web = FlutterWebviewPlugin();
    }

    if (_subscription != null) {
      //  (should only happen in hot-restart)
      _subscription.cancel();
    }
    _subscription = _web.onStateChanged.listen((viewState) async {
      if (viewState.type == WebViewState.finishLoad) {
        String network = 'encointer';
        print('webview loaded for network $network');

        DefaultAssetBundle.of(context).loadString('lib/js_service_$network/dist/main.js').then((String js) {
          print('js_service_$network loaded in webview');
          // inject js file to webview
          _web.evalJavascript(js);

          // load keyPairs from local data
          account.initAccounts();
          // connect remote node
          _connectFunc();
        });
      }
    });

    if (!needLaunch) {
      _web.reload();
      return;
    } else {
      _web.launch(
        'about:blank',
        javascriptChannels: [
          JavascriptChannel(
              name: 'PolkaWallet',
              onMessageReceived: (JavascriptMessage message) {
                print('received msg: ${message.message}');
                compute(jsonDecode, message.message).then((msg) {
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
                  }
                });
              }),
        ].toSet(),
        ignoreSSLErrors: true,
//      debuggingEnabled: true,
//        withLocalUrl: true,
//        localUrlScope: 'lib/polkadot_js_service/dist/',
        hidden: true,
      );
    }
  }

  int _getEvalJavascriptUID() {
    return _evalJavascriptUID++;
  }

  Future<dynamic> evalJavascript(
    String code, {
    bool wrapPromise = true,
    bool allowRepeat = false,
  }) async {
    // check if there's a same request loading
    if (!allowRepeat) {
      for (String i in _msgCompleters.keys) {
        String call = code.split('(')[0];
        if (i.compareTo(call) == 0) {
          print('request $call loading');
          return _msgCompleters[i].future;
        }
      }
    }

    if (!wrapPromise) {
      String res = await _web.evalJavascript(code);
      return res;
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
    String node = store.settings.endpoint.value;
    NodeConfig config = store.settings.endpoint.overrideConfig;
    // do connect
    String res = await evalJavascript('settings.connect("$node", "${jsonEncode(config)}")');
    if (res == null) {
      print('connecting to node failed');
      store.settings.setNetworkName(null);
      return;
    }

    if (store.settings.endpointIsCantillon) {
      var worker = store.settings.endpoint.worker;
      var mrenclave = store.settings.endpoint.mrenclave;
      await evalJavascript('settings.setWorkerEndpoint("$worker", "$mrenclave")');
    }

    fetchNetworkProps();
  }

  Future<void> connectNodeAll() async {
    List<String> nodes = store.settings.endpointList.map((e) => e.value).toList();
    List<NodeConfig> configs = store.settings.endpointList.map((e) => e.overrideConfig).toList();
    print("configs: $configs");
    // do connect
    String res = await evalJavascript('settings.connectAll(${jsonEncode(nodes)}, ${jsonEncode(configs)})');
    if (res == null) {
      print('connect failed');
      store.settings.setNetworkName(null);
      return;
    }

    // setWorker endpoint on js side
    if (store.settings.endpointIsCantillon) {
      var worker = store.settings.endpoint.worker;
      var mrenclave = store.settings.endpoint.mrenclave;
      await evalJavascript('settings.setWorkerEndpoint("$worker", "$mrenclave")');
    }

    int index = store.settings.endpointList.indexWhere((i) => i.value == res);
    if (index < 0) return;
    store.settings.setEndpoint(store.settings.endpointList[index]);
    fetchNetworkProps();
  }

  Future<void> fetchNetworkProps() async {
    // fetch network info
    List<dynamic> info = await Future.wait([
      evalJavascript('settings.getNetworkConst()'),
      evalJavascript('api.rpc.system.properties()'),
      evalJavascript('api.rpc.system.chain()'), // "Development" or "Encointer Testnet Gesell" or whatever
    ]);
    store.settings.setNetworkConst(info[0]);
    store.settings.setNetworkState(info[1]);
    store.settings.setNetworkName(info[2]);

    startSubscriptions();
  }

  void startSubscriptions() {
    this.encointer.startSubscriptions();
    this.chain.startSubscriptions();
    this.assets.startSubscriptions();
  }

  void stopSubscriptions() {
    this.encointer.stopSubscriptions();
    this.chain.stopSubscriptions();
    this.assets.stopSubscriptions();
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

  Future<String> subscribeBestNumber(Function callback) async {
    final String channel = _getEvalJavascriptUID().toString();
    subscribeMessage('settings.subscribeMessage("chain", "bestNumber", [], "$channel")', channel, callback);
    return channel;
  }

  Future<void> subscribeMessage(
    String code,
    String channel,
    Function callback,
  ) async {
    _msgHandlers[channel] = callback;
    evalJavascript(code, allowRepeat: true);
  }

  Future<void> unsubscribeMessage(String channel) async {
    if (_msgHandlers[channel] != null) {
      _web.evalJavascript('unsub$channel()');
    }
  }

  Future<bool> isConnected() async {
    bool connected = await evalJavascript('settings.isConnected()');
    print("Api is connected: $connected");
    return connected;
  }

  Future<void> closeWebView() async {
    print("closing webview");
    if (_web != null) {
      stopSubscriptions();
      _web.close();
      _web = null;
    } else {
      print("was null already");
    }
  }

  Future<List> getExternalLinks(GenExternalLinksParams params) async {
    final List res = await evalJavascript(
      'settings.genLinks(${jsonEncode(GenExternalLinksParams.toJson(params))})',
      allowRepeat: true,
    );
    return res;
  }
}
