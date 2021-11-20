import 'package:encointer_wallet/store/encointer/types/encointerTypes.dart';

const String zueriLoi = 'Züri Loi';
const String zul = 'ZUL';
const String cid = '0x22c51e6a656b19dd1e34c6126a75b8af02b38eedbeec51865063f142c83d40d3';

const List<String> communityIdentifiers = [
  cid,
  '0x2ebf164a5bb618ec6caad31488161b237e24d75efa3040286767b620d9183989',
  '0xc792bf36f892404a27603ffd14cd5a12e794ed3c740bab0929ba55b8c747c615',
];

const List<Map<String, dynamic>> communities = [
  {'cid': cid, 'name': zueriLoi}
];

const Map<String, dynamic> communityMetadata = {
  'name': 'Züri Loi',
  'symbol': 'ZUL',
  'icons': 'ShouldBeValidCidSometime',
  'theme': null,
  'url': null
};

const double demurrage = 1.1267607882072287e-7;

const Map<String, dynamic> claim = {
  'claimant_public': '5GrwvaEF5zXb26Fz9rcQpDWS57CtERHpNehXCPcNoHGKutQY',
  'ceremony_index': 63,
  'community_identifier': cid,
  'meetup_index': 1,
  'location': {'lon': '0xffffffffffffffe72ff3493858360000', 'lat': '0x000000000000001987d96638433d0000'},
  'timestamp': 1592719549549,
  'number_of_participants_confirmed': 3
};

const List<String> meetupRegistry = [
  "0xb67fe3812b469da5cac180161851120a45b6c6cf13f5be7062874bfa6cec381f",
  "0x1bb4e46bbd2bb547d93d952c5de12ea7e3a3f3b638551a8eaf35ad086700c00c",
  "0x1cc4e46bbd2bb547d93d952c5de12ea7e3a3f3b638551a8eaf35ad086700c00c",
];

const CeremonyPhase initialPhase = CeremonyPhase.REGISTERING;

const Map<String, dynamic> balanceEntry = {'principal': 23.4, 'last_update': 4};
