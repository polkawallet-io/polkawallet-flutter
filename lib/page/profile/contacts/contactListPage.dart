import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:polka_wallet/common/components/accountSelectList.dart';
import 'package:polka_wallet/store/settings.dart';
import 'package:polka_wallet/utils/i18n/index.dart';

class ContactListPage extends StatelessWidget {
  ContactListPage(this.store);

  static final String route = '/profile/contacts/list';
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
                child: AccountSelectList(store.contactList.toList()),
              ),
            ),
          );
        },
      );
}
