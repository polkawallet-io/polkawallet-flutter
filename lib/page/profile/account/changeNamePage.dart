import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:polka_wallet/common/components/roundedButton.dart';
import 'package:polka_wallet/store/account/account.dart';
import 'package:polka_wallet/utils/i18n/index.dart';

class ChangeNamePage extends StatefulWidget {
  ChangeNamePage(this.store);
  static final String route = '/profile/name';
  final AccountStore store;

  @override
  _ChangeName createState() => _ChangeName(store);
}

class _ChangeName extends State<ChangeNamePage> {
  _ChangeName(this.store);

  final AccountStore store;

  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameCtrl = new TextEditingController();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _nameCtrl.text = store.currentAccount.name;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var dic = I18n.of(context).profile;
    return Scaffold(
      appBar: AppBar(
        title: Text(dic['name.change']),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Expanded(
              child: Form(
                key: _formKey,
                child: ListView(
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.fromLTRB(16, 8, 16, 8),
                      child: TextFormField(
                        decoration: InputDecoration(
                          hintText: dic['contact.name'],
                          labelText: dic['contact.name'],
                        ),
                        controller: _nameCtrl,
                        validator: (v) {
                          String name = v.trim();
                          if (name.length == 0) {
                            return dic['contact.name.error'];
                          }
                          int exist = store.optionalAccounts
                              .indexWhere((i) => i.name == name);
                          if (exist > -1) {
                            return dic['contact.name.exist'];
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Container(
              margin: EdgeInsets.all(16),
              child: RoundedButton(
                text: dic['contact.save'],
                onPressed: () {
                  if (_formKey.currentState.validate()) {
                    store.updateAccountName(_nameCtrl.text.trim());
                    Navigator.of(context).pop();
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
