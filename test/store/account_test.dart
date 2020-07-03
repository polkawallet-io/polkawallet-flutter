import 'package:flutter_test/flutter_test.dart';
import 'package:polka_wallet/store/app.dart';

import 'localStorage_mock.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AccountStore test', () {
    final AppStore root = AppStore();
    root.localStorage = getMockLocalStorage();

    test('account store test', () async {
      await root.init('_en');
      final store = root.account;

      /// accounts load
      expect(store.accountList.length, 1);
      expect(store.currentAccountPubKey, accList[0]['pubKey']);
      expect(store.currentAccount.name, accList[0]['name']);
      expect(store.currentAccount.pubKey, accList[0]['pubKey']);
      expect(store.currentAccount.address, accList[0]['address']);

      /// create new account
      store.setNewAccount('test', 'a111111');
      expect(store.newAccount.name, 'test');
      expect(store.newAccount.password, 'a111111');
      store.setNewAccountKey('new_key');
      expect(store.newAccount.key, 'new_key');

      /// add account
      String testPass = 'a111111';
      await store.addAccount(accNew, testPass);
      expect(store.accountList.length, 2);
      expect(store.currentAccountPubKey, accNew['pubKey']);
      expect(store.currentAccount.name, 'test');
      expect(store.currentAccount.pubKey, accNew['pubKey']);
      expect(store.currentAccount.address, accNew['address']);
      expect(store.optionalAccounts.length, 1);
      expect(store.optionalAccounts[0].pubKey, accList[0]['pubKey']);
      expect(store.optionalAccounts[0].name, accList[0]['name']);
      expect(store.optionalAccounts[0].pubKey, accList[0]['pubKey']);
      expect(store.optionalAccounts[0].address, accList[0]['address']);

      /// update account
      await store.updateAccountName('test-change');
      expect(store.currentAccount.name, 'test-change');
      expect(store.currentAccount.pubKey, accNew['pubKey']);
      expect(store.currentAccount.address, accNew['address']);

      /// update works after reload
      await store.loadAccount();
      expect(store.currentAccount.name, 'test-change');
      expect(store.currentAccount.pubKey, accNew['pubKey']);
      expect(store.currentAccount.address, accNew['address']);

      /// change account
      store.setCurrentAccount(accList[0]['pubKey']);
      expect(store.currentAccountPubKey, accList[0]['pubKey']);
      expect(store.currentAccount.name, accList[0]['name']);
      expect(store.currentAccount.pubKey, accList[0]['pubKey']);
      expect(store.currentAccount.address, accList[0]['address']);
      expect(store.optionalAccounts[0].pubKey, accNew['pubKey']);
      expect(store.optionalAccounts[0].name, 'test-change');
      expect(store.optionalAccounts[0].pubKey, accNew['pubKey']);
      expect(store.optionalAccounts[0].address, accNew['address']);

      store.setCurrentAccount(accNew['pubKey']);
      expect(store.currentAccountPubKey, accNew['pubKey']);
      expect(store.currentAccount.name, 'test-change');
      expect(store.currentAccount.pubKey, accNew['pubKey']);
      expect(store.currentAccount.address, accNew['address']);

      /// remove account
      await store.removeAccount(store.currentAccount);
      expect(store.accountList.length, 1);
      expect(store.currentAccountPubKey, accList[0]['pubKey']);
      expect(store.currentAccount.name, accList[0]['name']);
      expect(store.currentAccount.pubKey, accList[0]['pubKey']);
      expect(store.currentAccount.address, accList[0]['address']);
      expect(store.optionalAccounts.length, 0);

      /// add observation account
      Map<String, dynamic> contact = {
        "name": "gav",
        "address": "FcxNWVy5RESDsErjwyZmPCW6Z8Y3fbfLzmou34YZTrbcraL",
        "pubKey":
            "0x86b7409a11700afb027924cb40fa43889d98709ea35319d48fea85dd35004e64",
        "observation": true,
      };
      await root.settings.addContact(contact);
      expect(store.accountListAll.length, 2);
      expect(store.optionalAccounts.length, 1);

      /// change to observation account
      store.setCurrentAccount(contact['pubKey']);
      expect(store.currentAccountPubKey, contact['pubKey']);
      expect(store.currentAccount.name, contact['name']);
      expect(store.currentAccount.pubKey, contact['pubKey']);
      expect(store.currentAccount.address, contact['address']);
      expect(store.optionalAccounts[0].pubKey, accList[0]['pubKey']);
      expect(store.optionalAccounts[0].name, accList[0]['name']);
      expect(store.optionalAccounts[0].pubKey, accList[0]['pubKey']);
      expect(store.optionalAccounts[0].address, accList[0]['address']);

      /// update observation account
      Map<String, dynamic> contactNew = Map<String, dynamic>.of(contact);
      contactNew['name'] = 'changed-observation';
      await root.settings.updateContact(contactNew);
      expect(store.currentAccount.name, 'changed-observation');
    });
  });
}
