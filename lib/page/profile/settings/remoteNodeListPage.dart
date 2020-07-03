import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:polka_wallet/common/consts/settings.dart';
import 'package:polka_wallet/service/substrateApi/api.dart';
import 'package:polka_wallet/store/settings.dart';
import 'package:polka_wallet/utils/i18n/index.dart';

class RemoteNodeListPage extends StatelessWidget {
  RemoteNodeListPage(this.store);

  static final String route = '/profile/endpoint';
  final Api api = webApi;
  final SettingsStore store;

  @override
  Widget build(BuildContext context) {
    var dic = I18n.of(context).profile;
    List<EndpointData> endpoints = List<EndpointData>.of(networkEndpoints);
    endpoints.retainWhere((i) => i.info == store.endpoint.info);
    List<Widget> list = endpoints
        .map((i) => ListTile(
              leading: Container(
                width: 36,
                child: Image.asset('assets/images/public/${i.info}.png'),
              ),
              title: Text(i.info),
              subtitle: Text(i.text),
              trailing: Container(
                width: 40,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    store.endpoint.value == i.value
                        ? Image.asset(
                            'assets/images/assets/success.png',
                            width: 16,
                          )
                        : Container(),
                    Icon(Icons.arrow_forward_ios, size: 18)
                  ],
                ),
              ),
              onTap: () {
                if (store.endpoint.value == i.value) {
                  Navigator.of(context).pop();
                  return;
                }
                store.setEndpoint(i);
                store.setNetworkLoading(true);
                webApi.launchWebview(customNode: true);
                Navigator.of(context).pop();
              },
            ))
        .toList();
    return Scaffold(
      appBar: AppBar(
        title: Text(dic['setting.node.list']),
        centerTitle: true,
      ),
      body: SafeArea(
        child: ListView(padding: EdgeInsets.only(top: 8), children: list),
      ),
    );
  }
}
