import 'package:flutter_test/flutter_test.dart';
import 'package:encointer_wallet/config/consts.dart';
import 'package:encointer_wallet/store/app.dart';
import 'package:encointer_wallet/store/settings.dart';

import '../mocks/localStorage_mock.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('SettingsStore test', () {
    final AppStore root = AppStore();
    root.localStorage = getMockLocalStorage();
    final store = SettingsStore(root);

    test('settings store created', () {
      expect(store.cacheNetworkStateKey, 'network');
      expect(store.localeCode, '');
    });
    test('set locale code properly', () async {
      await store.setLocalCode('_en');
      expect(store.localeCode, '_en');
      await store.setLocalCode('_zh');
      expect(store.localeCode, '_zh');
    });
    test('set network loading state properly', () async {
      expect(store.loading, true);
      store.setNetworkLoading(false);
      expect(store.loading, false);
      store.setNetworkLoading(true);
      expect(store.loading, true);
    });
    test('set network name properly', () async {
      expect(store.networkName, '');
      store.setNetworkName('Encointer');
      expect(store.networkName, 'Encointer');
      expect(store.loading, false);
    });

    test('network endpoint test', () async {
      await store.init('_en');
      expect(store.endpoint.info, networkEndpointEncointerGesell.info);
      expect(store.endpointList.length, 1);
    });

    test('set network state properly', () async {
      store.setNetworkState(Map<String, dynamic>.of({
        'ss58Format': 2,
        'tokenDecimals': 12,
        'tokenSymbol': 'KSM',
      }));
      expect(store.networkState.ss58Format, 2);
      expect(store.networkState.tokenDecimals, 12);
      expect(store.networkState.tokenSymbol, 'KSM');
    });
  });
}
