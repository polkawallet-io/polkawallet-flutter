import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:polka_wallet/service/substrateApi/api.dart';
import 'package:polka_wallet/store/settings.dart';
import 'package:polka_wallet/utils/i18n/index.dart';

const default_node_zh = {
  'info': 'kusama',
  'text': 'Kusama (Polkadot Canary, hosted by Polkawallet)',
  'value': 'ws://mandala-01.acala.network:9954/',
};
const default_node = {
  'info': 'kusama',
  'text': 'Kusama (Polkadot Canary, hosted by Parity)',
  'value': 'wss://kusama-rpc.polkadot.io/',
};
const nodeList = [
//  default_node_zh,
  default_node,
  {
    'info': 'kusama',
    'text': 'Kusama (Polkadot Canary, hosted by Web3 Foundation)',
    'value': 'wss://cc3-5.kusama.network/',
  },
  {
    'info': 'westend',
    'text': 'Westend (Polkadot Testnet, hosted by Parity)',
    'value': 'wss://westend-rpc.polkadot.io',
  },
  {
    'info': 'substrate',
    'text': 'Flaming Fir (Substrate Testnet, hosted by Parity)',
    'value': 'wss://substrate-rpc.parity.io/',
  },
  {
    'info': 'substrate',
    'text': 'Kulupu (Kulupu Mainnet, hosted by Kulupu)',
    'value': 'wss://rpc.kulupu.network/ws',
  },
];
const default_ss58_map = {
  'kusama': 2,
  'substrate': 42,
  'westend': 42,
  'polkadot': 0,
};

class RemoteNode extends StatelessWidget {
  RemoteNode(this.store);

  final Api api = webApi;
  final SettingsStore store;

  @override
  Widget build(BuildContext context) {
    var dic = I18n.of(context).profile;
    List<Widget> list = nodeList
        .map((i) => ListTile(
              leading: Container(
                width: 36,
                child: Image.asset('assets/images/public/${i['info']}.png'),
              ),
              title: Text(i['info']),
              subtitle: Text(i['text']),
              trailing: Icon(Icons.arrow_forward_ios, size: 18),
              onTap: () {
                store.setEndpoint(i);
                api.changeNode(i['value']);
                Navigator.of(context).pop();
              },
            ))
        .toList();
    return Scaffold(
      appBar: AppBar(
        title: Text(dic['setting.node.list']),
        centerTitle: true,
      ),
      body: Padding(
        padding: EdgeInsets.all(8),
        child: ListView(children: list),
      ),
    );
  }
}
