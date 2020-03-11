import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:polka_wallet/page/account/scanPage.dart';
import 'package:polka_wallet/service/substrateApi/api.dart';
import 'package:polka_wallet/common/components/roundedButton.dart';
import 'package:polka_wallet/store/settings.dart';
import 'package:polka_wallet/utils/format.dart';
import 'package:polka_wallet/utils/i18n/index.dart';

class ContactPage extends StatefulWidget {
  ContactPage(this.store);

  static final String route = '/profile/contact';
  final SettingsStore store;

  @override
  _Contact createState() => _Contact(store);
}

class _Contact extends State<ContactPage> {
  _Contact(this.store);
  final SettingsStore store;

  final _formKey = GlobalKey<FormState>();

  final TextEditingController _addressCtrl = new TextEditingController();
  final TextEditingController _nameCtrl = new TextEditingController();
  final TextEditingController _memoCtrl = new TextEditingController();

  ContactData _args;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    _args = ModalRoute.of(context).settings.arguments;
    if (_args != null) {
      _addressCtrl.text = _args.address;
      _nameCtrl.text = _args.name;
      _memoCtrl.text = _args.memo;
    }
  }

  void _onSave() {
    if (_formKey.currentState.validate()) {
      var dic = I18n.of(context).profile;
      String addr = _addressCtrl.text.trim();
      Map<String, dynamic> con = {
        'address': addr,
        'name': _nameCtrl.text,
        'memo': _memoCtrl.text
      };
      if (_args == null) {
        // create new contact
        int exist = store.contactList.indexWhere((i) => i.address == addr);
        if (exist > -1) {
          showCupertinoDialog(
            context: context,
            builder: (BuildContext context) {
              return CupertinoAlertDialog(
                title: Container(),
                content: Text(dic['contact.exist']),
                actions: <Widget>[
                  CupertinoButton(
                    child: Text(I18n.of(context).home['ok']),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              );
            },
          );
        } else {
          store.addContact(con);
          webApi.account.getAddressIcons([addr]);
          Navigator.of(context).pop();
        }
      } else {
        // edit contact
        store.updateContact(con);
        Navigator.of(context).pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    Map<String, String> dic = I18n.of(context).profile;
    List<Widget> action = <Widget>[
      IconButton(
        icon: Image.asset('assets/images/assets/Menu_scan.png'),
        onPressed: () async {
          var to = await Navigator.of(context).pushNamed(ScanPage.route);
          _addressCtrl.text = to;
        },
      )
    ];
    return Scaffold(
      appBar: AppBar(
        title: Text(I18n.of(context).profile['contact']),
        centerTitle: true,
        actions: _args == null ? action : null,
      ),
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Expanded(
              child: Form(
                key: _formKey,
                child: ListView(
                  padding: EdgeInsets.fromLTRB(16, 8, 16, 8),
                  children: <Widget>[
                    TextFormField(
                      decoration: InputDecoration(
                        hintText: dic['contact.address'],
                        labelText: dic['contact.address'],
                      ),
                      controller: _addressCtrl,
                      validator: (v) {
                        if (!Fmt.isAddress(v.trim())) {
                          return dic['contact.address.error'];
                        }
                        return null;
                      },
                      readOnly: _args != null,
                    ),
                    TextFormField(
                      decoration: InputDecoration(
                        hintText: dic['contact.name'],
                        labelText: dic['contact.name'],
                      ),
                      controller: _nameCtrl,
                      validator: (v) {
                        return v.trim().length > 0
                            ? null
                            : dic['contact.name.error'];
                      },
                    ),
                    TextFormField(
                      decoration: InputDecoration(
                        hintText: dic['contact.memo'],
                        labelText: dic['contact.memo'],
                      ),
                      controller: _memoCtrl,
                    ),
                  ],
                ),
              ),
            ),
            Container(
              margin: EdgeInsets.all(16),
              child: RoundedButton(
                text: dic['contact.save'],
                onPressed: _onSave,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
