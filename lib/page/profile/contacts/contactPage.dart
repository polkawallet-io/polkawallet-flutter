import 'package:encointer_wallet/common/components/TapTooltip.dart';
import 'package:encointer_wallet/common/components/roundedButton.dart';
import 'package:encointer_wallet/service/qrScanService.dart';
import 'package:encointer_wallet/service/substrateApi/api.dart';
import 'package:encointer_wallet/store/app.dart';
import 'package:encointer_wallet/utils/format.dart';
import 'package:encointer_wallet/utils/translations/index.dart';
import 'package:encointer_wallet/utils/translations/translations.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

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

  QrScanData qrScanData;

  bool _submitting = false;

  Future<void> _onSave() async {
    if (_formKey.currentState.validate()) {
      setState(() {
        _submitting = true;
      });
      final Translations dic = I18n.of(context).translationsForLocale();
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
      if (qrScanData == null) {
        // create new contact
        int exist = store.settings.contactList.indexWhere((i) => i.address == addr);
        if (exist > -1) {
          showCupertinoDialog(
            context: context,
            builder: (BuildContext context) {
              return CupertinoAlertDialog(
                title: Container(),
                content: Text(dic.profile.contactAlreadyExists),
                actions: <Widget>[
                  CupertinoButton(
                    child: Text(I18n.of(context).translationsForLocale().home.ok),
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
    QrScanData qrScanData = ModalRoute.of(context).settings.arguments;
    final Translations dic = I18n.of(context).translationsForLocale();
    if (qrScanData != null) {
      _addressCtrl.text = qrScanData.account;
      _nameCtrl.text = qrScanData.label;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(dic.profile.addressBook),
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
                          hintText: dic.profile.contactAddress,
                          labelText: dic.profile.contactAddress,
                        ),
                        controller: _addressCtrl,
                        validator: (v) {
                          if (!Fmt.isAddress(v.trim())) {
                            return dic.profile.contactAddressError;
                          }
                          return null;
                        },
                        readOnly: qrScanData != null,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(left: 16, right: 16),
                      child: TextFormField(
                        decoration: InputDecoration(
                          hintText: dic.profile.contactName,
                          labelText: dic.profile.contactName,
                        ),
                        controller: _nameCtrl,
                        validator: (v) {
                          return v.trim().length > 0 ? null : dic.profile.contactNameError;
                        },
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(left: 16, right: 16),
                      child: TextFormField(
                        decoration: InputDecoration(
                          hintText: dic.profile.contactMemo,
                          labelText: dic.profile.contactMemo,
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
                          child: Text(I18n.of(context).translationsForLocale().account.observe),
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
                          message: I18n.of(context).translationsForLocale().account.observeBrief,
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
                text: dic.profile.contactSave,
                onPressed: () => _onSave(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
