import 'package:mobx/mobx.dart';
import 'package:polka_wallet/common/consts/settings.dart';
import 'package:polka_wallet/store/acala/types/dexPoolInfoData.dart';
import 'package:polka_wallet/store/acala/types/loanType.dart';
import 'package:polka_wallet/store/acala/types/stakingPoolInfoData.dart';
import 'package:polka_wallet/store/acala/types/txHomaData.dart';
import 'package:polka_wallet/store/acala/types/txLiquidityData.dart';
import 'package:polka_wallet/store/acala/types/txLoanData.dart';
import 'package:polka_wallet/store/acala/types/txSwapData.dart';
import 'package:polka_wallet/store/app.dart';
import 'package:polka_wallet/store/assets/types/transferData.dart';
import 'package:polka_wallet/utils/format.dart';

part 'acala.g.dart';

class AcalaStore extends _AcalaStore with _$AcalaStore {
  AcalaStore(AppStore store) : super(store);
}

abstract class _AcalaStore with Store {
  _AcalaStore(this.rootStore);

  final AppStore rootStore;
  final String cacheAirdropKey = 'airdrop_balance';
  final String cacheTxsTransferKey = 'transfer_txs';
  final String cacheTxsLoanKey = 'loan_txs';
  final String cacheTxsSwapKey = 'swap_txs';
  final String cacheTxsDexLiquidityKey = 'dex_liquidity_txs';
  final String cacheTxsHomaKey = 'homa_txs';

  @observable
  Map<String, BigInt> airdrops = Map<String, BigInt>();

  @observable
  List<LoanType> loanTypes = List<LoanType>();

  @observable
  Map<String, LoanData> loans = {};

  @observable
  Map<String, BigInt> prices = {};

  @observable
  ObservableList<TransferData> txsTransfer = ObservableList<TransferData>();

  @observable
  ObservableList<TxLoanData> txsLoan = ObservableList<TxLoanData>();

  @observable
  ObservableList<TxSwapData> txsSwap = ObservableList<TxSwapData>();

  @observable
  ObservableList<TxDexLiquidityData> txsDexLiquidity =
      ObservableList<TxDexLiquidityData>();

  @observable
  ObservableList<TxHomaData> txsHoma = ObservableList<TxHomaData>();

  @observable
  bool txsLoading = false;

  @observable
  ObservableMap<String, String> swapPoolRatios =
      ObservableMap<String, String>();

  @observable
  Map<String, double> swapPoolRewards = Map<String, double>();

  @observable
  ObservableMap<String, DexPoolInfoData> dexPoolInfoMap =
      ObservableMap<String, DexPoolInfoData>();

  @observable
  StakingPoolInfoData stakingPoolInfo = StakingPoolInfoData();

  @observable
  HomaUserInfoData homaUserInfo = HomaUserInfoData();

  @computed
  List<String> get swapTokens {
    return List<String>.from(
        rootStore.settings.networkConst['dex']['enabledCurrencyIds']);
  }

  @computed
  double get swapFee {
    return Fmt.balanceDouble(
        rootStore.settings.networkConst['dex']['getExchangeFee'].toString(),
        rootStore.settings.networkState.tokenDecimals);
  }

  @computed
  double get dexLiquidityRewards {
    return Fmt.bigIntToDouble(
        Fmt.balanceInt(rootStore.settings.networkConst['dex']['getExchangeFee']
            .toString()),
        rootStore.settings.networkState.tokenDecimals);
  }

  @action
  void setAirdrops(Map amount, {bool needCache = true}) {
    if (amount['tokens'] == null) {
      airdrops = {};
      return;
    }

    Map<String, BigInt> amt = Map<String, BigInt>();
    amount['tokens'].asMap().forEach((i, v) {
      amt[v] = Fmt.balanceInt(amount['amount'][i].toString());
    });

    airdrops = amt;
    if (needCache) {
      rootStore.localStorage.setAccountCache(
          rootStore.account.currentAccountPubKey, cacheAirdropKey, amount);
    }
  }

  @action
  void setAccountLoans(List list) {
    Map<String, LoanData> data = {};
    list.forEach((i) {
      String token = i['token'];
      data[token] = LoanData.fromJson(
        Map<String, dynamic>.from(i),
        loanTypes.firstWhere((t) => t.token == token),
        prices[token] ?? BigInt.zero,
        prices[acala_stable_coin] ?? BigInt.zero,
        rootStore.settings.networkState.tokenDecimals,
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
  Future<void> setTransferTxs(List list,
      {bool reset = false, needCache = true}) async {
    List transfers = list.map((i) {
      return {
        "block_timestamp": int.parse(i['time'].toString().substring(0, 10)),
        "hash": i['hash'],
        "success": true,
        "from": rootStore.account.currentAddress,
        "to": i['params'][0],
        "token": i['params'][1],
        "amount": Fmt.balance(
          i['params'][2],
          rootStore.settings.networkState.tokenDecimals,
        ),
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
    final int decimals = rootStore.settings.networkState.tokenDecimals;
    if (reset) {
      txsSwap = ObservableList.of(list.map(
          (i) => TxSwapData.fromJson(Map<String, dynamic>.from(i), decimals)));
    } else {
      txsSwap.addAll(list.map(
          (i) => TxSwapData.fromJson(Map<String, dynamic>.from(i), decimals)));
    }

    if (needCache && txsSwap.length > 0) {
      _cacheTxs(list, cacheTxsSwapKey);
    }
  }

  @action
  Future<void> setDexLiquidityTxs(List list,
      {bool reset = false, needCache = true}) async {
    list.retainWhere((i) => i['params'] != null);
    final int decimals = rootStore.settings.networkState.tokenDecimals;
    if (reset) {
      txsDexLiquidity = ObservableList.of(list.map((i) =>
          TxDexLiquidityData.fromJson(Map<String, dynamic>.from(i), decimals)));
    } else {
      txsDexLiquidity.addAll(list.map((i) =>
          TxDexLiquidityData.fromJson(Map<String, dynamic>.from(i), decimals)));
    }

    if (needCache && txsDexLiquidity.length > 0) {
      _cacheTxs(list, cacheTxsDexLiquidityKey);
    }
  }

  @action
  Future<void> setHomaTxs(List list,
      {bool reset = false, needCache = true}) async {
    final int decimals = rootStore.settings.networkState.tokenDecimals;
    if (reset) {
      txsHoma = ObservableList.of(list.map(
          (i) => TxHomaData.fromJson(Map<String, dynamic>.from(i), decimals)));
    } else {
      txsHoma.addAll(list.map(
          (i) => TxHomaData.fromJson(Map<String, dynamic>.from(i), decimals)));
    }

    if (needCache && txsHoma.length > 0) {
      _cacheTxs(list, cacheTxsHomaKey);
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
  void setTxsLoading(bool loading) {
    txsLoading = loading;
  }

  @action
  Future<void> loadCache() async {
    // return if currentAccount not exist
    String pubKey = rootStore.account.currentAccountPubKey;
    if (pubKey == null || pubKey.isEmpty) {
      return;
    }

    List cached = await Future.wait([
      rootStore.localStorage.getAccountCache(pubKey, cacheTxsLoanKey),
      rootStore.localStorage.getAccountCache(pubKey, cacheTxsDexLiquidityKey),
      rootStore.localStorage.getAccountCache(pubKey, cacheTxsSwapKey),
      rootStore.localStorage.getAccountCache(pubKey, cacheTxsHomaKey),
      rootStore.localStorage.getAccountCache(pubKey, cacheTxsTransferKey),
      rootStore.localStorage.getAccountCache(pubKey, cacheAirdropKey),
    ]);

    if (cached[0] != null) {
      setLoanTxs(cached[0], needCache: false);
    } else {
      setLoanTxs([], needCache: false, reset: true);
    }
    if (cached[1] != null) {
      setDexLiquidityTxs(cached[1], needCache: false);
    } else {
      setDexLiquidityTxs([], needCache: false, reset: true);
    }
    if (cached[2] != null) {
      setSwapTxs(cached[2], needCache: false, reset: true);
    } else {
      setSwapTxs([], needCache: false, reset: true);
    }
    if (cached[3] != null) {
      setHomaTxs(cached[3], needCache: false);
    } else {
      setHomaTxs([], needCache: false, reset: true);
    }
    if (cached[4] != null) {
      setTransferTxs(cached[4], reset: true, needCache: false);
    } else {
      setTransferTxs([], reset: true, needCache: false);
    }
    if (cached[5] != null) {
      setAirdrops(cached[5], needCache: false);
    } else {
      setAirdrops({}, needCache: false);
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
      rewards[k] = Fmt.balanceDouble(
              v.toString(), rootStore.settings.networkState.tokenDecimals) *
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

  @action
  Future<void> setHomaStakingPool(Map pool) async {
    stakingPoolInfo = StakingPoolInfoData.fromJson(pool);
  }

  @action
  Future<void> setHomaUserInfo(Map info) async {
    homaUserInfo = HomaUserInfoData.fromJson(info);
  }
}
