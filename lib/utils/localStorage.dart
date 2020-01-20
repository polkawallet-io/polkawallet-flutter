import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class LocalStorage {
  static final storage = new _LocalStorage();

  static Future<void> addAccount(Map<String, dynamic> acc) async {
    return storage.addAccount(acc);
  }

  static Future<void> removeAccount(String address) async {
    return storage.removeAccount(address);
  }

  static Future<List<Map<String, dynamic>>> getAccountList() async {
    return storage.getAccountList();
  }

  static Future<void> setCurrentAccount(Map<String, dynamic> acc) async {
    return storage.setCurrentAccount(acc);
  }

  static Future<Map<String, dynamic>> getCurrentAccount() async {
    return storage.getCurrentAccount();
  }
}

class _LocalStorage {
  final accountsKey = 'wallet_account_list';

  final currentAccountKey = 'wallet_current_account';

  Future<String> getItem(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(key);
  }

  Future<void> setItem(String key, value) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString(key, value);
  }

  Future<void> addAccount(Map<String, dynamic> acc) async {
    var accounts = new List<Map<String, dynamic>>();

    String accountsStr = await getItem(accountsKey);
    if (accountsStr != null) {
      Iterable l = jsonDecode(accountsStr);
      accounts = l.map((i) => Map<String, dynamic>.from(i)).toList();
    }

    accounts.add(acc);

    setItem(accountsKey, jsonEncode(accounts));
  }

  Future<void> removeAccount(String address) async {
    var accounts = await getAccountList();
    accounts.removeWhere((item) => item['address'] == address);
    setItem(accountsKey, jsonEncode(accounts));
  }

  Future<List<Map<String, dynamic>>> getAccountList() async {
    var accounts = new List<Map<String, dynamic>>();

    String accountsStr = await getItem(accountsKey);
    if (accountsStr != null) {
      Iterable l = jsonDecode(accountsStr);
      accounts = l.map((i) => Map<String, dynamic>.from(i)).toList();
    }
    return accounts;
  }

  Future<void> setCurrentAccount(Map<String, dynamic> acc) async {
    setItem(currentAccountKey, jsonEncode(acc));
  }

  Future<Map<String, dynamic>> getCurrentAccount() async {
    String accountStr = await getItem(currentAccountKey);
    if (accountStr != null) {
      return jsonDecode(accountStr);
    }
    return new Map<String, dynamic>();
  }
}
