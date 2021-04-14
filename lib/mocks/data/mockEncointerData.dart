import 'package:encointer_wallet/store/encointer/types/encointerTypes.dart';

const String cid = '0x22c51e6a656b19dd1e34c6126a75b8af02b38eedbeec51865063f142c83d40d3';

const Map<String, dynamic> claim = {
  'claimant_public': '5GrwvaEF5zXb26Fz9rcQpDWS57CtERHpNehXCPcNoHGKutQY',
  'ceremony_index': 63,
  'community_identifier': cid,
  'meetup_index': 1,
  'location': {'lon': 79643934720, 'lat': 152403291178},
  'timestamp': 1592719549549,
  'number_of_participants_confirmed': 3
};

String claimHex =
    '0xd43593c715fdd31c61141abd04a99fd6822c8558854ccde39a5684e7a56da27d3f00000022c51e6a656b19dd1e34c6126a75b8af02b38eedbeec51865063f142c83d40d30100000000000000968680d300000000a8184851040000006da47bd57201000003000000';

const Map<String, dynamic> attestationMap = {
  'attestation': attestation,
  'attestation_hex': attestationHex,
};

const Map<String, dynamic> attestation = {
  'claim': claim,
  'signature': {
    "Sr25519":
        "0xb6dbda8f42ccf3683ce5700762e1e838f6da3066931a791be4c2454cd423e93ac3a2d35dbb18e94b60e5bc10d3bbc7dce8fe67467c5b25c871977144c83b078c"
  },
  'public': '5DPgv6nn4R1Gi1MUiAnzFDPaKF56SYKD9Zq4Q6REUGLhUZk1'
};

const String attestationHex =
    '0xd43593c715fdd31c61141abd04a99fd6822c8558854ccde39a5684e7a56da27d3f00000022c51e6a656b19dd1e34c6126a75b8af02b38eedbeec51865063f142c83d40d301000000000000002aacf17b230000000000268b120000006da47bd5720100000300000001864e24338bf1be2f9a304a67ca1b166f72e76919202109c4ef5b8b6f0e5c00238b7ecc8cc30de924443971dd001a79010ff34c16ca42413eb831e549775a858d8eaf04151687736326c9fea17e25fc5287613693c912909cb226aa4794f26a48';

const List<String> communityIdentifiers = [
  cid,
  '0x2ebf164a5bb618ec6caad31488161b237e24d75efa3040286767b620d9183989',
  '0xc792bf36f892404a27603ffd14cd5a12e794ed3c740bab0929ba55b8c747c615',
];

const List<String> meetupRegistry = [
  "0xb67fe3812b469da5cac180161851120a45b6c6cf13f5be7062874bfa6cec381f",
  "0x1bb4e46bbd2bb547d93d952c5de12ea7e3a3f3b638551a8eaf35ad086700c00c",
  "0x1cc4e46bbd2bb547d93d952c5de12ea7e3a3f3b638551a8eaf35ad086700c00c",
];

const CeremonyPhase initialPhase = CeremonyPhase.REGISTERING;

const Map<String, dynamic> balanceEntry = {'principal': 23.4, 'lastUpdate': 4};
