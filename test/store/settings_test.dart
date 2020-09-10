import 'package:flutter_test/flutter_test.dart';
import 'package:polka_wallet/common/consts/settings.dart';
import 'package:polka_wallet/store/app.dart';
import 'package:polka_wallet/store/settings.dart';

import 'localStorage_mock.dart';

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
      store.setNetworkName('Kusama');
      expect(store.networkName, 'Kusama');
      expect(store.loading, false);
    });

    test('network endpoint test', () async {
      await store.init('_en');
      expect(store.endpoint.info, networkEndpointKusama.info);
      expect(store.endpointList.length >= 4, true);
      store.setEndpoint(networkEndpointPolkadot);
      expect(store.endpoint.info, networkEndpointPolkadot.info);
      expect(store.endpointList.length >= 3, true);
      store.setEndpoint(networkEndpointAcala);
      expect(store.endpoint.info, networkEndpointAcala.info);
      expect(store.endpointList.length >= 3, true);
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
