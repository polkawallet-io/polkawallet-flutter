import 'dart:convert';
import 'dart:io';

import 'package:device_info/device_info.dart';
import 'package:polka_wallet/service/faucet.dart';
import 'package:polka_wallet/store/acala/types/swapOutputData.dart';
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
    String res = await FaucetApi.getAcalaTokensV2(address, deviceId);
    return res;
  }

  Future<void> fetchTokens(String pubKey) async {
    if (pubKey != null && pubKey.isNotEmpty) {
      final symbol = store.settings.networkState.tokenSymbol;
      final address = store.account.currentAddress;
      final List tokens =
          store.settings.networkConst['accounts']['allNonNativeCurrencyIds'];
      final String queries = tokens
          .map((i) => 'acala.getTokens("$address", ${jsonEncode(i)})')
          .join(",");
      var res = await Future.wait([
        apiRoot.evalJavascript('Promise.all([$queries])', allowRepeat: true),
        apiRoot.evalJavascript('acala.queryLPTokens("$address")',
            allowRepeat: true),
      ]);
      Map balances = {};
      balances[symbol] = store.assets.balances[symbol].transferable.toString();
      tokens.asMap().forEach((index, token) {
        balances[token['Token']] = res[0][index].toString();
      });
      store.assets.setAccountTokenBalances(pubKey, balances);
      store.acala.setLPTokens(res[1]);
    }
  }

  Future<void> fetchAirdropTokens() async {
    String getCurrencyIds = 'api.createType("AirDropCurrencyId").defKeys';
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

  Future<SwapOutputData> fetchTokenSwapAmount(
    String supplyAmount,
    String targetAmount,
    List<String> swapPair,
    String slippage,
  ) async {
    final code =
        'acala.calcTokenSwapAmount(api, $supplyAmount, $targetAmount, ${jsonEncode(swapPair)}, $slippage)';
    final output = await apiRoot.evalJavascript(code, allowRepeat: true);
    return SwapOutputData.fromJson(output);
  }

  Future<void> fetchDexPools() async {
    final res = await apiRoot.evalJavascript('acala.getTokenPairs()');
    store.acala.setDexPools(res);
  }

  Future<void> fetchDexLiquidityPoolSwapRatio(String currencyId) async {
    // String res = await fetchTokenSwapAmount(
    //     '1', null, [currencyId, acala_stable_coin], '0');
    // store.acala.setSwapPoolRatio(currencyId, res);
  }

  Future<void> fetchDexLiquidityPoolRewards() async {
    await webApi.acala.fetchDexPools();
    final pools = store.acala.dexPools
        .map((pool) =>
            jsonEncode({'DEXShare': pool.map((e) => e.name).toList()}))
        .toList();
    final incentiveQuery = pools
        .map((i) => 'api.query.incentives.dEXIncentiveRewards($i)')
        .join(',');
    print(pools);
    final savingRateQuery =
        pools.map((i) => 'api.query.incentives.dEXSavingRates($i)').join(',');
    print(incentiveQuery);
    print(savingRateQuery);
    final incentivesData =
        await apiRoot.evalJavascript('Promise.all([$incentiveQuery])');
    final savingRatesData =
        await apiRoot.evalJavascript('Promise.all([$savingRateQuery])');
    final incentives = Map<String, dynamic>();
    final savingRates = Map<String, dynamic>();
    final tokenPairs = store.acala.dexPools
        .map((e) => e.map((i) => i.symbol).join('-'))
        .toList();
    print(tokenPairs);
    tokenPairs.asMap().forEach((k, v) {
      incentives[v] = incentivesData[k];
      savingRates[v] = savingRatesData[k];
    });
    store.acala.setSwapPoolRewards(incentives);
    store.acala.setSwapSavingRates(savingRates);
  }

  Future<void> fetchDexPoolInfo(String pool) async {
    Map info = await apiRoot.evalJavascript(
      'acala.fetchDexPoolInfo(${jsonEncode({
        'DEXShare': pool.split('-').map((e) => e.toUpperCase()).toList()
      })}, "${store.account.currentAddress}")',
      allowRepeat: true,
    );
    store.acala.setDexPoolInfo(pool, info);
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
