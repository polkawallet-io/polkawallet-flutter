import 'dart:convert';

import 'package:polka_wallet/store/app.dart';
import 'package:polka_wallet/service/polkascan.dart';
import 'package:polka_wallet/service/substrateApi/api.dart';

class ApiAssets {
  ApiAssets(this.apiRoot);

  final Api apiRoot;
  final store = globalAppStore;

  Future<void> fetchBalance(String address) async {
    if (address != null) {
      var res = await apiRoot.evalJavascript('account.getBalance("$address")');
      store.assets.setAccountBalance(res);
    }
  }

  Future<List> updateTxs(int page) async {
    if (page == 1) {
      store.assets.clearTxs();
      store.assets.setTxsLoading(true);
    }
    String data =
        await PolkaScanApi.fetchTxs(store.account.currentAddress, page);
    List ls = jsonDecode(data)['data'];

    await store.assets.addTxs(ls);

    await apiRoot.updateBlocks();
    store.assets.setTxsLoading(false);
    return ls;
  }
}
