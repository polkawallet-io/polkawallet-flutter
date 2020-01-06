import 'package:mobx/mobx.dart';
import 'package:json_annotation/json_annotation.dart';

part 'assets.g.dart';

@JsonSerializable()
class AssetsStore extends _AssetsStore with _$AssetsStore {
  AssetsStore();
}

abstract class _AssetsStore with Store {
  _AssetsStore();

  @observable
  String description = '';

  @observable
  Account newAccount = new Account();

  @action
  Future setNewAccount(Map<String, dynamic> res) async {
    newAccount = Account.fromJson(new Map<String, dynamic>.from(res['data']));
  }
}

@JsonSerializable()
class Account extends _Account with _$Account {
  Account();

  static Account fromJson(Map<String, dynamic> json) => _$AccountFromJson(json);
  static Map<String, dynamic> toJson(Account acc) => _$AccountToJson(acc);
}

abstract class _Account with Store {
  _Account();

  @observable
  String address = '';

  @observable
  bool isLocked = false;

  @observable
  String mnemonic = '';

  @observable
  String seed = '';
}
