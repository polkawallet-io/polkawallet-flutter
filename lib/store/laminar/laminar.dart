import 'package:mobx/mobx.dart';
import 'package:polka_wallet/store/app.dart';
import 'package:polka_wallet/store/laminar/types/laminarCurrenciesData.dart';

part 'laminar.g.dart';

class LaminarStore extends _LaminarStore with _$LaminarStore {
  LaminarStore(AppStore store) : super(store);
}

abstract class _LaminarStore with Store {
  _LaminarStore(this.rootStore);

  final AppStore rootStore;

  final String localStorageTokensKey = 'laminar_tokens';
  final String localStorageBalanceKey = 'laminar_balance';

  @observable
  List<LaminarTokenData> tokens = [];

  @observable
  List<LaminarBalanceData> accountBalance = [];

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

    List cache = await rootStore.localStorage
        .getAccountCache(pubKey, localStorageBalanceKey);
    if (cache != null) {
      setAccountBalance(cache, shouldCache: false);
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
