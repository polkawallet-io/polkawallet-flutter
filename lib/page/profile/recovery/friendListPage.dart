import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:polka_wallet/common/components/addressIcon.dart';
import 'package:polka_wallet/common/components/roundedButton.dart';
import 'package:polka_wallet/page/profile/contacts/contactPage.dart';
import 'package:polka_wallet/store/account/types/accountData.dart';
import 'package:polka_wallet/store/app.dart';
import 'package:polka_wallet/utils/format.dart';
import 'package:polka_wallet/utils/i18n/index.dart';

class FriendListPage extends StatefulWidget {
  FriendListPage(this.store);
  static final String route = '/profile/recovery/friends';
  final AppStore store;

  @override
  _FriendListPage createState() => _FriendListPage();
}

class _FriendListPage extends State<FriendListPage> {
  List<AccountData> _selected = [];

  void _onSwitch(AccountData acc, bool res) {
    Timer(Duration(milliseconds: 300), () {
      setState(() {
        setState(() {
          if (res) {
            _selected.add(acc);
          } else {
            _selected.removeWhere((i) => i.address == acc.address);
          }
        });
      });
    });
  }

  void _onFinish() {
    if (_selected.length > 9) {
      showCupertinoDialog(
        context: context,
        builder: (BuildContext context) {
          final Map dic = I18n.of(context).profile;
          return CupertinoAlertDialog(
            title: Container(),
            content: Text(dic['recovery.friends.max']),
            actions: <Widget>[
              CupertinoButton(
                child: Text(I18n.of(context).home['ok']),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    } else {
      Navigator.of(context).pop(_selected.toList());
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      var args = ModalRoute.of(context).settings.arguments;
      setState(() {
        _selected = args;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final Map dic = I18n.of(context).profile;
    return Scaffold(
      appBar: AppBar(
        title: Text(dic['recovery.friends']),
        centerTitle: true,
        actions: <Widget>[
          Padding(
            padding: EdgeInsets.only(right: 8),
            child: IconButton(
              icon: Icon(Icons.add, size: 28),
              onPressed: () =>
                  Navigator.of(context).pushNamed(ContactPage.route),
            ),
          )
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Observer(
              builder: (_) {
                List<AccountData> contacts =
                    widget.store.settings.contactList.toList();
                contacts.retainWhere((i) =>
                    _selected.indexWhere((e) => e.address == i.address) < 0);
                List<AccountData> list = List<AccountData>();
                list.addAll(_selected);
                list.addAll(contacts);
                return Expanded(
                  child: ListView.builder(
                    itemCount: list.length,
                    itemBuilder: (_, i) {
                      bool switchOn = i < _selected.length;
                      return ListTile(
                        leading: AddressIcon(list[i].address, size: 32),
                        title: Text(list[i].name),
                        subtitle: Text(Fmt.address(list[i].address)),
                        trailing: CupertinoSwitch(
                          value: switchOn,
                          onChanged: (res) => _onSwitch(list[i], res),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
            Padding(
              padding: EdgeInsets.all(16),
              child: RoundedButton(
                text: I18n.of(context).home['ok'],
                onPressed: _onFinish,
              ),
            )
          ],
        ),
      ),
    );
  }
}
