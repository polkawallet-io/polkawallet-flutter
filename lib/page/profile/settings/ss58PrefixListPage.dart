import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:polka_wallet/service/substrateApi/api.dart';
import 'package:polka_wallet/store/settings.dart';
import 'package:polka_wallet/utils/i18n/index.dart';

const default_ss58_prefix = {
  'info': 'default',
  'text': 'Default for the connected node',
  'value': 42,
};
const prefixList = [
  default_ss58_prefix,
  {'info': 'substrate', 'text': 'Substrate (development)', 'value': 42},
  {'info': 'kusama', 'text': 'Kusama (canary)', 'value': 2},
  {'info': 'polkadot', 'text': 'Polkadot (live)', 'value': 0}
];

class SS58PrefixListPage extends StatelessWidget {
  SS58PrefixListPage(this.store);

  static final String route = '/profile/ss58';
  final Api api = webApi;
  final SettingsStore store;

  @override
  Widget build(BuildContext context) {
    var dic = I18n.of(context).profile;
    List<Widget> list = prefixList
        .map((i) => ListTile(
              leading: Container(
                width: 36,
                child: Image.asset('assets/images/public/${i['info']}.png'),
              ),
              title: Text(i['info']),
              subtitle: Text(i['text']),
              trailing: Icon(Icons.arrow_forward_ios, size: 18),
              onTap: () {
                if (store.customSS58Format['info'] == i['info']) {
                  Navigator.of(context).pop();
                  return;
                }
                store.setCustomSS58Format(i);
//                if (i['info'] == 'default') {
//                  api.account
//                      .setSS58Format(default_ss58_map[store.endpoint.info]);
//                } else {
//                  api.account.setSS58Format(i['value']);
//                }
                Navigator.of(context).pop();
              },
            ))
        .toList();
    return Scaffold(
      appBar: AppBar(
        title: Text(dic['setting.prefix.list']),
        centerTitle: true,
      ),
      body: SafeArea(
        child: ListView(children: list),
      ),
    );
  }
}
