import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:polka_wallet/store/app.dart';
import 'package:polka_wallet/utils/localStorage.dart';

class MockLocalStorage extends Mock implements LocalStorage {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AppStore test', () {
    final AppStore store = AppStore();
    store.localStorage = MockLocalStorage();
    when(store.localStorage.getContactList())
        .thenAnswer((_) => Future.value([]));
    when(store.localStorage.getAccountList())
        .thenAnswer((_) => Future.value([]));
    when(store.localStorage.getObject(any))
        .thenAnswer((_) => Future.value(null));
    when(store.localStorage.getAccountCache(any, any))
        .thenAnswer((_) => Future.value(null));

    test('app store created and not ready', () {
      expect(store.isReady, false);
    });

    test('app store init and ready', () async {
      await store.init('_en');
      expect(store.isReady, true);
      expect(store.account.accountList.length, 0);
    });
  });
}
