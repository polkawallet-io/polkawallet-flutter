import 'dart:convert';

import 'package:polka_wallet/store/app.dart';
import 'package:polka_wallet/service/polkascan.dart';
import 'package:polka_wallet/service/substrateApi/api.dart';

class ApiAcala {
  ApiAcala(this.apiRoot);

  final Api apiRoot;
  final store = globalAppStore;

  Future<void> fetchTokens(String pubKey) async {
    if (pubKey != null && pubKey.isNotEmpty) {
      String address = store.account.currentAddress;
      List<String> tokens =
          List<String>.from(store.settings.networkConst['currencyIds']);
      tokens.retainWhere((i) => i != store.settings.networkState.tokenSymbol);
      String queries =
          tokens.map((i) => 'acala.getTokens("$i", "$address")').join(",");
      var res = await apiRoot.evalJavascript('Promise.all([$queries])');
      Map balances = {};
      tokens.asMap().forEach((index, token) {
        balances[token] = res[index].toString();
      });
      store.assets.setAccountBalances(pubKey, balances);
    }
  }

  Future<String> _mockFetchTxs() async {
    Map data = {
      "data": [
        {
          "hash":
              "0x35d84b670411d4224fb7cf3bc521c3ad3208572b2458faba110060b4136f42b2",
          "time": 1586750500643,
          "method": {
            "callIndex": "0x1702",
            "section": "honzon",
            "method": "adjustLoan",
            "args": ["XBTC", "-166,899,564,349,554,688", "0"]
          },
          "isSigned": true,
          "signer": "5HGN9UPNrtZ3vMwyxj7koXuRnZXfSYccwhopm7whoELDJwxU",
          "nonce": "4",
        },
        {
          "hash":
              "0x35d84b670411d4224fb7cf3bc521c3ad3208572b2458faba110060b4136f42bc",
          "time": 1586750500643,
          "method": {
            "callIndex": "0x1702",
            "section": "honzon",
            "method": "adjustLoan",
            "args": ["XBTC", "0", "999,996,899,564,349,554,688"]
          },
          "isSigned": true,
          "signer": "5HGN9UPNrtZ3vMwyxj7koXuRnZXfSYccwhopm7whoELDJwxU",
          "nonce": "3",
        },
        {
          "hash":
              "0x35d84b670411d4224fb7cf3bc521c3ad3208572b2458faba110060b4136f42bb",
          "time": 1586750500643,
          "method": {
            "callIndex": "0x1702",
            "section": "honzon",
            "method": "adjustLoan",
            "args": [
              "XBTC",
              "400000000000000000",
              "1999,996,899,564,349,554,688"
            ]
          },
          "isSigned": true,
          "signer": "5HGN9UPNrtZ3vMwyxj7koXuRnZXfSYccwhopm7whoELDJwxU",
          "nonce": "2",
        },
      ],
    };
    return jsonEncode(data);
  }

  Future<List> updateTxs(int page) async {
    String address = store.account.currentAddress;
//    String data = await PolkaScanApi.fetchTransfers(address, page,
//        network: store.settings.endpoint.info);
    String data = await _mockFetchTxs();
    List txs = jsonDecode(data)['data'];

    if (page == 1) {
      store.acala.setTxsLoading(true);
    }
    // cache first page of txs
//    store.acala.setLoanTxs(txs, reset: page == 1);

//    await apiRoot.updateBlocks(txs);
    store.acala.setTxsLoading(false);
    return txs;
  }

  Future<void> fetchAccountLoans() async {
    String address = store.account.currentAddress;
    List res =
        await apiRoot.evalJavascript('api.derive.loan.allLoans("$address")');
    store.acala.setAccountLoans(res);
  }

  Future<void> fetchLoanTypes() async {
    List res = await apiRoot.evalJavascript('api.derive.loan.allLoanTypes()');
    store.acala.setLoanTypes(res);
  }

  Future<void> subscribeTokenPrices() async {
    await apiRoot.subscribeMessage('price', 'allPrices', [], 'TokenPrices',
        (List res) {
      store.acala.setPrices(res);
    });
  }

  Future<void> unsubscribeTokenPrices() async {
    await apiRoot.unsubscribeMessage('TokenPrices');
  }

  List getSwapTokens() {
    List currencyIds = List.from(store.settings.networkConst['currencyIds']);
    currencyIds
        .retainWhere((i) => i != store.settings.networkState.tokenSymbol);
    return currencyIds;
  }

  Future<void> subscribeDexPool() async {
    getSwapTokens().forEach((i) {
      apiRoot.subscribeMessage('dex', 'pool', [i], 'DexPool$i', (res) {
        fetchTokenSwapRatio();
      });
    });
  }

  Future<void> unsubscribeDexPool() async {
    getSwapTokens().forEach((i) {
      apiRoot.unsubscribeMessage('DexPool$i');
    });
  }

  Future<void> fetchTokenSwapRatio() async {
    //
  }
}
