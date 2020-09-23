class AccountRecoveryInfo extends _AccountRecoveryInfo {
  static AccountRecoveryInfo fromJson(Map<String, dynamic> json) {
    AccountRecoveryInfo info = AccountRecoveryInfo();
    if (json == null) {
      return info;
    }
    info.address = json['address'];
    info.delayPeriod = json['delayPeriod'];
    info.threshold = json['threshold'];
    info.friends = List<String>.from(json['friends']);
    info.deposit = BigInt.parse(json['deposit'].toString());
    return info;
  }
}

abstract class _AccountRecoveryInfo {
  String address;
  int delayPeriod;
  int threshold;
  List<String> friends;
  BigInt deposit;
}
