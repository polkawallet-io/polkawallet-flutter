import 'dart:convert';

import 'package:polka_wallet/page/profile/secondary/settings/remoteNode.dart';
import 'package:polka_wallet/page/profile/secondary/settings/ss58Prefix.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocalStorage {
  static const accountsKey = 'wallet_account_list';
  static const currentAccountKey = 'wallet_current_account';
  static const contactsKey = 'wallet_contact_list';
  static const localeKey = 'wallet_locale';
  static const endpointKey = 'wallet_endpoint';
  static const customSS58Key = 'wallet_custom_ss58';

  static final storage = new _LocalStorage();

  static Future<void> addAccount(Map<String, dynamic> acc) async {
    return storage.addItemToList(accountsKey, acc);
  }

  static Future<void> removeAccount(String pubKey) async {
    return storage.removeItemFromList(accountsKey, 'pubKey', pubKey);
  }

  static Future<List<Map<String, dynamic>>> getAccountList() async {
    return storage.getList(accountsKey);
  }

  static Future<void> setCurrentAccount(String pubKey) async {
    return storage.setKV(currentAccountKey, pubKey);
  }

  static Future<String> getCurrentAccount() async {
    return storage.getKV(currentAccountKey);
  }

  static Future<void> addContact(Map<String, dynamic> con) async {
    return storage.addItemToList(contactsKey, con);
  }

  static Future<void> removeContact(String address) async {
    return storage.removeItemFromList(contactsKey, 'address', address);
  }

  static Future<void> updateContact(Map<String, dynamic> con) async {
    return storage.updateItemInList(
        contactsKey, 'address', con['address'], con);
  }

  static Future<List<Map<String, dynamic>>> getContractList() async {
    return storage.getList(contactsKey);
  }

  static Future<void> setLocale(String value) async {
    return storage.setKV(localeKey, value);
  }

  static Future<String> getLocale() async {
    return storage.getKV(localeKey);
  }

  static Future<void> setEndpoint(Map<String, dynamic> value) async {
    return storage.setKV(endpointKey, jsonEncode(value));
  }

  static Future<Map<String, dynamic>> getEndpoint() async {
    String value = await storage.getKV(endpointKey);
    if (value != null) {
      return jsonDecode(value);
    }
    return default_node;
  }

  static Future<void> setCustomSS58(Map<String, dynamic> value) async {
    return storage.setKV(customSS58Key, jsonEncode(value));
  }

  static Future<Map<String, dynamic>> getCustomSS58() async {
    String value = await storage.getKV(customSS58Key);
    if (value != null) {
      return jsonDecode(value);
    }
    return default_ss58_prefix;
  }
}

class _LocalStorage {
  Future<String> getKV(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(key);
  }

  Future<void> setKV(String key, value) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.setString(key, value);
  }

  Future<void> addItemToList(String storeKey, Map<String, dynamic> acc) async {
    var ls = new List<Map<String, dynamic>>();

    String str = await getKV(storeKey);
    if (str != null) {
      Iterable l = jsonDecode(str);
      ls = l.map((i) => Map<String, dynamic>.from(i)).toList();
    }

    ls.add(acc);

    setKV(storeKey, jsonEncode(ls));
  }

  Future<void> removeItemFromList(
      String storeKey, String itemKey, String itemValue) async {
    var ls = await getList(storeKey);
    ls.removeWhere((item) => item[itemKey] == itemValue);
    setKV(storeKey, jsonEncode(ls));
  }

  Future<void> updateItemInList(String storeKey, String itemKey,
      String itemValue, Map<String, dynamic> itemNew) async {
    var ls = await getList(storeKey);
    ls.removeWhere((item) => item[itemKey] == itemValue);
    ls.add(itemNew);
    setKV(storeKey, jsonEncode(ls));
  }

  Future<List<Map<String, dynamic>>> getList(String storeKey) async {
    var res = new List<Map<String, dynamic>>();

    String str = await getKV(storeKey);
    if (str != null) {
      Iterable l = jsonDecode(str);
      res = l.map((i) => Map<String, dynamic>.from(i)).toList();
    }
    return res;
  }
}
