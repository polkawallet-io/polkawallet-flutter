import 'package:encointer_wallet/mocks/api/api.dart';
import 'package:encointer_wallet/service/substrateApi/api.dart';
import 'package:encointer_wallet/store/app.dart';
import 'package:encointer_wallet/store/encointer/types/encointerTypes.dart';
import 'package:encointer_wallet/store/encointer/types/location.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:encointer_wallet/mocks/data/mockEncointerData.dart';
import 'package:encointer_wallet/mocks/data/mockAccountData.dart';
import 'package:encointer_wallet/mocks/storage/localStorage.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('EncointerStore test', () {
    globalAppStore = AppStore(getMockLocalStorage());
    final AppStore root = globalAppStore;
    accList = [testAcc];
    currentAccountPubKey = accList[0]['pubKey'];

    webApi = MockApi(null, root, withUi: false);

    test('encointer store cache works', () async {
      await root.init('_en');
      await webApi.init();

      final store = root.encointer;

      var phase = CeremonyPhase.REGISTERING;

      store.setCurrentPhase(CeremonyPhase.ASSIGNING);
      store.setCurrentPhase(phase);
      expect(store.currentPhase, phase);

      var phaseFetched = await store.loadCurrentPhase();
      expect(phaseFetched, phase);

      store.setMeetupIndex(1);
      expect(1, store.meetupIndex);
      expect(await store.loadObject(store.encointerMeetupIndexKey), 1);

      var loc = Location.fromJson(claim['location']);
      store.setMeetupLocation(loc);
      expect(store.meetupLocation, loc);
      expect(await store.loadObject(store.encointerMeetupLocationKey), loc.toJson());

      store.setMeetupRegistry(meetupRegistry);
      expect(store.meetupRegistry, meetupRegistry);
      expect(await store.loadObject(store.encointerMeetupRegistryKey), meetupRegistry);

      store.setMeetupTime(2);
      expect(store.meetupTime, 2);
      expect(await store.loadObject(store.encointerMeetupTimeKey), 2);
    });
  });
}
