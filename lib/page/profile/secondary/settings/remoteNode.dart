import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:polka_wallet/service/api.dart';
import 'package:polka_wallet/store/settings.dart';
import 'package:polka_wallet/utils/i18n/index.dart';

const nodeList = [
  {
    'info': 'kusama',
    'text': 'Kusama (Polkadot Canary, hosted by Parity)',
    'value': 'wss://kusama-rpc.polkadot.io/',
  },
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
    'info': 'edgeware',
    'text': 'Edgeware Testnet (Edgeware Testnet, hosted by Commonwealth Labs)',
    'value': 'wss://testnet4.edgewa.re',
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

class RemoteNode extends StatelessWidget {
  RemoteNode(this.api, this.store);

  final Api api;
  final SettingsStore store;

  @override
  Widget build(BuildContext context) {
    var dic = I18n.of(context).profile;
    List<Widget> list = nodeList
        .map((i) => ListTile(
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
