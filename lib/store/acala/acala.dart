import 'dart:math';

import 'package:mobx/mobx.dart';
import 'package:polka_wallet/common/consts/settings.dart';
import 'package:polka_wallet/page-acala/loan/loanAdjustPage.dart';
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
  final String cacheLoanTxsKey = 'loan_txs';

  @observable
  List<LoanType> loanTypes = List<LoanType>();

  @observable
  Map<String, LoanData> loans = {};

  @observable
  Map<String, BigInt> prices = {};

  @observable
  BigInt swapRatio = BigInt.one;

  @observable
  ObservableList<TxLoanData> txs = ObservableList<TxLoanData>();

  @observable
  bool txsLoading = false;

  @action
  void setAccountLoans(List list) {
    Map<String, LoanData> data = {};
    list.forEach((i) {
      String token = i['token'];
      data[token] = LoanData.fromJson(
        Map<String, dynamic>.from(i),
        loanTypes.firstWhere((t) => t.token == token),
        prices[token],
        prices['AUSD'],
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
  void setSwapRatio(BigInt ratio) {
    swapRatio = ratio;
  }

  @action
  Future<void> setLoanTxs(List list,
      {bool reset = false, needCache = true}) async {
    if (reset) {
      txs = ObservableList.of(
          list.map((i) => TxLoanData.fromJson(Map<String, dynamic>.from(i))));
    } else {
      txs.addAll(
          list.map((i) => TxLoanData.fromJson(Map<String, dynamic>.from(i))));
    }

    if (needCache && txs.length > 0) {
      String pubKey = rootStore.account.currentAccount.pubKey;
      List cached = await LocalStorage.getAccountCache(pubKey, cacheLoanTxsKey);
      if (cached != null) {
        cached.addAll(list);
      } else {
        cached = list;
      }
      LocalStorage.setAccountCache(pubKey, cacheLoanTxsKey, cached);
    }
  }

  @action
  void setTxsLoading(bool loading) {
    txsLoading = loading;
  }

  @action
  Future<void> loadCache() async {
    String pubKey = rootStore.account.currentAccount.pubKey;
    List cached = await LocalStorage.getAccountCache(pubKey, cacheLoanTxsKey);
    if (cached != null) {
      print(cached);
      setLoanTxs(cached, needCache: false);
    }
  }
}

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
    data.stabilityFee = BigInt.parse(json['stabilityFee'].toString());
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
      data.amountView = data.amountDebitShare;
      data.currencyIdView = 'aUSD';
    } else if (data.amountDebitShare == BigInt.zero) {
      data.actionType = data.amountCollateral > BigInt.zero
          ? LoanAdjustPage.actionTypeDeposit
          : LoanAdjustPage.actionTypeWithdraw;
      data.amountView = data.amountCollateral;
      data.currencyIdView = data.currencyId;
    } else {
      data.actionType = 'create';
      data.amountView = data.amountDebitShare;
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

  BigInt amountView;
  String currencyIdView;
}
