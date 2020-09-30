class BalancesInfo extends _BalancesInfo {
  static BalancesInfo fromJson(Map<String, dynamic> json) {
    BalancesInfo data = BalancesInfo();
    data.freeBalance = BigInt.parse(json['freeBalance'].toString());
    data.transferable = BigInt.parse(json['availableBalance'].toString());
    data.bonded = BigInt.parse(json['frozenFee'].toString());
    data.reserved = BigInt.parse(json['reservedBalance'].toString());
    data.lockedBalance = BigInt.parse(json['lockedBalance'].toString());
    data.total = data.freeBalance + data.reserved;
    data.lockedBreakdown = List.of(json['lockedBreakdown']).map((i) {
      return BalanceLockedItemData.fromJson(i);
    }).toList();
    return data;
  }
}

class _BalancesInfo {
  /// votingBalance
  BigInt total;

  /// freeBalance = total - reserved
  BigInt freeBalance;

  /// availableBalance
  BigInt transferable;

  /// frozenFee
  BigInt bonded;

  /// reservedBalance
  BigInt reserved;

  /// lockedBalance
  BigInt lockedBalance;

  /// locked details
  List<BalanceLockedItemData> lockedBreakdown;
}

class BalanceLockedItemData extends _BalanceLockedItemData {
  static BalanceLockedItemData fromJson(Map<String, dynamic> json) {
    BalanceLockedItemData data = BalanceLockedItemData();
    data.amount = BigInt.parse(json['amount'].toString());
    data.reasons = json['reasons'];
    data.use = json['use'].toString().trim();
    return data;
  }
}

class _BalanceLockedItemData {
  BigInt amount;
  String reasons;
  String use;
}
