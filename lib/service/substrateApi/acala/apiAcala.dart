import 'dart:convert';
import 'dart:io';

import 'package:device_info/device_info.dart';
import 'package:polka_wallet/common/consts/settings.dart';
import 'package:polka_wallet/service/faucet.dart';
import 'package:polka_wallet/store/app.dart';
import 'package:polka_wallet/service/substrateApi/api.dart';
import 'package:polka_wallet/utils/format.dart';

class ApiAcala {
  ApiAcala(this.apiRoot);

  final Api apiRoot;
  final store = globalAppStore;

  final String tokenPricesSubscribeChannel = 'TokenPrices';

  Future<String> fetchFaucet() async {
    String address = store.account.currentAddress;
    String deviceId = address;
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    if (Platform.isAndroid) {
      AndroidDeviceInfo info = await deviceInfo.androidInfo;
      deviceId = info.androidId;
    } else {
      IosDeviceInfo info = await deviceInfo.iosInfo;
      deviceId = info.identifierForVendor;
    }
    String res = await FaucetApi.getAcalaTokens(address, deviceId);
    return res;
  }

  Future<void> fetchTokens(String pubKey) async {
    if (pubKey != null && pubKey.isNotEmpty) {
      String symbol = store.settings.networkState.tokenSymbol;
      String address = store.account.currentAddress;
      List<String> tokens =
          List<String>.from(store.settings.networkConst['currencyIds']);
      tokens.retainWhere((i) => i != symbol);
      String queries =
          tokens.map((i) => 'acala.getTokens("$address", "$i")').join(",");
      var res = await apiRoot.evalJavascript('Promise.all([$queries])',
          allowRepeat: true);
      Map balances = {};
      balances[symbol] = store.assets.balances[symbol].transferable.toString();
      tokens.asMap().forEach((index, token) {
        balances[token] = res[index].toString();
      });
      store.assets.setAccountTokenBalances(pubKey, balances);
    }
  }

  Future<void> fetchAirdropTokens() async {
    String getCurrencyIds =
        'api.registry.createType("AirDropCurrencyId").defKeys';
    if (Platform.isIOS) {
      getCurrencyIds =
          'JSON.stringify(api.registry.createType("AirDropCurrencyId").defKeys)';
    }
    String res =
        await apiRoot.evalJavascript(getCurrencyIds, wrapPromise: false);
    if (res == null) return;

    final List tokens = jsonDecode(res);
    String address = store.account.currentAddress;
    String queries = tokens
        .map((i) => 'api.query.airDrop.airDrops("$address", "$i")')
        .join(",");
    final List amount = await apiRoot.evalJavascript('Promise.all([$queries])',
        allowRepeat: true);
    final Map amt = {
      'tokens': tokens,
      'amount': amount,
    };
    store.acala.setAirdrops(amt);
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
    final decimals = store.settings.networkState.tokenDecimals;
    final res = await apiRoot.evalJavascript(
      'acala.fetchLDOTPrice(api)',
      allowRepeat: true,
    );
    return {
      "token": 'LDOT',
      "price": {"value": Fmt.tokenInt(res.toString(), decimals).toString()}
    };
  }

  Future<void> subscribeTokenPrices() async {
    final String code =
        'settings.subscribeMessage("price", "allPrices", [], "$tokenPricesSubscribeChannel")';
    await apiRoot.subscribeMessage(code, tokenPricesSubscribeChannel,
        (List res) async {
      var priceOfLDOT = await _fetchPriceOfLDOT();
      res.add(priceOfLDOT);
      store.acala.setPrices(res);
    });
  }

  Future<void> unsubscribeTokenPrices() async {
    await apiRoot.unsubscribeMessage(tokenPricesSubscribeChannel);
  }

  Future<String> fetchTokenSwapAmount(String supplyAmount, String targetAmount,
      List<String> swapPair, String slippage) async {
    /// baseCoin = 0, supplyToken == AUSD
    /// baseCoin = 1, targetToken == AUSD
    /// baseCoin = -1, no AUSD
    int baseCoin =
        swapPair.indexWhere((i) => i.toUpperCase() == acala_stable_coin);
    String output = await apiRoot.evalJavascript(
      'acala.calcTokenSwapAmount(api, $supplyAmount, $targetAmount, ${jsonEncode(swapPair)}, $baseCoin, $slippage)',
      allowRepeat: true,
    );
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
      'acala.fetchDexPoolInfo("$currencyId", "${store.account.currentAddress}")',
      allowRepeat: true,
    );
    store.acala.setDexPoolInfo(currencyId, info);
  }

  Future<void> fetchHomaStakingPool() async {
    Map res = await apiRoot.evalJavascript('acala.fetchHomaStakingPool(api)');
    store.acala.setHomaStakingPool(res);
  }

  Future<void> fetchHomaUserInfo() async {
    String address = store.account.currentAddress;
    Map res = await apiRoot
        .evalJavascript('acala.fetchHomaUserInfo(api, "$address")');
    store.acala.setHomaUserInfo(res);
  }
}
