import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:polka_wallet/common/components/addressIcon.dart';
import 'package:polka_wallet/store/settings.dart';
import 'package:polka_wallet/utils/format.dart';
import 'package:polka_wallet/utils/i18n/index.dart';

class ContactList extends StatelessWidget {
  ContactList(this.store);

  final SettingsStore store;

  @override
  Widget build(BuildContext context) => Observer(
        builder: (_) {
          return Scaffold(
            appBar: AppBar(
              title: Text(I18n.of(context).profile['contact']),
              centerTitle: true,
            ),
            body: Padding(
              padding: EdgeInsets.only(top: 8, left: 8),
              child: SafeArea(
                child: ListView(
                  children: store.contactList.map((i) {
                    return ListTile(
                      leading: AddressIcon(address: i.address),
                      title: Text(i.name),
                      subtitle: Text(Fmt.address(i.address)),
                      trailing: Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () => Navigator.of(context).pop(i.address),
                    );
                  }).toList(),
                ),
              ),
            ),
          );
        },
      );
}
