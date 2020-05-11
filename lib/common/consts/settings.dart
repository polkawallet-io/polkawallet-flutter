import 'package:polka_wallet/store/settings.dart';

EndpointData networkEndpointKusama = EndpointData.fromJson(const {
  'info': 'kusama',
  'ss58': 2,
  'text': 'Kusama (Polkadot Canary, hosted by Polkawallet)',
  'value': 'ws://mandala-01.acala.network:9954/',
});

EndpointData networkEndpointAcala = EndpointData.fromJson(const {
  'info': 'acala-mandala',
  'ss58': 42,
  'text': 'Acala Mandala (Hosted by Polkawallet)',
  'value': 'wss://39.99.168.67/wss',
});

List<EndpointData> networkEndpoints = [
  networkEndpointKusama,
  EndpointData.fromJson(const {
    'info': 'kusama',
    'ss58': 2,
    'text': 'Kusama (Polkadot Canary, hosted by Parity)',
    'value': 'wss://kusama-rpc.polkadot.io/',
  }),
  networkEndpointAcala,
  EndpointData.fromJson(const {
    'info': 'acala-mandala',
    'ss58': 42,
    'text': 'Acala Mandala (Hosted by Acala Network)',
    'value': 'wss://testnet-node-1.acala.laminar.one/ws',
  }),
];

const network_ss58_map = {
  'acala': 42,
  'kusama': 2,
  'substrate': 42,
  'polkadot': 0,
};

const int acala_token_decimals = 18;

const int SECONDS_OF_DAY = 24 * 60 * 60; // seconds of one day
const int SECONDS_OF_YEAR = 365 * 24 * 60 * 60; // seconds of one year

const String acala_stable_coin = 'AUSD';
const String acala_stable_coin_view = 'aUSD';

/// test app versions
const String app_beta_version = '0.7.4-beta.3';
