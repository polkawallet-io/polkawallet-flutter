import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:polka_wallet/store/settings.dart';
import 'package:polka_wallet/utils/format.dart';
import 'package:polka_wallet/utils/i18n/index.dart';

class Contacts extends StatelessWidget {
  Contacts(this.store);

  final SettingsStore store;

  Function _getMenuBuilder(BuildContext context) {
    return (BuildContext context) => <PopupMenuEntry<String>>[
          PopupMenuItem<String>(
            value: 'edit',
            child: Row(
              children: <Widget>[
                Icon(Icons.edit),
                Padding(
                  padding: EdgeInsets.only(left: 8),
                  child: Text(I18n.of(context).home['edit']),
                ),
              ],
            ),
          ),
          PopupMenuItem<String>(
            value: 'delete',
            child: Row(
              children: <Widget>[
                Icon(
                  Icons.delete,
                  color: Colors.pink,
                ),
                Padding(
                  padding: EdgeInsets.only(left: 8),
                  child: Text(
                    I18n.of(context).home['delete'],
                    style: TextStyle(color: Colors.pink),
                  ),
                ),
              ],
            ),
          ),
        ];
  }

  void _removeItem(BuildContext context, ContactData i) {
    var dic = I18n.of(context).profile;
    showCupertinoDialog(
      context: context,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: Text(dic['delete.confirm']),
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
              trailing: PopupMenuButton<String>(
                onSelected: (String result) {
                  if (result == 'edit') {
                    Navigator.of(context)
                        .pushNamed('/profile/contact', arguments: i);
                  } else {
                    _removeItem(context, i);
                  }
                },
                itemBuilder: _getMenuBuilder(context),
              ),
            );
          }).toList();
          return Scaffold(
            appBar: AppBar(
              title: Text(I18n.of(context).profile['contact']),
              actions: <Widget>[
                IconButton(
                  icon: Icon(Icons.add),
                  onPressed: () =>
                      Navigator.of(context).pushNamed('/profile/contact'),
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
