import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:polka_wallet/store/settings.dart';
import 'package:polka_wallet/utils/i18n/index.dart';

class Settings extends StatelessWidget {
  Settings(this.store);

  final SettingsStore store;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(I18n.of(context).profile['setting']),
        centerTitle: true,
      ),
      body: Observer(
        builder: (_) => Padding(
          padding: EdgeInsets.all(8),
          child: ListView(
            children: <Widget>[
              ListTile(
                title: Text(I18n.of(context).profile['setting.node']),
                subtitle: Text(store.endpoint.text ?? ''),
                trailing: Icon(Icons.arrow_forward_ios, size: 18),
                onTap: () =>
                    Navigator.of(context).pushNamed('/profile/endpoint'),
              ),
              ListTile(
                title: Text(I18n.of(context).profile['setting.lang']),
                subtitle: Text(store.endpoint.text ?? ''),
                trailing: Icon(Icons.arrow_forward_ios, size: 18),
              )
            ],
          ),
        ),
      ),
    );
  }
}
