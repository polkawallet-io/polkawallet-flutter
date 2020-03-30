import 'dart:convert';

import 'package:polka_wallet/store/app.dart';
import 'package:polka_wallet/service/polkascan.dart';
import 'package:polka_wallet/service/substrateApi/api.dart';

class ApiAcalaAssets {
  ApiAcalaAssets(this.apiRoot);

  final Api apiRoot;
  final store = globalAppStore;

  Future<void> fetchTokens(String pubKey) async {
    if (pubKey != null && pubKey.isNotEmpty) {
      String address = store.account.currentAddress;
      List<String> tokens =
          List<String>.from(store.settings.networkConst['currencyIds']);
      tokens.retainWhere((i) => i != store.settings.networkState.tokenSymbol);
      String queries = tokens
          .map((i) => 'api.query.tokens.balance("$i", "$address")')
          .join(",");
      var res = await apiRoot.evalJavascript('Promise.all([$queries])');
      Map balances = {};
      tokens.asMap().forEach((index, token) {
        balances[token] = res[index].toString();
      });
      store.assets.setAccountBalances(pubKey, balances);
    }
  }

  Future<List> updateTxs(int page) async {
    String address = store.account.currentAddress;
    String data = await PolkaScanApi.fetchTransfers(address, page,
        network: store.settings.endpoint.info);
    List transfers = jsonDecode(data)['data'];

    if (page == 1) {
      store.assets.clearTxs();
      store.assets.setTxsLoading(true);
    }
    // cache first page of txs
    await store.assets.addTxs(transfers, address);

    await apiRoot.updateBlocks(transfers);
    store.assets.setTxsLoading(false);
    return transfers;
  }
}
