import 'package:encointer_wallet/service/substrateApi/api.dart';
import 'package:encointer_wallet/store/app.dart';
import 'package:encointer_wallet/store/encointer/types/encointerTypes.dart';
import 'package:encointer_wallet/store/encointer/types/location.dart';
import 'package:flutter_test/flutter_test.dart';

import '../mocks/apiEncointer_mock.dart';
import '../mocks/data/mockEncointerData.dart';
import '../mocks/localStorage_mock.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('EncointerStore test', () {
    final AppStore root = AppStore();
    root.localStorage = getMockLocalStorage();

    webApi = Api(null, root);
    webApi.encointer = getMockApiEncointer();

    test('encointer store cache works', () async {
      await root.init('_en');
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
