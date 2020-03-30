import 'package:polka_wallet/store/settings.dart';

EndpointData networkEndpointKusama = EndpointData.fromJson(const {
  'info': 'kusama',
  'ss58': 2,
  'text': 'Kusama (Polkadot Canary, hosted by Parity)',
  'value': 'wss://kusama-rpc.polkadot.io/',
});

EndpointData networkEndpointAcala = EndpointData.fromJson(const {
  'info': 'acala-mandala',
  'ss58': 42,
  'text': 'Acala Mandala (Hosted by Acala Network)',
  'value': 'wss://testnet-node-1.acala.laminar.one/ws',
});

const network_ss58_map = {
  'acala': 42,
  'kusama': 2,
  'substrate': 42,
  'polkadot': 0,
};
