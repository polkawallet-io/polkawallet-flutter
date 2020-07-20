import 'package:polka_wallet/service/substrateApi/api.dart';
import 'package:polka_wallet/store/app.dart';

class ApiLaminar {
  ApiLaminar(this.apiRoot);

  final Api apiRoot;
  final store = globalAppStore;

  final String balanceSubscribeChannel = 'LaminarAccountBalances';

  Future<void> getTokenList() async {
    final List res =
        await apiRoot.evalJavascript('api.currencies.tokens().toPromise()');
    print(res);
    store.laminar.setTokenList(res);
  }

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

  Future<void> subscribeAccountBalance() async {
    final String address = store.account.currentAddress;
    final String code =
        'laminar.subscribeMessage("currencies", "balances", ["$address"], "$balanceSubscribeChannel")';
    await apiRoot.subscribeMessage(code, balanceSubscribeChannel,
        (List res) async {
      store.laminar.setAccountBalance(res);
    });
  }

  Future<void> unsubscribeAccountBalance() async {
    await apiRoot.unsubscribeMessage(balanceSubscribeChannel);
  }
}
