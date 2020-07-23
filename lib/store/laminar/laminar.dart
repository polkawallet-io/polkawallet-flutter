import 'package:mobx/mobx.dart';
import 'package:polka_wallet/common/consts/settings.dart';
import 'package:polka_wallet/store/app.dart';
import 'package:polka_wallet/store/assets/types/transferData.dart';
import 'package:polka_wallet/utils/format.dart';

part 'laminar.g.dart';

class LaminarStore extends _LaminarStore with _$LaminarStore {
  LaminarStore(AppStore store) : super(store);
}

abstract class _LaminarStore with Store {
  _LaminarStore(this.rootStore);

  final AppStore rootStore;

  final String cacheTxsTransferKey = 'laminar_transfer_txs';

  @observable
  ObservableList<TransferData> txsTransfer = ObservableList<TransferData>();

  @action
  Future<void> setTransferTxs(
    List list, {
    bool reset = false,
    needCache = true,
  }) async {
    List transfers = list.map((i) {
      return {
        "block_timestamp": int.parse(i['time'].toString().substring(0, 10)),
        "hash": i['hash'],
        "success": true,
        "from": rootStore.account.currentAddress,
        "to": i['params'][0],
        "token": i['params'][1],
        "amount": Fmt.balance(i['params'][2], decimals: acala_token_decimals),
      };
    }).toList();
    if (reset) {
      txsTransfer = ObservableList.of(transfers
          .map((i) => TransferData.fromJson(Map<String, dynamic>.from(i))));
    } else {
      txsTransfer.addAll(transfers
          .map((i) => TransferData.fromJson(Map<String, dynamic>.from(i))));
    }

    if (needCache && txsTransfer.length > 0) {
      _cacheTxs(list, cacheTxsTransferKey);
    }
  }

  Future<void> _cacheTxs(List list, String cacheKey) async {
    String pubKey = rootStore.account.currentAccount.pubKey;
    List cached =
        await rootStore.localStorage.getAccountCache(pubKey, cacheKey);
    if (cached != null) {
      cached.addAll(list);
    } else {
      cached = list;
    }
    rootStore.localStorage.setAccountCache(pubKey, cacheKey, cached);
  }

  @action
  Future<void> loadAccountCache() async {
    // return if currentAccount not exist
    String pubKey = rootStore.account.currentAccountPubKey;
    if (pubKey == null || pubKey.isEmpty) {
      return;
    }

    List cache = await Future.wait([
      rootStore.localStorage.getAccountCache(pubKey, cacheTxsTransferKey),
    ]);
    if (cache[0] != null) {
      setTransferTxs(List.of(cache[1]), reset: true, needCache: false);
    } else {
      setTransferTxs([], reset: true, needCache: false);
    }
  }

  @action
  Future<void> loadCache() async {
    loadAccountCache();
  }
}
