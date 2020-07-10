import 'package:polka_wallet/common/consts/settings.dart';
import 'package:polka_wallet/service/subscan.dart';
import 'package:polka_wallet/store/app.dart';
import 'package:polka_wallet/service/substrateApi/api.dart';

class ApiAssets {
  ApiAssets(this.apiRoot);

  final Api apiRoot;
  final store = globalAppStore;

  Future<void> fetchBalance(String pubKey) async {
    if (pubKey != null && pubKey.isNotEmpty) {
      String address = store.account.currentAddress;
      Map res = await apiRoot.evalJavascript('account.getBalance("$address")');
      store.assets.setAccountBalances(
          pubKey, Map.of({store.settings.networkState.tokenSymbol: res}));
    }
    if (store.settings.endpoint.info == networkEndpointEncointerGesell.info ||
        store.settings.endpoint.info == networkEndpointEncointerGesellDev.info ||
        store.settings.endpoint.info == networkEndpointEncointerCantillon.info) {
      apiRoot.encointer.getBalances();
    }
  }

  Future<Map> updateTxs(int page) async {
    store.assets.setTxsLoading(true);

    String address = store.account.currentAddress;
    Map res = await SubScanApi.fetchTransfers(address, page);

    if (page == 0) {
      store.assets.clearTxs();
    }
    // cache first page of txs
    await store.assets.addTxs(res, address, shouldCache: page == 0);

    store.assets.setTxsLoading(false);
    return res;
  }
}
