import 'dart:math';

import 'package:mobx/mobx.dart';
import 'package:polka_wallet/common/consts/settings.dart';
import 'package:polka_wallet/page-acala/loan/loanAdjustPage.dart';
import 'package:polka_wallet/store/acala/types/dexPoolInfoData.dart';
import 'package:polka_wallet/store/acala/types/txLiquidityData.dart';
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
  final String acalaBaseCoin = 'AUSD';

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
  Map<String, dynamic> swapPool = Map<String, dynamic>();

  @observable
  Map<String, BigInt> swapPoolSharesTotal = Map<String, BigInt>();

  @observable
  ObservableMap<String, String> swapPoolRatios =
      ObservableMap<String, String>();

  @observable
  Map<String, double> swapPoolRewards = Map<String, double>();

  @observable
  ObservableMap<String, BigInt> swapPoolShares =
      ObservableMap<String, BigInt>();

  @observable
  ObservableMap<String, BigInt> swapPoolShareRewards =
      ObservableMap<String, BigInt>();

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
        prices[acalaBaseCoin],
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
  }

  @action
  Future<void> setSwapPool(Map<String, dynamic> map) async {
    swapPool = map;
  }

  @action
  Future<void> setSwapPoolSharesTotal(Map<String, BigInt> map) async {
    swapPoolSharesTotal = map;
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
  Future<void> setSwapPoolShare(String currencyId, BigInt share) async {
    swapPoolShares[currencyId] = share;
  }

  @action
  Future<void> setSwapPoolShareRewards(
      String currencyId, BigInt rewards) async {
    swapPoolShareRewards[currencyId] = rewards;
  }

  @action
  Future<void> setDexPoolInfo(String currencyId, Map info) async {
    dexPoolInfoMap[currencyId] = DexPoolInfoData.fromJson(info);
  }
}

// todo: move struct data definitions into acala.types
class LoanData extends _LoanData with _$LoanData {
  static LoanData fromJson(Map<String, dynamic> json, LoanType type,
      BigInt tokenPrice, BigInt stableCoinPrice) {
    LoanData data = LoanData();
    data.token = json['token'];
    data.type = type;
    data.price = tokenPrice;
    data.stableCoinPrice = stableCoinPrice;
    data.debitShares = BigInt.parse(json['debits'].toString());
    data.debits = type.debitShareToDebit(data.debitShares);
    data.collaterals = BigInt.parse(json['collaterals'].toString());

    data.debitInUSD = type.tokenToUSD(data.debits, stableCoinPrice);
    data.collateralInUSD = type.tokenToUSD(data.collaterals, tokenPrice);
    data.collateralRatio =
        type.calcCollateralRatio(data.debitInUSD, data.collateralInUSD);
    data.requiredCollateral =
        type.calcRequiredCollateral(data.debitInUSD, tokenPrice);
    data.maxToBorrow =
        type.calcMaxToBorrow(data.collaterals, tokenPrice, stableCoinPrice);
    data.stableFeeDay = data.calcStableFee(SECONDS_OF_DAY);
    data.stableFeeYear = data.calcStableFee(SECONDS_OF_YEAR);
    data.liquidationPrice =
        type.calcLiquidationPrice(data.debitInUSD, data.collaterals);
    return data;
  }
}

const int SECONDS_OF_DAY = 24 * 60 * 60; // seconds of one day
const int SECONDS_OF_YEAR = 365 * 24 * 60 * 60; // seconds of one year

abstract class _LoanData with Store {
  String token = '';
  LoanType type = LoanType();
  BigInt price = BigInt.zero;
  BigInt stableCoinPrice = BigInt.zero;
  BigInt debitShares = BigInt.zero;
  BigInt debits = BigInt.zero;
  BigInt collaterals = BigInt.zero;

  // computed properties
  BigInt debitInUSD = BigInt.zero;
  BigInt collateralInUSD = BigInt.zero;
  double collateralRatio = 0;
  BigInt requiredCollateral = BigInt.zero;
  BigInt maxToBorrow = BigInt.zero;
  double stableFeeDay = 0;
  double stableFeeYear = 0;
  BigInt liquidationPrice = BigInt.zero;

  double calcStableFee(int seconds) {
    int blocks = seconds * 1000 ~/ type.expectedBlockTime;
    double base = 1 +
        (type.globalStabilityFee + type.stabilityFee) /
            BigInt.from(pow(10, acala_token_decimals));
    return (pow(base, blocks) - 1);
  }
}

class LoanType extends _LoanType with _$LoanType {
  static LoanType fromJson(Map<String, dynamic> json) {
    LoanType data = LoanType();
    data.token = json['token'];
    data.debitExchangeRate = BigInt.parse(json['debitExchangeRate'].toString());
    data.liquidationPenalty =
        BigInt.parse(json['liquidationPenalty'].toString());
    data.liquidationRatio = BigInt.parse(json['liquidationRatio'].toString());
    data.requiredCollateralRatio =
        BigInt.parse(json['requiredCollateralRatio'].toString());
    data.stabilityFee = BigInt.parse((json['stabilityFee'] ?? 0).toString());
    data.globalStabilityFee =
        BigInt.parse(json['globalStabilityFee'].toString());
    data.maximumTotalDebitValue =
        BigInt.parse(json['maximumTotalDebitValue'].toString());
    data.minimumDebitValue = BigInt.parse(json['minimumDebitValue'].toString());
    data.expectedBlockTime = json['expectedBlockTime'];
    return data;
  }

  BigInt debitShareToDebit(BigInt debitShares) {
    return Fmt.balanceInt(Fmt.token(
      debitShares * debitExchangeRate,
      decimals: acala_token_decimals,
    ));
  }

  BigInt debitToDebitShare(BigInt debits) {
    return Fmt.tokenInt(
      (debits / debitExchangeRate).toString(),
      decimals: acala_token_decimals,
    );
  }

  BigInt tokenToUSD(BigInt amount, BigInt price) {
    return Fmt.balanceInt(Fmt.token(
      amount * price,
      decimals: acala_token_decimals,
    ));
  }

  double calcCollateralRatio(BigInt debitInUSD, BigInt collateralInUSD) {
    if (debitInUSD < minimumDebitValue) {
      return double.minPositive;
    }
    return collateralInUSD / debitInUSD;
  }

  BigInt calcLiquidationPrice(BigInt debitInUSD, BigInt collaterals) {
    return debitInUSD > BigInt.zero
        ? BigInt.from(debitInUSD * this.liquidationRatio / collaterals)
        : BigInt.zero;
  }

  BigInt calcRequiredCollateral(BigInt debitInUSD, BigInt price) {
    if (price > BigInt.zero && debitInUSD > BigInt.zero) {
      return BigInt.from(debitInUSD * requiredCollateralRatio / price);
    }
    return BigInt.zero;
  }

  BigInt calcMaxToBorrow(
      BigInt collaterals, BigInt tokenPrice, BigInt stableCoinPrice) {
    return Fmt.tokenInt(
        (collaterals * tokenPrice / (requiredCollateralRatio * stableCoinPrice))
            .toString(),
        decimals: acala_token_decimals);
  }
}

abstract class _LoanType with Store {
  String token = '';
  BigInt debitExchangeRate = BigInt.zero;
  BigInt liquidationPenalty = BigInt.zero;
  BigInt liquidationRatio = BigInt.zero;
  BigInt requiredCollateralRatio = BigInt.zero;
  BigInt stabilityFee = BigInt.zero;
  BigInt globalStabilityFee = BigInt.zero;
  BigInt maximumTotalDebitValue = BigInt.zero;
  BigInt minimumDebitValue = BigInt.zero;
  int expectedBlockTime = 0;
}

class TxLoanData extends _TxLoanData with _$TxLoanData {
  static TxLoanData fromJson(Map<String, dynamic> json) {
    TxLoanData data = TxLoanData();
    data.hash = json['hash'];
    data.currencyId = json['method']['args'][0];
    data.time = DateTime.fromMillisecondsSinceEpoch(json['time']);
    data.amountCollateral = Fmt.balanceInt(json['method']['args'][1]);
    data.amountDebitShare = Fmt.balanceInt(json['method']['args'][2]);
    if (data.amountCollateral == BigInt.zero) {
      data.actionType = data.amountDebitShare > BigInt.zero
          ? LoanAdjustPage.actionTypeBorrow
          : LoanAdjustPage.actionTypePayback;
      data.currencyIdView = 'aUSD';
    } else if (data.amountDebitShare == BigInt.zero) {
      data.actionType = data.amountCollateral > BigInt.zero
          ? LoanAdjustPage.actionTypeDeposit
          : LoanAdjustPage.actionTypeWithdraw;
      data.currencyIdView = data.currencyId;
    } else {
      data.actionType = 'create';
      data.currencyIdView = 'aUSD';
    }
    return data;
  }

//  static Map<String, dynamic> toJson(TxLoanData data) =>
//      _$TxLoanDataToJson(data);
}

abstract class _TxLoanData with Store {
  String hash;
  String currencyId;
  String actionType;
  DateTime time;
  BigInt amountCollateral;
  BigInt amountDebitShare;

  String currencyIdView;
}
