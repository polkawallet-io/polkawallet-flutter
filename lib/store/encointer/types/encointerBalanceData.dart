import 'dart:convert';

import 'package:encointer_wallet/store/encointer/types/communities.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:mobx/mobx.dart';

part 'encointerBalanceData.g.dart';

@JsonSerializable(explicitToJson: true)
class EncointerBalanceData {
  EncointerBalanceData(this.cid, this.balanceEntry);

  @observable
  final CommunityIdentifier cid;
  @observable
  final BalanceEntry balanceEntry;

  @override
  String toString() {
    return jsonEncode(this);
  }

  factory EncointerBalanceData.fromJson(Map<String, dynamic> json) => _$EncointerBalanceDataFromJson(json);
  Map<String, dynamic> toJson() => _$EncointerBalanceDataToJson(this);
}

@JsonSerializable()
class BalanceEntry {
  BalanceEntry(this.principal, this.lastUpdate);

  @observable
  final double principal;
  @observable
  final int lastUpdate;

  @override
  String toString() {
    return jsonEncode(this);
  }

  factory BalanceEntry.fromJson(Map<String, dynamic> json) => _$BalanceEntryFromJson(json);
  Map<String, dynamic> toJson() => _$BalanceEntryToJson(this);
}
