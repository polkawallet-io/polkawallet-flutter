import 'dart:convert';

import 'package:polka_wallet/store/app.dart';
import 'package:polka_wallet/service/polkascan.dart';
import 'package:polka_wallet/service/substrateApi/api.dart';

class ApiAssets {
  ApiAssets(this.apiRoot);

  final Api apiRoot;
  final store = globalAppStore;

  Future<void> fetchBalance(String pubKey) async {
    if (pubKey != null && pubKey.isNotEmpty) {
      String address = store.account.pubKeyAddressMap[pubKey];
      String res =
          await apiRoot.evalJavascript('account.getBalance("$address")');
      store.assets.setAccountBalance(pubKey, res);
    }
  }

  Future<List> updateTxs(int page) async {
    String address = store.account.currentAddress;
    List<String> data = await Future.wait([
      PolkaScanApi.fetchTransfers(address, page),
      PolkaScanApi.fetchTxs(address,
          page: page, module: PolkaScanApi.module_balances),
    ]);
    List transfers = jsonDecode(data[0])['data'];
    List txs = jsonDecode(data[1])['data'];
    transfers.asMap().forEach((k, v) {
      v['hash'] = txs[k]['attributes']['extrinsic_hash'];
    });

    if (page == 1) {
      store.assets.clearTxs();
      store.assets.setTxsLoading(true);
    }
    // cache first page of txs
    await store.assets.addTxs(transfers, address, shouldCache: page == 1);

    await apiRoot.updateBlocks(transfers);
    store.assets.setTxsLoading(false);
    return transfers;
  }
}
