import 'package:mobx/mobx.dart';
import 'package:polka_wallet/common/consts/settings.dart';
import 'package:polka_wallet/store/app.dart';
import 'package:polka_wallet/store/assets/types/transferData.dart';
import 'package:polka_wallet/store/laminar/types/laminarCurrenciesData.dart';
import 'package:polka_wallet/utils/format.dart';

part 'laminar.g.dart';

class LaminarStore extends _LaminarStore with _$LaminarStore {
  LaminarStore(AppStore store) : super(store);
}

abstract class _LaminarStore with Store {
  _LaminarStore(this.rootStore);

  final AppStore rootStore;

  final String cacheTxsTransferKey = 'laminar_transfer_txs';

  final String localStorageTokensKey = 'laminar_tokens';
  final String localStorageBalanceKey = 'laminar_balance';

  @observable
  ObservableList<TransferData> txsTransfer = ObservableList<TransferData>();

  @observable
  List<LaminarTokenData> tokens = [];

  @observable
  List<LaminarBalanceData> accountBalance = [];

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
  Future<void> setTokenList(List data, {bool shouldCache = true}) async {
    tokens = data.map((e) => LaminarTokenData.fromJson(e)).toList();
    if (shouldCache) {
      rootStore.localStorage.setObject(localStorageTokensKey, data);
    }
  }

  @action
  Future<void> setAccountBalance(List data, {bool shouldCache = true}) async {
    accountBalance = data.map((e) => LaminarBalanceData.fromJson(e)).toList();
    if (shouldCache) {
      rootStore.localStorage.setAccountCache(
          rootStore.account.currentAccountPubKey, localStorageBalanceKey, data);
    }
  }

  @action
  Future<void> loadAccountCache() async {
    // return if currentAccount not exist
    String pubKey = rootStore.account.currentAccountPubKey;
    if (pubKey == null || pubKey.isEmpty) {
      return;
    }

    List cache = await Future.wait([
      rootStore.localStorage.getAccountCache(pubKey, localStorageBalanceKey),
      rootStore.localStorage.getAccountCache(pubKey, cacheTxsTransferKey),
    ]);
    if (cache[0] != null) {
      setAccountBalance(List.of(cache[0]), shouldCache: false);
    }
    if (cache[1] != null) {
      setTransferTxs(List.of(cache[1]), reset: true, needCache: false);
    } else {
      setTransferTxs([], reset: true, needCache: false);
    }
  }

  @action
  Future<void> loadCache() async {
    List cacheOverview = await Future.wait([
      rootStore.localStorage.getObject(localStorageTokensKey),
    ]);
    if (cacheOverview[0] != null) {
      setTokenList(List.of(cacheOverview[0]), shouldCache: false);
    }

    loadAccountCache();
  }
}
