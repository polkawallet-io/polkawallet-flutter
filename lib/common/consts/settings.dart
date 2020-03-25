import 'package:polka_wallet/store/settings.dart';

EndpointData networkEndpointKusama = EndpointData.fromJson({
  'info': 'kusama',
  'text': 'Kusama (Polkadot Canary, hosted by Parity)',
  'value': 'wss://kusama-rpc.polkadot.io/',
});

EndpointData networkEndpointAcala = EndpointData.fromJson({
  'info': 'acala',
  'text': 'Acala Mandala (Hosted by Acala Network)',
  'value': 'wss://testnet-node-1.acala.laminar.one/ws',
});
