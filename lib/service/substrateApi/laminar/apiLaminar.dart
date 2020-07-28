import 'dart:async';

import 'package:polka_wallet/service/substrateApi/api.dart';
import 'package:polka_wallet/store/app.dart';

class ApiLaminar {
  ApiLaminar(this.apiRoot);

  final Api apiRoot;
  final store = globalAppStore;

  final String balanceSubscribeChannel = 'LaminarAccountBalances';
  final String priceSubscribeChannel = 'LaminarPrices';
  final String syntheticPoolsSubscribeChannel = 'LaminarSyntheticPools';

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
      'laminar.subscribePrices()',
      priceSubscribeChannel,
      (Map res) {
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
        if (!c.isCompleted) {
          c.complete(res);
        }
      },
    );
    return c.future;
  }
}
