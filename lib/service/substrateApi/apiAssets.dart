import 'package:encointer_wallet/service/substrateApi/api.dart';
import 'package:encointer_wallet/store/app.dart';

class ApiAssets {
  ApiAssets(this.apiRoot);

  final Api apiRoot;
  final store = globalAppStore;

  Future<void> fetchBalance() async {
    String pubKey = store.account.currentAccountPubKey;
    if (pubKey != null && pubKey.isNotEmpty) {
      String address = store.account.currentAddress;
      Map res = await apiRoot.evalJavascript(
        'account.getBalance("$address")',
        allowRepeat: true,
      );
      store.assets.setAccountBalances(pubKey, Map.of({store.settings.networkState.tokenSymbol: res}));
    }
    if (store.settings.endpointIsEncointer) {
      apiRoot.encointer.getBalances();
    }
    _fetchMarketPrice();
  }

  Future<Map> updateTxs(int page) async {
    store.assets.setTxsLoading(true);

    String address = store.account.currentAddress;
    Map res = await apiRoot.subScanApi.fetchTransfersAsync(
      address,
      page,
      network: store.settings.endpoint.info,
    );

    if (page == 0) {
      store.assets.clearTxs();
    }
    // cache first page of txs
    await store.assets.addTxs(res, address, shouldCache: page == 0);

    store.assets.setTxsLoading(false);
    return res;
  }

  Future<void> _fetchMarketPrice() async {
    print("Fetch marketprice not implemented for Encointer networks");
  }
}
