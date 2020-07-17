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
