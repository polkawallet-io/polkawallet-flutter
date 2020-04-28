import 'dart:convert';

import 'package:polka_wallet/common/consts/settings.dart';
import 'package:polka_wallet/service/faucet.dart';
import 'package:polka_wallet/store/app.dart';
import 'package:polka_wallet/service/polkascan.dart';
import 'package:polka_wallet/service/substrateApi/api.dart';
import 'package:polka_wallet/utils/format.dart';

class ApiAcala {
  ApiAcala(this.apiRoot);

  final Api apiRoot;
  final store = globalAppStore;

  Future<String> fetchFaucet() async {
    String res = await AcalaFaucetApi.getTokens(store.account.currentAddress);
    return res;
  }

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

  Future<void> fetchAirdropTokens() async {
    String address = store.account.currentAddress;
    String res = await apiRoot.evalJavascript(
        'api.registry.createType("AirDropCurrencyId").defKeys',
        wrapPromise: false);
    if (res == null) return;
    List tokens = jsonDecode(res);
    String queries = tokens
        .map((i) => 'api.query.airDrop.airDrops("$address", "$i")')
        .join(",");
    List amount = await apiRoot.evalJavascript('Promise.all([$queries])');
    Map<String, BigInt> amt = Map<String, BigInt>();
    tokens.asMap().forEach((i, v) {
      amt[v] = BigInt.parse(amount[i].toString());
    });
    print(amt);
    store.acala.setAirdrops(amt);
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

  Future<Map> _fetchPriceOfLDOT() async {
    var res = await apiRoot.evalJavascript('acala.fetchLDOTPrice(api)');
    return {
      "token": 'LDOT',
      "price": {
        "value": Fmt.tokenInt(res.toString(), decimals: acala_token_decimals)
            .toString()
      }
    };
  }

  Future<void> subscribeTokenPrices() async {
    await apiRoot.subscribeMessage('price', 'allPrices', [], 'TokenPrices',
        (List res) async {
      var priceOfLDOT = await _fetchPriceOfLDOT();
      res.add(priceOfLDOT);
      store.acala.setPrices(res);
    });
  }

  Future<void> unsubscribeTokenPrices() async {
    await apiRoot.unsubscribeMessage('TokenPrices');
  }

  Future<String> fetchTokenSwapRatio() async {
    List<String> swapPair = store.acala.currentSwapPair;
    String ratio = await fetchTokenSwapAmount('1', null, swapPair, '0');
    store.acala.setSwapRatio(ratio);
    return ratio;
  }

  Future<String> fetchTokenSwapAmount(String supplyAmount, String targetAmount,
      List<String> swapPair, String slippage) async {
    /// baseCoin = 0, supplyToken == AUSD
    /// baseCoin = 1, targetToken == AUSD
    /// baseCoin = -1, no AUSD
    int baseCoin =
        swapPair.indexWhere((i) => i.toUpperCase() == acala_stable_coin);
    String output = await apiRoot.evalJavascript(
        'acala.calcTokenSwapAmount(api, $supplyAmount, $targetAmount, ${jsonEncode(swapPair)}, $baseCoin, $slippage)');
    return output;
  }

  Future<void> fetchDexLiquidityPoolSwapRatio(String currencyId) async {
    String res = await fetchTokenSwapAmount(
        '1', null, [currencyId, acala_stable_coin], '0');
    store.acala.setSwapPoolRatio(currencyId, res);
  }

  Future<void> fetchDexLiquidityPoolRewards() async {
    List<String> tokens = store.acala.swapTokens;
    String code = tokens
        .map((i) => 'api.query.dex.liquidityIncentiveRate("$i")')
        .join(',');
    List list = await apiRoot.evalJavascript('Promise.all([$code])');
    Map<String, dynamic> rewards = Map<String, dynamic>();
    tokens.asMap().forEach((k, v) {
      rewards[v] = list[k];
    });
    store.acala.setSwapPoolRewards(rewards);
  }

  Future<void> fetchDexPoolInfo(String currencyId) async {
    Map info = await apiRoot.evalJavascript(
        'acala.fetchDexPoolInfo("$currencyId", "${store.account.currentAddress}")');
    store.acala.setDexPoolInfo(currencyId, info);
  }
}
