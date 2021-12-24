import 'package:encointer_wallet/store/encointer/types/communities.dart';
import 'package:encointer_wallet/store/encointer/types/encointerTypes.dart';

const String zueriLoi = 'Züri Loi';
const String zul = 'ZUL';
CommunityIdentifier cid = CommunityIdentifier.fromFmtString('gbsuv7YXq9G');
CommunityIdentifier cid2 = CommunityIdentifier.fromFmtString('hbsuv7YXq9G');
CommunityIdentifier cid3 = CommunityIdentifier.fromFmtString('ibsuv7YXq9G');

List<CommunityIdentifier> communityIdentifiers = [
  cid,
  cid2,
  cid3,
];

List<CidName> communities = [new CidName(cid, zueriLoi)];

const Map<String, dynamic> communityMetadata = {
  'name': 'Züri Loi',
  'symbol': 'ZUL',
  'icons': 'ShouldBeValidCidSometime',
  'theme': null,
  'url': null
};

const double demurrage = 1.1267607882072287e-7;

Map<String, dynamic> claim = {
  'claimant_public': '5GrwvaEF5zXb26Fz9rcQpDWS57CtERHpNehXCPcNoHGKutQY',
  'ceremony_index': 63,
  'community_identifier': cid,
  'meetup_index': 1,
  'location': {'lat': '18.2341235412345', 'lon': '35.18324513451'},
  'timestamp': 1592719549549,
  'number_of_participants_confirmed': 3
};

const List<String> meetupRegistry = [
  "0xb67fe3812b469da5cac180161851120a45b6c6cf13f5be7062874bfa6cec381f",
  "0x1bb4e46bbd2bb547d93d952c5de12ea7e3a3f3b638551a8eaf35ad086700c00c",
  "0x1cc4e46bbd2bb547d93d952c5de12ea7e3a3f3b638551a8eaf35ad086700c00c",
];

const CeremonyPhase initialPhase = CeremonyPhase.REGISTERING;

const Map<String, dynamic> balanceEntry = {'principal': 23.4, 'lastUpdate': 4};
