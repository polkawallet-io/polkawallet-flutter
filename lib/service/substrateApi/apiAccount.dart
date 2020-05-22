import 'dart:async';
import 'dart:convert';

import 'package:polka_wallet/common/consts/settings.dart';
import 'package:polka_wallet/store/app.dart';
import 'package:polka_wallet/service/notification.dart';
import 'package:polka_wallet/service/substrateApi/api.dart';
import 'package:polka_wallet/store/account.dart';

class ApiAccount {
  ApiAccount(this.apiRoot);

  final Api apiRoot;
  final store = globalAppStore;

  Future<void> initAccounts() async {
    if (store.account.accountList.length > 0) {
      String accounts = jsonEncode(
          store.account.accountList.map((i) => AccountData.toJson(i)).toList());

      String ss58 = jsonEncode(network_ss58_map.values.toSet().toList());
      Map keys =
          await apiRoot.evalJavascript('account.initKeys($accounts, $ss58)');
      store.account.setPubKeyAddressMap(Map<String, Map>.from(keys));

      // get accounts icons
      getPubKeyIcons(store.account.accountList.map((i) => i.pubKey).toList());
    }

    // and contacts icons
    List<AccountData> contacts =
        List<AccountData>.of(store.settings.contactList);
    getAddressIcons(contacts.map((i) => i.address).toList());
    // set pubKeyAddressMap for observation accounts
    contacts.retainWhere((i) => i.observation);
    List<String> observations = contacts.map((i) => i.pubKey).toList();
    if (observations.length > 0) {
      encodeAddress(observations);
      getPubKeyIcons(observations);
    }
  }

  /// encode addresses to publicKeys
  Future<void> encodeAddress(List<String> pubKeys) async {
    String ss58 = jsonEncode(network_ss58_map.values.toSet().toList());
    Map res = await apiRoot
        .evalJavascript('account.encodeAddress(${jsonEncode(pubKeys)}, $ss58)');
    if (res != null) {
      store.account.setPubKeyAddressMap(Map<String, Map>.from(res));
    }
  }

  /// decode addresses to publicKeys
  Future<Map> decodeAddress(List<String> addresses) async {
    Map res = await apiRoot
        .evalJavascript('account.decodeAddress(${jsonEncode(addresses)})');
    if (res != null) {
      store.account.setPubKeyAddressMap(Map<String, Map>.from(
          {store.settings.endpoint.ss58.toString(): res}));
    }
    return res;
  }

//  Future<Map> getObservationAddressPubKey(String address) async {
//    String ss58 = jsonEncode(network_ss58_map.values.toSet().toList());
//    Map res = await apiRoot.evalJavascript('account.decodeAddress(["$address"])'
//        '.then(res => account.encodeAddress(Object.keys(res), $ss58))');
//    if (res != null) {
//      Map<String, Map> addressMap = Map<String, Map>.from(res);
//      store.account.setPubKeyAddressMap(addressMap);
//    }
//    return res;
//  }

  Future<void> fetchAccountsBonded(List<String> pubKeys) async {
    if (pubKeys.length > 0) {
      List res = await apiRoot.evalJavascript(
          'account.queryAccountsBonded(${jsonEncode(pubKeys)})');
      store.account.setAccountsBonded(res);
    }
  }

  Future<Map> estimateTxFees(Map txInfo, List params, {String rawParam}) async {
    String param = rawParam != null ? rawParam : jsonEncode(params);
    Map res = await apiRoot.evalJavascript(
        'account.txFeeEstimate(${jsonEncode(txInfo)}, $param)',
        allowRepeat: true);
    return res;
  }

  Future<dynamic> _testSendTx() async {
    Completer c = new Completer();
    void onComplete(res) {
      c.complete(res);
    }

    Timer(Duration(seconds: 6), () => onComplete({'hash': '0x79867'}));
    return c.future;
  }

  Future<dynamic> sendTx(
      Map txInfo, List params, String pageTile, String notificationTitle,
      {String rawParam}) async {
    String param = rawParam != null ? rawParam : jsonEncode(params);
    Map res = await apiRoot
        .evalJavascript('account.sendTx(${jsonEncode(txInfo)}, $param)');
//    var res = await _testSendTx();

    if (res['hash'] != null) {
      String hash = res['hash'];
      NotificationPlugin.showNotification(
        int.parse(hash.substring(0, 6)),
        notificationTitle,
        '$pageTile - ${txInfo['module']}.${txInfo['call']}',
      );
    }
    return res;
  }

  Future<void> generateAccount() async {
    Map<String, dynamic> acc = await apiRoot.evalJavascript('account.gen()');
    store.account.setNewAccountKey(acc['mnemonic']);
  }

  Future<Map<String, dynamic>> importAccount({
    String keyType = AccountStore.seedTypeMnemonic,
    String cryptoType = 'sr25519',
    String derivePath = '',
  }) async {
    String key = store.account.newAccount.key;
    String pass = store.account.newAccount.password;
    String code =
        'account.recover("$keyType", "$cryptoType", \'$key$derivePath\', "$pass")';
    code = code.replaceAll(RegExp(r'\t|\n|\r'), '');
    Map<String, dynamic> acc =
        await apiRoot.evalJavascript(code, allowRepeat: true);
    return acc;
  }

  Future<dynamic> checkAccountPassword(String pass) async {
    String pubKey = store.account.currentAccount.pubKey;
    print('checkpass: $pubKey, $pass');
    return apiRoot.evalJavascript('account.checkPassword("$pubKey", "$pass")');
  }

  Future<List> fetchAccountsIndex(List addresses) async {
    if (addresses == null || addresses.length == 0) {
      return [];
    }
    addresses
        .retainWhere((i) => !store.account.accountIndexMap.keys.contains(i));
    if (addresses.length == 0) {
      return [];
    }

    var res = await apiRoot.evalJavascript(
      'account.getAccountIndex(${jsonEncode(addresses)})',
      allowRepeat: true,
    );
    store.account.setAccountsIndex(res);
    return res;
  }

  Future<List> getPubKeyIcons(List keys) async {
    keys.retainWhere((i) => !store.account.pubKeyIconsMap.keys.contains(i));
    if (keys.length == 0) {
      return [];
    }
    List res = await apiRoot.evalJavascript(
        'account.genPubKeyIcons(${jsonEncode(keys)})',
        allowRepeat: true);
    store.account.setPubKeyIconsMap(res);
    return res;
  }

  Future<List> getAddressIcons(List addresses) async {
    addresses
        .retainWhere((i) => !store.account.addressIconsMap.keys.contains(i));
    if (addresses.length == 0) {
      return [];
    }
    List res = await apiRoot.evalJavascript(
        'account.genIcons(${jsonEncode(addresses)})',
        allowRepeat: true);
    store.account.setAddressIconsMap(res);
    return res;
  }

  Future<String> checkDerivePath(
      String seed, String path, String pairType) async {
    String res = await apiRoot.evalJavascript(
      'account.checkDerivePath("$seed", "$path", "$pairType")',
      allowRepeat: true,
    );
    return res;
  }
}
