import 'dart:async';
import 'dart:convert';
import 'dart:ffi';
import 'package:flutter/cupertino.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
import 'package:mobx/mobx.dart';
import 'package:polka_wallet/service/polkascan.dart';
import 'package:polka_wallet/store/account.dart';
import 'package:polka_wallet/store/assets.dart';
import 'package:polka_wallet/store/settings.dart';
import 'package:polka_wallet/store/staking.dart';

class Api {
  Api(
      {@required this.context,
      @required this.accountStore,
      @required this.assetsStore,
      @required this.stakingStore,
      @required this.settingsStore});

  final BuildContext context;
  final AccountStore accountStore;
  final AssetsStore assetsStore;
  final SettingsStore settingsStore;
  final StakingStore stakingStore;

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
          // inject js file to webview
          _web.evalJavascript(js);

          // load keyPairs from local data
          initAccounts();
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
              final msg = jsonDecode(message.message);
              var handler = _msgHandlers[msg['path'] as String];
              if (handler == null) {
                return;
              }
              handler(msg['data']);
            }),
      ].toSet(),
      ignoreSSLErrors: true,
//        withLocalUrl: true,
//        localUrlScope: 'lib/polkadot_js_service/dist/',
      hidden: true,
    );
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
    List<dynamic> info = await Future.wait([
      evalJavascript('settings.getNetworkConst()'),
      evalJavascript('api.rpc.system.properties()'),
      evalJavascript('api.rpc.system.chain()'),
      fetchBalance(),
    ]);

    settingsStore.setNetworkConst(info[0]);
    settingsStore.setNetworkState(info[1]);
    settingsStore.setNetworkName(info[2]);
  }

  void initAccounts() {
    String accounts = jsonEncode(
        accountStore.accountList.map((i) => AccountData.toJson(i)).toList());
    evalJavascript('account.initKeys($accounts)');
  }

  Future<void> connectNode() async {
    String value =
        settingsStore.endpoint.value ?? 'wss://kusama-rpc.polkadot.io/';
    print(value);
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
    stakingStore.clearSate();
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
      var res = await Future.wait([
        evalJavascript('account.getBalance("$address")'),
        evalJavascript('api.derive.staking.account("$address")')
      ]);
      assetsStore.setAccountBalance(res[0]);
      stakingStore.setLedger(res[1]);
    }
  }

  Future<void> generateAccount() async {
    Map<String, dynamic> acc = await evalJavascript('account.gen()');
    accountStore.setNewAccountKey(acc['mnemonic']);
  }

  Future<Map<String, dynamic>> importAccount(
      {String keyType = 'Mnemonic', String cryptoType = 'sr25519'}) async {
    String key = accountStore.newAccount.key;
    String pass = accountStore.newAccount.password;
    String code =
        'account.recover("$keyType", "$cryptoType", \'$key\', "$pass")';
    print(code);
    Map<String, dynamic> acc = await evalJavascript(code);
    if (acc != null) {
      acc['name'] = accountStore.newAccount.name;
      await accountStore.addAccount(acc);
      fetchBalance();
    }
    return acc;
  }

  Future<List> updateTxs(int page) async {
    if (page == 1) {
      assetsStore.clearTxs();
    }
    assetsStore.setLoading(true);
    String data =
        await PolkaScanApi.fetchTxs(accountStore.currentAccount.address, page);
    List ls = jsonDecode(data)['data'];

    await assetsStore.addTxs(ls);

    await updateBlocks();
    assetsStore.setLoading(false);
    return ls;
  }

  Future<List> updateStaking(int page) async {
    if (page == 1) {
      stakingStore.clearTxs();
    }
    String data = await PolkaScanApi.fetchStaking(
        accountStore.currentAccount.address, page);
//    String data = await PolkaScanApi.fetchStaking(
//        'E4ukkmqUZv1noW1sq7uqEB2UVfzFjMEM73cVSp8roRtx14n', page);
    var ls = jsonDecode(data)['data'];
    var detailReqs = List<Future<dynamic>>();
    ls.forEach((i) => detailReqs
        .add(PolkaScanApi.fetchTx(i['attributes']['extrinsic_hash'])));
    var details = await Future.wait(detailReqs);
    var index = 0;
    ls.forEach((i) {
      i['detail'] = jsonDecode(details[index])['data']['attributes'];
      index++;
    });
    await stakingStore.addTxs(List<Map<String, dynamic>>.from(ls));

    Map<int, bool> blocksNeedUpdate = Map<int, bool>();
    ls.forEach((i) {
      int block = i['attributes']['block_id'];
      if (assetsStore.blockMap[block] == null) {
        blocksNeedUpdate[block] = true;
      }
    });
    String blocks = blocksNeedUpdate.keys.join(',');
    var blockData = await evalJavascript('account.getBlockTime([$blocks])');

    assetsStore.setBlockMap(blockData);
    return ls;
  }

  Future<void> updateBlocks() async {
    Map<int, bool> blocksNeedUpdate = Map<int, bool>();
    assetsStore.txs.forEach((i) {
      if (assetsStore.blockMap[i.block] == null) {
        blocksNeedUpdate[i.block] = true;
      }
    });
    String blocks = blocksNeedUpdate.keys.join(',');
    var data = await evalJavascript('account.getBlockTime([$blocks])');

    assetsStore.setBlockMap(data);
  }

  Future<dynamic> checkAccountPassword(String pass) async {
    String address = accountStore.currentAccount.address;
//    String address = 'HmyonjFVFZyg1mRjRvohVGRw9ouFDRoQ5ea9nDfH2Yi44qQ';
    print('checkpass: $address, $pass');
    return evalJavascript('account.checkPassword("$address", "$pass")');
  }

  Future<Map> queryValidatorRewards(String accountId) async {
    int timestamp = DateTime.now().second;
    Map cached = stakingStore.chartDataCache[accountId];
    if (cached != null && cached['timestamp'] > timestamp - 600) {
      return cached;
    }
    print('fetching chart data');
    Map data = await evalJavascript(
        'staking.loadValidatorRewardsData(api, "$accountId")');
    if (data != null && List.of(data['rewardsLabels']).length > 0) {
      stakingStore.setChartData(accountId, data);
    }
    return data;
  }
}
