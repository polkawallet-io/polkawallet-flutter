import 'dart:convert';

import 'package:polka_wallet/store/app.dart';
import 'package:polka_wallet/service/polkascan.dart';
import 'package:polka_wallet/service/substrateApi/api.dart';

class ApiAssets {
  ApiAssets(this.apiRoot);

  final Api apiRoot;
  final store = globalAppStore;

  Future<String> fetchBalance(String address) async {
    String res = '0';
    if (address != null && address.length > 0) {
      res = await apiRoot.evalJavascript('account.getBalance("$address")');
      store.assets.setAccountBalance(res);
    }
    return res;
  }

  Future<List> updateTxs(int page) async {
    String data =
        await PolkaScanApi.fetchTxs(store.account.currentAddress, page);
    List ls = jsonDecode(data)['data'];

    if (page == 1) {
      store.assets.clearTxs();
      store.assets.setTxsLoading(true);
    }
    await store.assets.addTxs(ls);

    await apiRoot.updateBlocks(ls);
    store.assets.setTxsLoading(false);
    return ls;
  }
}
