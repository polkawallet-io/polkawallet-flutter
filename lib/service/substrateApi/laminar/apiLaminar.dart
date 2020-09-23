import 'dart:async';
import 'package:polka_wallet/common/consts/settings.dart';
import 'package:polka_wallet/service/substrateApi/api.dart';
import 'package:polka_wallet/store/app.dart';
import 'package:polka_wallet/store/laminar/types/laminarCurrenciesData.dart';
import 'package:polka_wallet/store/laminar/types/laminarMarginData.dart';
import 'package:polka_wallet/utils/format.dart';

class ApiLaminar {
  ApiLaminar(this.apiRoot);

  final Api apiRoot;
  final store = globalAppStore;

  final String balanceSubscribeChannel = 'LaminarAccountBalances';
  final String priceSubscribeChannel = 'LaminarPrices';
  final String syntheticPoolsSubscribeChannel = 'LaminarSyntheticPools';
  final String marginPoolsSubscribeChannel = 'LaminarMarginPools';
  final String marginTraderInfoSubscribeChannel = 'LaminarMarginTraderInfo';

  Future<void> fetchTokens(String pubKey) async {
    if (pubKey != null && pubKey.isNotEmpty) {
      String symbol = store.settings.networkState.tokenSymbol;
      String address = store.account.currentAddress;
      List<String> tokens =
          List<String>.from(store.settings.networkConst['currencyIds']);
      tokens.retainWhere((i) => i != symbol);
      String queries =
          tokens.map((i) => 'laminar.getTokens("$address", "$i")').join(",");
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

  Future<void> subscribeTokenPrices() async {
    await apiRoot.subscribeMessage(
      'laminar.subscribeMessage("currencies", "oracleValues", [], "$priceSubscribeChannel")',
      priceSubscribeChannel,
      (List res) {
        store.laminar.setTokenPrices(res);
      },
    );
  }

  Future<void> unsubscribeTokenPrices() async {
    await apiRoot.unsubscribeMessage(priceSubscribeChannel);
  }

  Future<Map> subscribeSyntheticPools() async {
    Completer<Map> c = new Completer<Map>();
    apiRoot.subscribeMessage(
      'laminar.subscribeSyntheticPools()',
      syntheticPoolsSubscribeChannel,
      (Map res) {
        store.laminar.setSyntheticPoolInfo(res);
        if (List.of(res['options']).length > 0 && !c.isCompleted) {
          c.complete(res);
        }
      },
    );
    return c.future;
  }

  Future<Map> subscribeMarginPools() async {
    Completer<Map> c = new Completer<Map>();
    apiRoot.subscribeMessage(
      'laminar.subscribeMarginPools()',
      marginPoolsSubscribeChannel,
      (Map res) {
        store.laminar.setMarginPoolInfo(res);
        if (List.of(res['options']).length > 0 && !c.isCompleted) {
          c.complete(res);
        }
      },
    );
    return c.future;
  }

  Future<Map> subscribeMarginTraderInfo() async {
    final String address = store.account.currentAddress;
    Completer<Map> c = new Completer<Map>();
    apiRoot.subscribeMessage(
      'laminar.subscribeMarginTraderInfo("$address")',
      marginTraderInfoSubscribeChannel,
      (Map res) {
        store.laminar.setMarginTraderInfo(res);
        if (!c.isCompleted) {
          c.complete(res);
        }
      },
    );
    return c.future;
  }

  BigInt _getTokenPrice(Map<String, LaminarPriceData> prices, String symbol) {
    if (symbol == acala_stable_coin) {
      return laminarIntDivisor;
    }
    final LaminarPriceData priceData = prices[symbol];
    if (priceData == null) {
      return BigInt.zero;
    }
    return Fmt.balanceInt(priceData.value ?? '0');
  }

  BigInt getPairPriceInt(
      Map<String, LaminarPriceData> prices, LaminarMarginPairData pairData) {
    final BigInt priceBase = _getTokenPrice(prices, pairData.pair.base);
    final BigInt priceQuote = _getTokenPrice(prices, pairData.pair.quote);
    BigInt priceInt = BigInt.zero;
    if (priceBase != BigInt.zero && priceQuote != BigInt.zero) {
      priceInt = priceBase * laminarIntDivisor ~/ priceQuote;
    }

    return priceInt;
  }

  BigInt getTradePriceInt({
    Map<String, LaminarPriceData> prices,
    LaminarMarginPairData pairData,
    String direction,
    BigInt priceInt,
  }) {
    final BigInt spreadAsk = Fmt.balanceInt(pairData.askSpread.toString());
    final BigInt spreadBid = Fmt.balanceInt(pairData.bidSpread.toString());
    BigInt price = priceInt ?? getPairPriceInt(prices, pairData);

    return direction == 'long' ? price + spreadAsk : price - spreadBid;
  }
}
