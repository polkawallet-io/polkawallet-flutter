import 'dart:math';

import 'package:polka_wallet/common/consts/settings.dart';
import 'package:polka_wallet/utils/format.dart';

class LoanType extends _LoanType {
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

  BigInt debitShareToDebit(BigInt debitShares, int decimals) {
    return Fmt.balanceInt(Fmt.token(
      debitShares * debitExchangeRate,
      decimals,
    ));
  }

  BigInt debitToDebitShare(BigInt debits, int decimals) {
    return Fmt.tokenInt(
      (debits / debitExchangeRate).toString(),
      decimals,
    );
  }

  BigInt tokenToUSD(BigInt amount, price, int decimals) {
    return Fmt.balanceInt(Fmt.token(amount * price, decimals));
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
      BigInt collaterals, tokenPrice, stableCoinPrice, int decimals) {
    return Fmt.tokenInt(
        (collaterals * tokenPrice / (requiredCollateralRatio * stableCoinPrice))
            .toString(),
        decimals);
  }
}

abstract class _LoanType {
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

class LoanData extends _LoanData {
  static LoanData fromJson(Map<String, dynamic> json, LoanType type,
      BigInt tokenPrice, stableCoinPrice, int decimals) {
    LoanData data = LoanData();
    data.token = json['token'];
    data.type = type;
    data.price = tokenPrice;
    data.stableCoinPrice = stableCoinPrice;
    data.debitShares = BigInt.parse(json['debits'].toString());
    data.debits = type.debitShareToDebit(data.debitShares, decimals);
    data.collaterals = BigInt.parse(json['collaterals'].toString());

    data.debitInUSD = type.tokenToUSD(data.debits, stableCoinPrice, decimals);
    data.collateralInUSD =
        type.tokenToUSD(data.collaterals, tokenPrice, decimals);
    data.collateralRatio =
        type.calcCollateralRatio(data.debitInUSD, data.collateralInUSD);
    data.requiredCollateral =
        type.calcRequiredCollateral(data.debitInUSD, tokenPrice);
    data.maxToBorrow = type.calcMaxToBorrow(
        data.collaterals, tokenPrice, stableCoinPrice, decimals);
    data.stableFeeDay = data.calcStableFee(SECONDS_OF_DAY);
    data.stableFeeYear = data.calcStableFee(SECONDS_OF_YEAR);
    data.liquidationPrice =
        type.calcLiquidationPrice(data.debitInUSD, data.collaterals);
    return data;
  }
}

abstract class _LoanData {
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
