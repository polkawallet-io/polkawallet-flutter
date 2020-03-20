import 'dart:convert';

import 'package:polka_wallet/store/app.dart';
import 'package:polka_wallet/service/polkascan.dart';
import 'package:polka_wallet/service/substrateApi/api.dart';

class ApiAssets {
  ApiAssets(this.apiRoot);

  final Api apiRoot;
  final store = globalAppStore;

  Future<void> fetchBalance(String address) async {
    if (address != null && address.isNotEmpty) {
      String res =
          await apiRoot.evalJavascript('account.getBalance("$address")');
      store.assets.setAccountBalance(address, res);
    }
  }

  Future<List> updateTxs(int page) async {
    String address = store.account.currentAddress;
    String data = await PolkaScanApi.fetchTxs(address, page);
    List ls = jsonDecode(data)['data'];

    if (page == 1) {
      store.assets.clearTxs();
      store.assets.setTxsLoading(true);
    }
    // cache first page of txs
    await store.assets.addTxs(ls, address, shouldCache: page == 1);

    await apiRoot.updateBlocks(ls);
    store.assets.setTxsLoading(false);
    return ls;
  }
}
