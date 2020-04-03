import 'dart:math';

import 'package:mobx/mobx.dart';
import 'package:polka_wallet/common/consts/settings.dart';
import 'package:polka_wallet/utils/format.dart';

part 'acala.g.dart';

class AcalaStore = _AcalaStore with _$AcalaStore;

abstract class _AcalaStore with Store {
  @observable
  List<LoanType> loanTypes = List<LoanType>();

  @observable
  Map<String, LoanData> loans = {};

  @observable
  Map<String, BigInt> prices = {};

  @action
  void setAccountLoans(List list) {
    Map<String, LoanData> data = {};
    list.forEach((i) {
      String token = i['token'];
      data[token] = LoanData.fromJson(Map<String, dynamic>.from(i),
          loanTypes.firstWhere((t) => t.token == token), prices[token]);
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
}

class LoanData extends _LoanData with _$LoanData {
  static LoanData fromJson(
      Map<String, dynamic> json, LoanType type, BigInt price) {
    LoanData data = LoanData();
    data.token = json['token'];
    data.type = type;
    data.price = price;
    data.debits = BigInt.parse(json['debits'].toString());
    data.collaterals = BigInt.parse(json['collaterals'].toString());

    data.debitAmount = data.debitToUSD();
    data.collateralAmount = data.collateralToUSD();
    data.collateralRatio = type.calcCollateralRatio(data);
    data.requiredCollateral = data.calcRequiredCollateral();
    data.stableFeeAPR = data.calcStableFeeAPR();
    data.liquidationPrice = type.calcLiquidationPrice(data);
    return data;
  }
}

const int SECONDS_OF_YEAR = 365 * 24 * 60 * 60; // seconds of one year

abstract class _LoanData with Store {
  String token = '';
  LoanType type = LoanType();
  BigInt price = BigInt.zero;
  BigInt debits = BigInt.zero;
  BigInt collaterals = BigInt.zero;

  // computed properties
  BigInt debitAmount = BigInt.zero;
  BigInt collateralAmount = BigInt.zero;
  double collateralRatio = 0;
  BigInt requiredCollateral = BigInt.zero;
  double stableFeeAPR = 0;
  BigInt liquidationPrice = BigInt.zero;

  BigInt debitToStableCoin() {
    return debits * type.debitExchangeRate;
  }

  BigInt debitToUSD() {
    return debitToStableCoin() * price;
  }

  BigInt collateralToUSD() {
    return collaterals * price;
  }

  BigInt calcRequiredCollateral() {
    if (price > BigInt.zero && debitAmount > BigInt.zero) {
      BigInt requiredAmount = BigInt.parse(Fmt.token(
          debitAmount * type.requiredCollateralRatio,
          decimals: acala_token_decimals));
      return BigInt.from(requiredAmount / price);
    }
    return BigInt.zero;
  }

  double calcStableFeeAPR() {
    return ((1 +
                double.parse(Fmt.token(type.stabilityFee,
                    decimals: acala_token_decimals))) *
            pow((SECONDS_OF_YEAR / type.expectedBlockTime), 2) -
        1);
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

  double calcCollateralRatio(LoanData loanData) {
    return loanData.collateralAmount / loanData.debitAmount;
  }

  BigInt calcLiquidationPrice(LoanData loanData) {
    return loanData.collaterals > BigInt.zero
        ? BigInt.from(
            loanData.debitAmount * this.liquidationRatio / loanData.collaterals)
        : BigInt.zero;
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
