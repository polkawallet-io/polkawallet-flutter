import 'package:encointer_wallet/common/components/addressIcon.dart';
import 'package:encointer_wallet/page/profile/contacts/contactPage.dart';
import 'package:encointer_wallet/service/substrateApi/api.dart';
import 'package:encointer_wallet/store/account/types/accountData.dart';
import 'package:encointer_wallet/store/app.dart';
import 'package:encointer_wallet/utils/format.dart';
import 'package:encointer_wallet/utils/translations/index.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:encointer_wallet/utils/translations/translations.dart';

class ContactsPage extends StatelessWidget {
  ContactsPage(this.store);

  static final String route = '/profile/contacts';
  final AppStore store;

  void _showActions(BuildContext pageContext, AccountData i) {
    showCupertinoModalPopup(
      context: pageContext,
      builder: (BuildContext context) => CupertinoActionSheet(
        actions: <Widget>[
          CupertinoActionSheetAction(
            child: Text(
              I18n.of(context).translationsForLocale().home.edit,
            ),
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pushNamed(ContactPage.route, arguments: i);
            },
          ),
          CupertinoActionSheetAction(
            child: Text(
              I18n.of(context).translationsForLocale().home.delete,
            ),
            onPressed: () {
              Navigator.of(context).pop();
              _removeItem(pageContext, i);
            },
          )
        ],
        cancelButton: CupertinoActionSheetAction(
          child: Text(I18n.of(context).translationsForLocale().home.cancel),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
    );
  }

  void _removeItem(BuildContext context, AccountData i) {
    final Translations dic = I18n.of(context).translationsForLocale();
    showCupertinoDialog(
      context: context,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: Text(dic.profile.contactDeleteWarn),
          content: Text(Fmt.accountName(context, i)),
          actions: <Widget>[
            CupertinoButton(
              child: Text(I18n.of(context).translationsForLocale().home.cancel),
              onPressed: () => Navigator.of(context).pop(),
            ),
            CupertinoButton(
              child: Text(I18n.of(context).translationsForLocale().home.ok),
              onPressed: () {
                Navigator.of(context).pop();
                store.settings.removeContact(i);
                if (i.pubKey == store.account.currentAccountPubKey) {
                  webApi.account.changeCurrentAccount(fetchData: true);
                }
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) => Observer(
        builder: (_) {
          return Scaffold(
            appBar: AppBar(
              title: Text(I18n.of(context).translationsForLocale().profile.contact),
              centerTitle: true,
              actions: <Widget>[
                Padding(
                  padding: EdgeInsets.only(right: 8),
                  child: IconButton(
                    icon: Icon(Icons.add, size: 28),
                    onPressed: () => Navigator.of(context).pushNamed(ContactPage.route),
                  ),
                )
              ],
            ),
            body: SafeArea(
              child: ListView(
                children: store.settings.contactList.map((i) {
                  return ListTile(
                    leading: AddressIcon(i.address),
                    title: Text(Fmt.accountName(context, i)),
                    subtitle: Text(Fmt.address(i.address)),
                    trailing: Container(
                      width: 36,
                      child: IconButton(
                        icon: Icon(Icons.more_vert),
                        onPressed: () => _showActions(context, i),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          );
        },
      );
}
