import 'package:encointer_wallet/mocks/data/mockEncointerData.dart';
import 'package:encointer_wallet/store/app.dart';
import 'package:encointer_wallet/store/encointer/types/encointerTypes.dart';
import 'package:encointer_wallet/store/encointer/types/encointerBalanceData.dart';
import 'package:encointer_wallet/store/encointer/types/location.dart';

abstract class PrepareStorage {
  static void init(AppStore store) {
    store.encointer.setCurrentPhase(initialPhase);
    store.encointer.setCommunityIdentifiers(communityIdentifiers);
    store.encointer.addBalanceEntry(cid, BalanceEntry.fromJson(balanceEntry));
  }

  static void unregisteredParticipant(AppStore store) {
    store.encointer.setParticipantIndex(0);
    store.encointer.setMeetupTime(claim['timestamp']);
  }

  static void readyForMeetup(AppStore store) {
    store.encointer.setCurrentPhase(CeremonyPhase.ATTESTING);
    store.encointer.setParticipantIndex(1);
    store.encointer.setParticipantCount(3);
    store.encointer.setMeetupIndex(1);
    store.encointer.setMeetupLocation(Location.fromJson(claim['location']));
    store.encointer.setMeetupTime(claim['timestamp']);
    store.encointer.setMeetupRegistry(meetupRegistry);
  }
}
