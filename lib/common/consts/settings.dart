import 'package:polka_wallet/store/settings.dart';

const String network_name_kusama = 'kusama';
const String network_name_polkadot = 'polkadot';
const String network_name_encointer_gesell = 'nctr-gsl';
const String network_name_encointer_cantillon = 'nctr-ctln';

EndpointData networkEndpointPolkadot = EndpointData.fromJson(const {
  'color': 'pink',
  'info': network_name_polkadot,
  'ss58': 0,
  'text': 'Polkadot (Live, hosted by Parity)',
  'value': 'wss://rpc.polkadot.io',
});

EndpointData networkEndpointKusama = EndpointData.fromJson(const {
  'color': 'black',
  'info': network_name_kusama,
  'ss58': 2,
  'text': 'Kusama (Polkadot Canary, hosted by Polkawallet)',
  'value': 'wss://kusama-1.polkawallet.io:9944/',
//  'value': 'ws://10.230.199.44:9944/',
});

EndpointData networkEndpointEncointerGesell = EndpointData.fromJson(const {
  'info': 'nctr-gsl',
  'ss58': 42,
  'text': 'Encointer Gesell (Hosted by Encointer Association)',
  'value': 'wss://gesell.encointer.org',
});

EndpointData networkEndpointEncointerGesellDev = EndpointData.fromJson(const {
  'info': 'nctr-gsl-dev',
  'ss58': 42,
  'text': 'Encointer Gesell Local Devnet',
  // 'value': 'ws://192.168.1.36:9941',
  'value': 'ws://192.168.1.24:9944',
});

EndpointData networkEndpointEncointerCantillon = EndpointData.fromJson(const {
  'info': 'nctr-cln',
  'ss58': 42,
  'text': 'Encointer Cantillon (Hosted by Encointer Association)',
  'value': 'wss://cantillon.encointer.org',
  'worker': 'wss://substratee03.scs.ch'
});

List<EndpointData> networkEndpoints = [
  networkEndpointPolkadot,
  EndpointData.fromJson(const {
    'color': 'pink',
    'info': network_name_polkadot,
    'ss58': 0,
    'text': 'Polkadot (Live, hosted by Web3 Foundation)',
    'value': 'wss://cc1-1.polkadot.network',
  }),
  EndpointData.fromJson(const {
    'color': 'pink',
    'info': network_name_polkadot,
    'ss58': 0,
    'text': 'Polkadot (Live, hosted by Polkawallet CN)',
    'value': 'wss://polkadot-1.polkawallet.io:9944',
  }),
  EndpointData.fromJson(const {
    'color': 'pink',
    'info': network_name_polkadot,
    'ss58': 0,
    'text': 'Polkadot (Live, hosted by Polkawallet EU)',
    'value': 'wss://polkadot-2.polkawallet.io',
  }),
  EndpointData.fromJson(const {
    'color': 'pink',
    'info': network_name_polkadot,
    'ss58': 0,
    'text': 'Polkadot (Live, hosted by Polkawallet EU2)',
    'value': 'ws://62.171.154.98:9944',
  }),
  networkEndpointKusama,
  EndpointData.fromJson(const {
    'color': 'black',
    'info': network_name_kusama,
    'ss58': 2,
    'text': 'Kusama (Polkadot Canary, hosted by Polkawallet Asia)',
    'value': 'wss://kusama-2.polkawallet.io/',
  }),
  EndpointData.fromJson(const {
    'color': 'black',
    'info': network_name_kusama,
    'ss58': 2,
    'text': 'Kusama (Polkadot Canary, hosted by Parity)',
    'value': 'wss://kusama-rpc.polkadot.io/',
  }),
  EndpointData.fromJson(const {
    'color': 'black',
    'info': network_name_kusama,
    'ss58': 2,
    'text': 'Kusama (Polkadot Canary, hosted by Web3 Foundation)',
    'value': 'wss://cc3-5.kusama.network/',
  }),
  networkEndpointEncointerGesell,
  networkEndpointEncointerGesellDev,
  networkEndpointEncointerCantillon,
];

const network_ss58_map = {
  'encointer': 42,
  'nctr-gsl': 42,
  'nctr-cln': 42,
  'nctr-gsl-dev': 42,
  'kusama': 2,
  'substrate': 42,
  'polkadot': 0,
};

const int encointerTokenDecimals = 18;
const int kusama_token_decimals = 12;

const int dot_re_denominate_block = 1248328;

const int SECONDS_OF_DAY = 24 * 60 * 60; // seconds of one day
const int SECONDS_OF_YEAR = 365 * 24 * 60 * 60; // seconds of one year

/// test app versions
const String app_beta_version = '0.8.0';
const int app_beta_version_code = 800;

/// js code versions
const Map<String, int> js_code_version_map = {
  network_name_polkadot: 10010,
  network_name_kusama: 10010,
  network_name_encointer_gesell: 10010,
  network_name_encointer_cantillon: 10010,
};
