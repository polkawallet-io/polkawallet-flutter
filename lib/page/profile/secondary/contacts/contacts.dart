import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:polka_wallet/store/settings.dart';
import 'package:polka_wallet/utils/format.dart';
import 'package:polka_wallet/utils/i18n/index.dart';

class Contacts extends StatelessWidget {
  Contacts(this.store);

  final SettingsStore store;

  void _showActions(BuildContext pageContext, ContactData i) {
    showCupertinoModalPopup(
      context: pageContext,
      builder: (BuildContext context) => CupertinoActionSheet(
        actions: <Widget>[
          CupertinoActionSheetAction(
            child: Text(
              I18n.of(context).home['edit'],
            ),
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pushNamed('/profile/contact', arguments: i);
            },
          ),
          CupertinoActionSheetAction(
            child: Text(
              I18n.of(context).home['delete'],
            ),
            onPressed: () {
              Navigator.of(context).pop();
              _removeItem(pageContext, i);
            },
          )
        ],
        cancelButton: CupertinoActionSheetAction(
          child: Text(I18n.of(context).home['cancel']),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
    );
  }

  void _removeItem(BuildContext context, ContactData i) {
    var dic = I18n.of(context).profile;
    showCupertinoDialog(
      context: context,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          content: Text(dic['contact.delete.warn']),
          actions: <Widget>[
            CupertinoButton(
              child: Text(I18n.of(context).home['cancel']),
              onPressed: () => Navigator.of(context).pop(),
            ),
            CupertinoButton(
              child: Text(I18n.of(context).home['ok']),
              onPressed: () {
                Navigator.of(context).pop();
                store.removeContact(i);
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
          List<Widget> ls = store.contactList.map((i) {
            return ListTile(
              leading: Image.asset('assets/images/assets/Assets_nav_0.png'),
              title: Text(i.name),
              subtitle: Text(Fmt.address(i.address)),
              trailing: IconButton(
                icon: Icon(Icons.more_vert),
                onPressed: () => _showActions(context, i),
              ),
            );
          }).toList();
          return Scaffold(
            appBar: AppBar(
              title: Text(I18n.of(context).profile['contact']),
              centerTitle: true,
              actions: <Widget>[
                Padding(
                  padding: EdgeInsets.only(right: 8),
                  child: IconButton(
                    icon: Icon(Icons.add),
                    onPressed: () =>
                        Navigator.of(context).pushNamed('/profile/contact'),
                  ),
                )
              ],
            ),
            body: Padding(
              padding: EdgeInsets.only(top: 8, left: 8),
              child: ListView(
                children: ls,
              ),
            ),
          );
        },
      );
}
