import 'dart:convert';

import 'package:polka_wallet/common/consts/settings.dart';
import 'package:polka_wallet/store/app.dart';
import 'package:polka_wallet/service/polkascan.dart';
import 'package:polka_wallet/service/substrateApi/api.dart';

class ApiAssets {
  ApiAssets(this.apiRoot);

  final Api apiRoot;
  final store = globalAppStore;

  Future<void> fetchBalance(String pubKey) async {
    if (pubKey != null && pubKey.isNotEmpty) {
      String address = store.account.currentAddress;
      String res =
          await apiRoot.evalJavascript('account.getBalance("$address")');
      store.assets.setAccountBalances(
          pubKey, Map.of({store.settings.networkState.tokenSymbol: res}));
    }
    if (store.settings.endpoint.info == networkEndpointAcala.info) {
      apiRoot.acala.fetchTokens(store.account.currentAccount.pubKey);
      apiRoot.acala.fetchAirdropTokens();
    }
  }

  Future<Map> updateTxs(int page) async {
    String address = store.account.currentAddress;
    Map res = await PolkaScanApi.fetchTransfers(address, page);

    if (page == 0) {
      store.assets.clearTxs();
      store.assets.setTxsLoading(true);
    }
    // cache first page of txs
    await store.assets.addTxs(res, address, shouldCache: page == 0);

    store.assets.setTxsLoading(false);
    return res;
  }
}
