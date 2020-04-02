import 'package:mobx/mobx.dart';

part 'acala.g.dart';

class AcalaStore = _AcalaStore with _$AcalaStore;

abstract class _AcalaStore with Store {
  @observable
  Map<String, LoanData> loans = {};

  @observable
  Map<String, BigInt> prices = {};

  @action
  void setAccountLoans(List data) {
    data.forEach((i) {
      loans[i['token']] = LoanData.fromJson(Map<String, dynamic>.from(i));
    });
  }

  @action
  void setPrices(List data) {
    data.forEach((i) {
      prices[i['token']] = i['price'] == null
          ? BigInt.zero
          : BigInt.parse(i['price'].toString());
    });
  }
}

class LoanData extends _LoanData with _$LoanData {
  static LoanData fromJson(Map<String, dynamic> json) {
    LoanData data = LoanData();
    data.token = json['token'];
    data.debits = BigInt.parse(json['debits'].toString());
    data.collaterals = BigInt.parse(json['collaterals'].toString());
  }
}

abstract class _LoanData with Store {
  String token = '';
  BigInt debits = BigInt.zero;
  BigInt collaterals = BigInt.zero;
}
