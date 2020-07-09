import 'package:polka_wallet/store/settings.dart';

EndpointData networkEndpointPolkadot = EndpointData.fromJson(const {
  'info': 'polkadot',
  'ss58': 0,
  'text': 'Polkadot (Live, hosted by Parity)',
  'value': 'wss://rpc.polkadot.io',
});

EndpointData networkEndpointKusama = EndpointData.fromJson(const {
  'info': 'kusama',
  'ss58': 2,
  'text': 'Kusama (Polkadot Canary, hosted by Polkawallet)',
  'value': 'ws://mandala-01.acala.network:9954/',
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
  'value': 'ws://192.168.1.36:9941',
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
    'info': 'polkadot',
    'ss58': 0,
    'text': 'Polkadot (Live, hosted by Web3 Foundation)',
    'value': 'wss://cc1-1.polkadot.network',
  }),
  EndpointData.fromJson(const {
    'info': 'polkadot',
    'ss58': 0,
    'text': 'Polkadot (Live, hosted by Polkawallet)',
    'value': 'ws://62.171.154.98:9944',
  }),
  networkEndpointKusama,
  EndpointData.fromJson(const {
    'info': 'kusama',
    'ss58': 2,
    'text': 'Kusama (Polkadot Canary, hosted by Parity)',
    'value': 'wss://kusama-rpc.polkadot.io/',
  }),
  EndpointData.fromJson(const {
    'info': 'kusama',
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

const int encointer_token_decimals = 18;

const int SECONDS_OF_DAY = 24 * 60 * 60; // seconds of one day
const int SECONDS_OF_YEAR = 365 * 24 * 60 * 60; // seconds of one year

/// test app versions
const String app_beta_version = '0.7.6-beta.3';
