import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:polka_wallet/common/components/TapTooltip.dart';
import 'package:polka_wallet/page/account/scanPage.dart';
import 'package:polka_wallet/service/substrateApi/api.dart';
import 'package:polka_wallet/common/components/roundedButton.dart';
import 'package:polka_wallet/store/account/types/accountData.dart';
import 'package:polka_wallet/store/app.dart';
import 'package:polka_wallet/utils/format.dart';
import 'package:polka_wallet/utils/i18n/index.dart';

class ContactPage extends StatefulWidget {
  ContactPage(this.store);

  static final String route = '/profile/contact';
  final AppStore store;

  @override
  _Contact createState() => _Contact(store);
}

class _Contact extends State<ContactPage> {
  _Contact(this.store);
  final AppStore store;

  final _formKey = GlobalKey<FormState>();

  final TextEditingController _addressCtrl = new TextEditingController();
  final TextEditingController _nameCtrl = new TextEditingController();
  final TextEditingController _memoCtrl = new TextEditingController();

  bool _isObservation = false;

  AccountData _args;

  bool _submitting = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    _args = ModalRoute.of(context).settings.arguments;
    if (_args != null) {
      _addressCtrl.text = _args.address;
      _nameCtrl.text = _args.name;
      _memoCtrl.text = _args.memo;
      _isObservation = _args.observation;
    }
  }

  Future<void> _onSave() async {
    if (_formKey.currentState.validate()) {
      setState(() {
        _submitting = true;
      });
      var dic = I18n.of(context).profile;
      String addr = _addressCtrl.text.trim();
      Map pubKeyAddress = await webApi.account.decodeAddress([addr]);
      String pubKey = pubKeyAddress.keys.toList()[0];
      Map<String, dynamic> con = {
        'address': addr,
        'name': _nameCtrl.text,
        'memo': _memoCtrl.text,
        'observation': _isObservation,
        'pubKey': pubKey,
      };
      setState(() {
        _submitting = false;
      });
      if (_args == null) {
        // create new contact
        int exist =
            store.settings.contactList.indexWhere((i) => i.address == addr);
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
          return;
        } else {
          store.settings.addContact(con);
        }
      } else {
        // edit contact
        store.settings.updateContact(con);
      }

      // get contact info
      if (_isObservation) {
        webApi.account.encodeAddress([pubKey]);
        webApi.account.getPubKeyIcons([pubKey]);
      } else {
        // if this address was used as observation and current account,
        // we need to change current account
        if (pubKey == store.account.currentAccountPubKey) {
          webApi.account.changeCurrentAccount(fetchData: true);
        }
      }
      webApi.account.getAddressIcons([addr]);
      Navigator.of(context).pop();
    }
  }

  @override
  void dispose() {
    _addressCtrl.dispose();
    _nameCtrl.dispose();
    _memoCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Map<String, String> dic = I18n.of(context).profile;
    List<Widget> action = <Widget>[
      IconButton(
        icon: Image.asset('assets/images/assets/Menu_scan.png'),
        onPressed: () async {
          final to = await Navigator.of(context).pushNamed(ScanPage.route);
          _addressCtrl.text = (to as QRCodeAddressResult).address;
        },
      )
    ];
    return Scaffold(
      appBar: AppBar(
        title: Text(dic['contact']),
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
                  padding: EdgeInsets.only(top: 8, bottom: 8),
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.only(left: 16, right: 16),
                      child: TextFormField(
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
                    ),
                    Padding(
                      padding: EdgeInsets.only(left: 16, right: 16),
                      child: TextFormField(
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
                    ),
                    Padding(
                      padding: EdgeInsets.only(left: 16, right: 16),
                      child: TextFormField(
                        decoration: InputDecoration(
                          hintText: dic['contact.memo'],
                          labelText: dic['contact.memo'],
                        ),
                        controller: _memoCtrl,
                      ),
                    ),
                    Row(
                      children: <Widget>[
                        Checkbox(
                          value: _isObservation,
                          onChanged: (v) {
                            setState(() {
                              _isObservation = v;
                            });
                          },
                        ),
                        GestureDetector(
                          child: Text(I18n.of(context).account['observe']),
                          onTap: () {
                            setState(() {
                              _isObservation = !_isObservation;
                            });
                          },
                        ),
                        TapTooltip(
                          child: Padding(
                            padding: EdgeInsets.only(left: 8),
                            child: Icon(Icons.info_outline, size: 16),
                          ),
                          message: I18n.of(context).account['observe.brief'],
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),
            Container(
              margin: EdgeInsets.all(16),
              child: RoundedButton(
                submitting: _submitting,
                text: dic['contact.save'],
                onPressed: () => _onSave(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
