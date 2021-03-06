import 'package:encointer_wallet/config/node.dart';
import 'package:encointer_wallet/store/settings.dart';

const String network_name_encointer_gesell = 'nctr-gsl';
const String network_name_encointer_cantillon = 'nctr-ctln';

EndpointData networkEndpointEncointerGesell = EndpointData.fromJson({
  'info': 'nctr-gsl',
  'ss58': 42,
  'text': 'Encointer Gesell (Hosted by Encointer Association)',
  'value': 'wss://gesell.encointer.org',
  'overrideConfig': GesellConfig.toJson()
});

EndpointData networkEndpointEncointerGesellDev = EndpointData.fromJson({
  'info': 'nctr-gsl-dev',
  'ss58': 42,
  'text': 'Encointer Gesell Local Devnet',
  'value': 'ws://192.168.1.24:9979',  // do not use the docker's address, use the host's
  'overrideConfig': MasterBranchConfig.toJson()
});

EndpointData networkEndpointEncointerCantillon = EndpointData.fromJson({
  'info': 'nctr-cln',
  'ss58': 42,
  'text': 'Encointer Cantillon (Hosted by Encointer Association)',
  'value': 'wss://cantillon.encointer.org',
  'worker': 'wss://substratee03.scs.ch',
  'mrenclave': 'CbE3fPWjeYVo9LSNKgPPiCXThFBjfhP1GK6Y9S7t5WVe',
  'overrideConfig': CantillonConfig.toJson()
});

EndpointData networkEndpointEncointerCantillonDev = EndpointData.fromJson({
  'info': 'nctr-cln-dev',
  'ss58': 42,
  'text': 'Encointer Cantillon (Hosted by Encointer Association)',
  'value': 'ws://10.0.0.134:9979', // do not use the docker's address, use the host's
  'worker': 'ws:/10.0.0.134:2079',
  'mrenclave': '4SkU25tusVChcrUprW8X22QoEgamCgj3HKQeje7j8Z4E',
  'overrideConfig': SgxBranchConfig.toJson()
});

List<EndpointData> networkEndpoints = [
  networkEndpointEncointerGesell,
  networkEndpointEncointerGesellDev,
  networkEndpointEncointerCantillon,
  networkEndpointEncointerCantillonDev,
];

const network_ss58_map = {
  'encointer': 42,
  'nctr-gsl': 42,
  'nctr-cln': 42,
  'nctr-gsl-dev': 42,
  'nctr-cln-dev': 42,
  'substrate': 42,
};

const String ipfs_gateway_address = "http://ipfs.encointer.org:8080"; // AVD: 10.0.2.2 = 127.0.0.1

const int ert_decimals = 12;
const int encointer_currencies_decimals = 18;

const double faucetAmount = 0.1;

const int dot_re_denominate_block = 1248328;

const int SECONDS_OF_DAY = 24 * 60 * 60; // seconds of one day
const int SECONDS_OF_YEAR = 365 * 24 * 60 * 60; // seconds of one year

/// test app versions
const String app_beta_version = '0.8.0';
const int app_beta_version_code = 800;

/// js code versions
const Map<String, int> js_code_version_map = {
  network_name_encointer_gesell: 10010,
  network_name_encointer_cantillon: 10010,
};
