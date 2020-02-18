import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:polka_wallet/service/api.dart';
import 'package:polka_wallet/store/account.dart';
import 'package:polka_wallet/utils/i18n/index.dart';

class ChangeName extends StatefulWidget {
  ChangeName(this.api, this.store);

  final Api api;
  final AccountStore store;

  @override
  _ChangeName createState() => _ChangeName(api, store);
}

class _ChangeName extends State<ChangeName> {
  _ChangeName(this.api, this.store);

  final Api api;
  final AccountStore store;

  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameCtrl = new TextEditingController();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    _nameCtrl.text = store.currentAccount.name;
  }

  @override
  Widget build(BuildContext context) {
    var dic = I18n.of(context).profile;
    return Scaffold(
      appBar: AppBar(
        title: Text(dic['name.change']),
        centerTitle: true,
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: Form(
              key: _formKey,
              child: ListView(
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.fromLTRB(24, 8, 24, 8),
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
          Row(
            children: <Widget>[
              Expanded(
                child: Container(
                  margin: EdgeInsets.fromLTRB(24, 8, 24, 24),
                  child: RaisedButton(
                    padding: EdgeInsets.all(16),
                    color: Colors.pink,
                    child: Text(
                      dic['contact.save'],
                      style: TextStyle(color: Colors.white),
                    ),
                    onPressed: () {
                      if (_formKey.currentState.validate()) {
                        store.updateAccountName(_nameCtrl.text);
                        Navigator.of(context).pop();
                      }
                    },
                  ),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}
