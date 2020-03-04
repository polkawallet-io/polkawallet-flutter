import 'dart:async';
import 'dart:convert';

import 'package:polka_wallet/store/app.dart';
import 'package:polka_wallet/page/profile/secondary/settings/remoteNode.dart';
import 'package:polka_wallet/service/notification.dart';
import 'package:polka_wallet/service/substrateApi/api.dart';
import 'package:polka_wallet/store/account.dart';

class ApiAccount {
  ApiAccount(this.apiRoot);

  final Api apiRoot;
  final store = globalAppStore;

  Future<void> initAccounts() async {
    String accounts = jsonEncode(
        store.account.accountList.map((i) => AccountData.toJson(i)).toList());
    int ss58 = default_ss58_map[store.settings.endpoint.info];
    if (store.settings.customSS58Format['info'] != 'default') {
      ss58 = store.settings.customSS58Format['value'];
    }
    List keys =
        await apiRoot.evalJavascript('account.initKeys($accounts, $ss58)');
    store.account.setPubKeyAddressMap(keys);
    // get accounts icons
    getAddressIcons(keys.map((i) => i['address']).toList());
    // get settings.contacts icons
    getAddressIcons(store.settings.contactList.map((i) => i.address).toList());
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
      Map txInfo, List params, String notificationTitle) async {
//    var res = await _testSendTx();
    var res = await apiRoot.evalJavascript(
        'account.sendTx(${jsonEncode(txInfo)}, ${jsonEncode(params)})');

    if (res != null) {
      String hash = res['hash'];
      NotificationPlugin.showNotification(int.parse(hash.substring(0, 6)),
          notificationTitle, '${txInfo['module']}.${txInfo['call']}');
    }
    return res;
  }

  Future<void> generateAccount() async {
    Map<String, dynamic> acc = await apiRoot.evalJavascript('account.gen()');
    store.account.setNewAccountKey(acc['mnemonic']);
  }

  Future<Map<String, dynamic>> importAccount(
      {String keyType = 'Mnemonic', String cryptoType = 'sr25519'}) async {
    String key = store.account.newAccount.key;
    String pass = store.account.newAccount.password;
    String code =
        'account.recover("$keyType", "$cryptoType", \'$key\', "$pass")';
    print(code);
    Map<String, dynamic> acc = await apiRoot.evalJavascript(code);
    if (acc != null) {
      acc['name'] = store.account.newAccount.name;
      await store.account.addAccount(acc);
      store.staking.clearSate();
      store.gov.clearSate();

      if (store.settings.customSS58Format['info'] == 'default') {
        await apiRoot
            .setSS58Format(default_ss58_map[store.settings.endpoint.info]);
      } else {
        await apiRoot.setSS58Format(store.settings.customSS58Format['value']);
      }

      apiRoot.assets.fetchBalance(acc['address']);
      apiRoot.staking.fetchAccountStaking(acc['address']);
    }
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
    var res = await apiRoot
        .evalJavascript('account.getAccountIndex(${jsonEncode(addresses)})');
    store.account.setAccountsIndex(res);
    return res;
  }

  Future<List> getAddressIcons(List addresses) async {
    addresses
        .retainWhere((i) => !store.account.accountIconsMap.keys.contains(i));
    print(addresses);
    List res = await apiRoot
        .evalJavascript('account.genIcons(${jsonEncode(addresses)})');
    store.account.setAccountIconsMap(res);
    return res;
  }
}
