import 'dart:convert';

import 'package:polka_wallet/store/app.dart';
import 'package:polka_wallet/service/polkascan.dart';
import 'package:polka_wallet/service/substrateApi/api.dart';

class ApiAcala {
  ApiAcala(this.apiRoot);

  final Api apiRoot;
  final store = globalAppStore;

  Future<void> fetchTokens(String pubKey) async {
    if (pubKey != null && pubKey.isNotEmpty) {
      String address = store.account.currentAddress;
      List<String> tokens =
          List<String>.from(store.settings.networkConst['currencyIds']);
      tokens.retainWhere((i) => i != store.settings.networkState.tokenSymbol);
      String queries =
          tokens.map((i) => 'acala.getTokens("$i", "$address")').join(",");
      var res = await apiRoot.evalJavascript('Promise.all([$queries])');
      Map balances = {};
      tokens.asMap().forEach((index, token) {
        balances[token] = res[index].toString();
      });
      store.assets.setAccountBalances(pubKey, balances);
    }
  }

  Future<List> updateTxs(int page) async {
    String address = store.account.currentAddress;
    String data = await PolkaScanApi.fetchTransfers(address, page,
        network: store.settings.endpoint.info);
    List txs = jsonDecode(data)['data'];

    if (page == 1) {
      store.acala.setTxsLoading(true);
    }
    // cache first page of txs
//    store.acala.setLoanTxs(txs, reset: page == 1);

//    await apiRoot.updateBlocks(txs);
    store.acala.setTxsLoading(false);
    return txs;
  }

  Future<void> fetchAccountLoans() async {
    String address = store.account.currentAddress;
    List res =
        await apiRoot.evalJavascript('api.derive.loan.allLoans("$address")');
    store.acala.setAccountLoans(res);
  }

  Future<void> fetchLoanTypes() async {
    List res = await apiRoot.evalJavascript('api.derive.loan.allLoanTypes()');
    store.acala.setLoanTypes(res);
  }

  Future<void> subscribeTokenPrices() async {
    await apiRoot.subscribeMessage('price', 'allPrices', [], 'TokenPrices',
        (List res) {
      store.acala.setPrices(res);
    });
  }

  Future<void> unsubscribeTokenPrices() async {
    await apiRoot.unsubscribeMessage('TokenPrices');
  }

  Future<String> fetchTokenSwapRatio() async {
    String ratio = await fetchTokenSwapAmount('1', null, '0');
    store.acala.setSwapRatio(ratio);
    return ratio;
  }

  Future<String> fetchTokenSwapAmount(
      String supply, String target, String slippage) async {
    List<String> swapPair = store.acala.currentSwapPair;

    /// baseCoin = 0, supplyToken == AUSD
    /// baseCoin = 1, targetToken == AUSD
    /// baseCoin = -1, no AUSD
    int baseCoin = swapPair.indexOf(store.acala.acalaSwapBaseCoin);
    String output = await apiRoot.evalJavascript(
        'acala.calcTokenSwapAmount(api, $supply, $target, ${jsonEncode(swapPair)}, $baseCoin, $slippage)');
    return output;
  }
}
