import 'package:encointer_wallet/common/components/accountSelectList.dart';
import 'package:encointer_wallet/page/profile/contacts/contactPage.dart';
import 'package:encointer_wallet/store/account/types/accountData.dart';
import 'package:encointer_wallet/store/app.dart';
import 'package:encointer_wallet/utils/translations/index.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';

class ContactListPage extends StatelessWidget {
  ContactListPage(this.store);

  static final String route = '/profile/contacts/list';
  final AppStore store;

  @override
  Widget build(BuildContext context) {
    final List<AccountData> args = ModalRoute.of(context).settings.arguments;
    return Scaffold(
      appBar: AppBar(
        title: Text(args == null
            ? I18n.of(context).translationsForLocale().profile.contact
            : I18n.of(context).translationsForLocale().account.list),
        centerTitle: true,
        actions: <Widget>[
          args == null
              ? Padding(
                  padding: EdgeInsets.only(right: 8),
                  child: IconButton(
                    icon: Icon(Icons.add, size: 28),
                    onPressed: () => Navigator.of(context).pushNamed(ContactPage.route),
                  ),
                )
              : Container()
        ],
      ),
      body: SafeArea(
        child: Observer(
          builder: (_) {
            return AccountSelectList(
              store,
              args ?? store.settings.contactListAll.toList(),
            );
          },
        ),
      ),
    );
  }
}
