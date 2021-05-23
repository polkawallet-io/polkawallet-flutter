import 'package:encointer_wallet/mocks/data/mockEncointerData.dart';
import 'package:encointer_wallet/service/substrateApi/api.dart';
import 'package:encointer_wallet/service/substrateApi/encointer/apiEncointer.dart';
import 'package:encointer_wallet/store/encointer/types/attestation.dart';
import 'package:encointer_wallet/store/encointer/types/claimOfAttendance.dart';
import 'package:encointer_wallet/store/encointer/types/encointerTypes.dart';
import 'package:encointer_wallet/store/encointer/types/communities.dart';

/// The key rationale behind this mock is that all the getters do not alter the app state.
///
/// This allows to configure the app storage for specific tests via the `PrepareStorage` class.
/// The getters then return the preconfigured value, which in turn leads to consistent
/// responses in the test.
class MockApiEncointer extends ApiEncointer {
  MockApiEncointer(Api api) : super(api);

  void _log(String msg) {
    print("[mockApiAssets] $msg");
  }

  @override
  Future<void> startSubscriptions() async {
    _log("empty startSubscriptions stub");
  }

  @override
  Future<void> stopSubscriptions() async {
    _log("empty stopSubscriptions stub");
  }

  @override
  Future<void> subscribeShopRegistry() async {
    _log("empty subscribeShopRegistry stub");
  }

  @override
  Future<CeremonyPhase> getCurrentPhase() async {
    if (store.encointer.currentPhase == null) {
      store.encointer.setCurrentPhase(initialPhase);
    }

    return store.encointer.currentPhase;
  }

  @override
  Future<int> getCurrentCeremonyIndex() async {
    if (store.encointer.currentCeremonyIndex == null) {
      store.encointer.setCurrentCeremonyIndex(1);
    }
    return store.encointer.currentCeremonyIndex;
  }

  @override
  Future<void> getEncointerBalance() async {}

  @override
  Future<int> getParticipantIndex() async {
    return store.encointer.participantIndex;
  }

  @override
  Future<int> getMeetupIndex() async {
    return store.encointer.meetupIndex;
  }

  @override
  Future<int> getParticipantCount() async {
    return store.encointer.participantCount;
  }

  @override
  Future<List<String>> getCommunityIdentifiers() async {
    return communityIdentifiers;
  }

  @override
  Future<List<String>> getMeetupRegistry() async {
    return store.encointer.meetupRegistry;
  }

  @override
  Future<CommunityMetadata> getCommunityMetadata() async {
    return  store.encointer.communityMetadata;
  }

  @override
  Future<List<CidName>> communitiesGetAll() async {
    return store.encointer.communities;
  }

  @override
  Future<void> getDemurrage() async {}

  @override
  Future<AttestationResult> attestClaimOfAttendance(String _claimHex, String _password) async {
    return AttestationResult.fromJson(attestationMap);
  }

  @override
  Future<ClaimOfAttendance> parseClaimOfAttendance(String _claimHex) async {
    return Future.value(ClaimOfAttendance.fromJson(claim));
  }

  @override
  Future<Attestation> parseAttestation(String _attestationHex) async {
    return Attestation.fromJson(attestation);
  }

  @override
  void createClaimOfAttendance(int _participants) {
    if (store.encointer.myClaim == null) {
      store.encointer.setMyClaim(ClaimOfAttendance.fromJson(claim));
    }
  }

  @override
  Future<void> getMeetupLocation() async {}

  @override
  getShopRegistry() async {
    _log("warn: getShopRegistry mock is unimplemented");
  }

  @override
  Future<DateTime> getMeetupTime() async {
    return DateTime.fromMillisecondsSinceEpoch(claim['timestamp']);
  }
}
