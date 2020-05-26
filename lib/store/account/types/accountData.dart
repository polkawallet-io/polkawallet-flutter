import 'package:json_annotation/json_annotation.dart';

part 'accountData.g.dart';

@JsonSerializable()
class AccountData extends _AccountData {
  static AccountData fromJson(Map<String, dynamic> json) =>
      _$AccountDataFromJson(json);
  static Map<String, dynamic> toJson(AccountData acc) =>
      _$AccountDataToJson(acc);
}

abstract class _AccountData {
  String name = '';
  String address = '';
  String encoded = '';
  String pubKey = '';

  Map<String, dynamic> encoding = Map<String, dynamic>();
  Map<String, dynamic> meta = Map<String, dynamic>();

  String memo = '';
  bool observation = false;
}
