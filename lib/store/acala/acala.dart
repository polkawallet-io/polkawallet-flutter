import 'package:mobx/mobx.dart';
import 'package:polka_wallet/common/consts/settings.dart';
import 'package:polka_wallet/store/acala/types/dexPoolInfoData.dart';
import 'package:polka_wallet/store/acala/types/loanType.dart';
import 'package:polka_wallet/store/acala/types/txLiquidityData.dart';
import 'package:polka_wallet/store/acala/types/txLoanData.dart';
import 'package:polka_wallet/store/acala/types/txSwapData.dart';
import 'package:polka_wallet/store/app.dart';
import 'package:polka_wallet/utils/format.dart';
import 'package:polka_wallet/utils/localStorage.dart';

part 'acala.g.dart';

class AcalaStore extends _AcalaStore with _$AcalaStore {
  AcalaStore(AppStore store) : super(store);
}

abstract class _AcalaStore with Store {
  _AcalaStore(this.rootStore);

  final AppStore rootStore;
  final String cacheTxsLoanKey = 'loan_txs';
  final String cacheTxsSwapKey = 'swap_txs';
  final String cacheTxsDexLiquidityKey = 'dex_liquidity_txs';

  @observable
  Map<String, BigInt> airdrops = Map<String, BigInt>();

  @observable
  List<LoanType> loanTypes = List<LoanType>();

  @observable
  Map<String, LoanData> loans = {};

  @observable
  Map<String, BigInt> prices = {};

  @observable
  ObservableList<TxLoanData> txsLoan = ObservableList<TxLoanData>();

  @observable
  ObservableList<TxSwapData> txsSwap = ObservableList<TxSwapData>();

  @observable
  ObservableList<TxDexLiquidityData> txsDexLiquidity =
      ObservableList<TxDexLiquidityData>();

  @observable
  bool txsLoading = false;

  @observable
  List<String> currentSwapPair = List<String>();

  @observable
  String swapRatio = '';

  @observable
  ObservableMap<String, String> swapPoolRatios =
      ObservableMap<String, String>();

  @observable
  Map<String, double> swapPoolRewards = Map<String, double>();

  @observable
  ObservableMap<String, DexPoolInfoData> dexPoolInfoMap =
      ObservableMap<String, DexPoolInfoData>();

  @computed
  List<String> get swapTokens {
    return List<String>.from(
        rootStore.settings.networkConst['dex']['enabledCurrencyIds']);
  }

  @computed
  double get swapFee {
    return Fmt.balanceDouble(
        rootStore.settings.networkConst['dex']['getExchangeFee'].toString(),
        decimals: acala_token_decimals);
  }

  @computed
  double get dexLiquidityRewards {
    return Fmt.bigIntToDouble(
        Fmt.balanceInt(rootStore.settings.networkConst['dex']['getExchangeFee']
            .toString()),
        decimals: acala_token_decimals);
  }

  @action
  void setAirdrops(Map<String, BigInt> amt) {
    airdrops = amt;
  }

  @action
  void setAccountLoans(List list) {
    Map<String, LoanData> data = {};
    list.forEach((i) {
      String token = i['token'];
      data[token] = LoanData.fromJson(
        Map<String, dynamic>.from(i),
        loanTypes.firstWhere((t) => t.token == token),
        prices[token],
        prices[acala_stable_coin],
      );
    });
    loans = data;
  }

  @action
  void setLoanTypes(List list) {
    loanTypes = List<LoanType>.of(
        list.map((i) => LoanType.fromJson(Map<String, dynamic>.from(i))));
  }

  @action
  void setPrices(List list) {
    Map<String, BigInt> data = {};
    list.forEach((i) {
      data[i['token']] = i['price'] == null
          ? BigInt.zero
          : BigInt.parse(i['price']['value'].toString());
    });
    prices = data;
  }

  @action
  void setSwapPair(List pair) {
    currentSwapPair = ObservableList<String>.of(List<String>.from(pair));
  }

  @action
  void setSwapRatio(String ratio) {
    swapRatio = ratio;
  }

  @action
  Future<void> setLoanTxs(List list,
      {bool reset = false, needCache = true}) async {
    if (reset) {
      txsLoan = ObservableList.of(
          list.map((i) => TxLoanData.fromJson(Map<String, dynamic>.from(i))));
    } else {
      txsLoan.addAll(
          list.map((i) => TxLoanData.fromJson(Map<String, dynamic>.from(i))));
    }

    if (needCache && txsLoan.length > 0) {
      _cacheTxs(list, cacheTxsLoanKey);
    }
  }

  @action
  Future<void> setSwapTxs(List list,
      {bool reset = false, needCache = true}) async {
    if (reset) {
      txsSwap = ObservableList.of(
          list.map((i) => TxSwapData.fromJson(Map<String, dynamic>.from(i))));
    } else {
      txsSwap.addAll(
          list.map((i) => TxSwapData.fromJson(Map<String, dynamic>.from(i))));
    }

    if (needCache && txsSwap.length > 0) {
      _cacheTxs(list, cacheTxsSwapKey);
    }
  }

  @action
  Future<void> setDexLiquidityTxs(List list,
      {bool reset = false, needCache = true}) async {
    list.retainWhere((i) => i['params'] != null);
    if (reset) {
      txsDexLiquidity = ObservableList.of(list.map(
          (i) => TxDexLiquidityData.fromJson(Map<String, dynamic>.from(i))));
    } else {
      txsDexLiquidity.addAll(list.map(
          (i) => TxDexLiquidityData.fromJson(Map<String, dynamic>.from(i))));
    }

    if (needCache && txsDexLiquidity.length > 0) {
      _cacheTxs(list, cacheTxsDexLiquidityKey);
    }
  }

  @action
  Future<void> _cacheTxs(List list, String cacheKey) async {
    String pubKey = rootStore.account.currentAccount.pubKey;
    List cached = await LocalStorage.getAccountCache(pubKey, cacheKey);
    if (cached != null) {
      cached.addAll(list);
    } else {
      cached = list;
    }
    LocalStorage.setAccountCache(pubKey, cacheKey, cached);
  }

  @action
  void setTxsLoading(bool loading) {
    txsLoading = loading;
  }

  @action
  Future<void> loadCache() async {
    String pubKey = rootStore.account.currentAccount.pubKey;
    List cached = await LocalStorage.getAccountCache(pubKey, cacheTxsLoanKey);
    if (cached != null) {
      setLoanTxs(cached, needCache: false);
    }
    List dexs =
        await LocalStorage.getAccountCache(pubKey, cacheTxsDexLiquidityKey);
    if (dexs != null) {
      setDexLiquidityTxs(dexs, needCache: false);
    }
  }

  @action
  Future<void> setSwapPoolRatio(String currencyId, String ratio) async {
    swapPoolRatios[currencyId] = ratio;
  }

  @action
  Future<void> setSwapPoolRewards(Map<String, dynamic> map) async {
    final int blockTime =
        rootStore.settings.networkConst['babe']['expectedBlockTime'];
    Map<String, double> rewards = {};
    map.forEach((k, v) {
      rewards[k] =
          Fmt.balanceDouble(v.toString(), decimals: acala_token_decimals) *
              SECONDS_OF_YEAR *
              1000 /
              blockTime;
    });
    swapPoolRewards = rewards;
  }

  @action
  Future<void> setDexPoolInfo(String currencyId, Map info) async {
    dexPoolInfoMap[currencyId] = DexPoolInfoData.fromJson(info);
  }
}
