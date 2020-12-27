import 'package:polka_wallet/store/settings.dart';

const String network_name_kusama = 'kusama';
const String network_name_polkadot = 'polkadot';
const String network_name_acala_mandala = 'acala-mandala';
const String network_name_laminar_turbulence = 'laminar-turbulence';
const String network_name_edgeware = 'edgeware';

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

EndpointData networkEndpointAcala = EndpointData.fromJson(const {
  'color': 'indigo',
  'info': network_name_acala_mandala,
  'ss58': 42,
  'text': 'Acala Mandala (Hosted by Acala Network)',
  'value': 'wss://acala-testnet-1.polkawallet.io:9904',
});

EndpointData networkEndpointLaminar = EndpointData.fromJson(const {
  'color': 'purple',
  'info': network_name_laminar_turbulence,
  'ss58': 42,
  'text': 'Laminar TC2',
  'value': 'wss://node-6729167516986527744.jm.onfinality.io/ws',
});

EndpointData networkEndpointEdgeware = EndpointData.fromJson(const {
  'color': 'green',
  'info': network_name_edgeware,
  'ss58': 7,
  'text': 'Edgeware Mainnet #1 (hosted by Commonwealth Labs)',
  'value': 'wss://mainnet1.edgewa.re/',
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
  EndpointData.fromJson(const {
    'color': 'black',
    'info': network_name_kusama,
    'ss58': 2,
    'text': 'Kusama (Polkadot Canary, user-run public nodes)',
    'value': 'wss://kusama.polkadot.cloud.ava.do/',
  }),
  networkEndpointAcala,
  EndpointData.fromJson(const {
    'color': 'indigo',
    'info': network_name_acala_mandala,
    'ss58': 42,
    'text': 'Mandala TC5 Node 1 (Hosted by OnFinality)',
    'value': 'wss://node-6714447553777491968.jm.onfinality.io/ws'
  }),
  EndpointData.fromJson(const {
    'color': 'indigo',
    'info': network_name_acala_mandala,
    'ss58': 42,
    'text': 'Mandala TC5 Node 2 (Hosted by OnFinality)',
    'value': 'wss://node-6714447553211260928.rz.onfinality.io/ws',
  }),
  networkEndpointLaminar,
  EndpointData.fromJson(const {
    'color': 'purple',
    'info': network_name_laminar_turbulence,
    'ss58': 42,
    'text': 'Laminar TC2',
    'value': 'wss://node-6729167516973944832.rz.onfinality.io/ws',
  }),
  networkEndpointEdgeware,
  EndpointData.fromJson(const {
    'color': 'green',
    'info': network_name_edgeware,
    'ss58': 7,
    'text': 'Edgeware Mainnet #2 (hosted by Commonwealth Labs)',
    'value': 'wss://mainnet2.edgewa.re/',
  }),
  networkEndpointEdgeware,
  EndpointData.fromJson(const {
    'color': 'green',
    'info': network_name_edgeware,
    'ss58': 7,
    'text': 'Edgeware Mainnet #3 (hosted by Commonwealth Labs)',
    'value': 'wss://mainnet3.edgewa.re/',
  }),
  networkEndpointEdgeware,
  EndpointData.fromJson(const {
    'color': 'green',
    'info': network_name_edgeware,
    'ss58': 7,
    'text': 'Edgeware Mainnet #4 (hosted by Commonwealth Labs)',
    'value': 'wss://mainnet4.edgewa.re/',
  }),
];

const network_ss58_map = {
  'acala': 42,
  'laminar': 42,
  'kusama': 2,
  'substrate': 42,
  'polkadot': 0,
  'edgeware': 7,
};

const int kusama_token_decimals = 12;
const int acala_token_decimals = 18;
const int edgeware_token_decimals = 18;

const int dot_re_denominate_block = 1248328;

const int SECONDS_OF_DAY = 24 * 60 * 60; // seconds of one day
const int SECONDS_OF_YEAR = 365 * 24 * 60 * 60; // seconds of one year

const String acala_stable_coin = 'AUSD';
const String acala_stable_coin_view = 'aUSD';
const String acala_token_ren_btc = 'RENBTC';
const String acala_token_ren_btc_view = 'renBTC';
const String cross_chain_transfer_address_acala =
    '5CAca1aAUSDCrossChainTransferxxxxxxxxxxxxxxxxikw';
const String cross_chain_transfer_address_laminar =
    '5CLaminarAUSDCrossChainTransferxxxxxxxxxxxxxwisu';

/// app versions
const String app_beta_version = 'v1.0.9-beta.1';
const int app_beta_version_code = 1091;

/// js code versions
const Map<String, int> js_code_version_map = {
  network_name_polkadot: 10510,
  network_name_kusama: 10510,
  network_name_acala_mandala: 10510,
  network_name_laminar_turbulence: 10510,
};

/// graphql for laminar
const GraphQLConfig = {
  'httpUri': 'https://indexer.laminar-chain.laminar.one/v1/graphql',
  'wsUri': 'wss://indexer.laminar-chain.laminar.one/v1/graphql',
};
const Map<String, String> margin_pool_name_map = {
  '0': 'Laminar',
  '1': 'Crypto',
  '2': 'FX',
};
const Map<String, String> synthetic_pool_name_map = {
  '0': 'Laminar',
  '1': 'Crypto',
  '2': 'FX',
};
const Map<String, String> laminar_leverage_map = {
  'Two': 'x2',
  'Three': 'x3',
  'Five': 'x5',
  'Ten': 'x10',
  'Twenty': 'x20',
};
final BigInt laminarIntDivisor = BigInt.parse('1000000000000000000');
