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
      expect(store.currentAccount.name, 'test');
      expect(store.currentAccount.pubKey, accNew['pubKey']);
      expect(store.currentAccount.address, accNew['address']);

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

      /// remove account
      await store.removeAccount(store.currentAccount);
      expect(store.accountList.length, 1);
      expect(store.currentAccount.name, accList[0]['name']);
      expect(store.currentAccount.pubKey, accList[0]['pubKey']);
      expect(store.currentAccount.address, accList[0]['address']);
    });
  });
}
