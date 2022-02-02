import 'dart:convert';

import 'package:encointer_wallet/common/components/accountAdvanceOption.dart';
import 'package:encointer_wallet/page/account/scanPage.dart';
import 'package:encointer_wallet/service/substrateApi/api.dart';
import 'package:encointer_wallet/store/account/account.dart';
import 'package:encointer_wallet/store/app.dart';
import 'package:encointer_wallet/utils/format.dart';
import 'package:encointer_wallet/utils/i18n/index.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:encointer_wallet/common/components/gradientElements.dart';

class ImportAccountForm extends StatefulWidget {
  const ImportAccountForm(this.store, this.onSubmit);

  final AppStore store;
  final Function onSubmit;

  @override
  _ImportAccountFormState createState() => _ImportAccountFormState();
}

// TODO: add mnemonic word check & selection
class _ImportAccountFormState extends State<ImportAccountForm> {
  final List<String> _keyOptions = [
    AccountStore.seedTypeMnemonic,
    AccountStore.seedTypeRawSeed,
    AccountStore.seedTypeKeystore,
    'observe',
  ];

  KeySelection _keySelection = KeySelection.MNEMONIC;

  final _formKey = GlobalKey<FormState>();

  final TextEditingController _keyCtrl = new TextEditingController();
  final TextEditingController _nameCtrl = new TextEditingController();
  final TextEditingController _passCtrl = new TextEditingController();

  final TextEditingController _observationAddressCtrl = new TextEditingController();
  final TextEditingController _observationNameCtrl = new TextEditingController();
  final TextEditingController _memoCtrl = new TextEditingController();

  String _keyCtrlText = '';
  AccountAdvanceOptionParams _advanceOptions = AccountAdvanceOptionParams();

  Widget _buildNameAndPassInput() {
    final Map<String, String> dic = I18n.of(context).account;
    return Column(
      children: <Widget>[
        Padding(
          padding: EdgeInsets.only(left: 16, right: 16),
          child: TextFormField(
            decoration: InputDecoration(
              hintText: dic['create.hint'],
              labelText: "${dic['create.name']}: ${dic['create.hint']}",
            ),
            controller: _nameCtrl,
          ),
        ),
        Padding(
          padding: EdgeInsets.only(left: 16, right: 16),
          child: TextFormField(
            decoration: InputDecoration(
              hintText: dic['create.password'],
              labelText: dic['create.password'],
              suffixIcon: IconButton(
                iconSize: 18,
                icon: Icon(CupertinoIcons.clear_thick_circled, color: Theme.of(context).unselectedWidgetColor),
                onPressed: () {
                  WidgetsBinding.instance.addPostFrameCallback((_) => _passCtrl.clear());
                },
              ),
            ),
            controller: _passCtrl,
            obscureText: true,
            validator: (v) {
              // TODO: fix me: disable validator for polkawallet-RN exported keystore importing
              return null;
              // return v.trim().length > 0 ? null : dic['create.password.error'];
            },
          ),
        ),
      ],
    );
  }

  Widget _buildAddressAndNameInput() {
    final Map<String, String> dic = I18n.of(context).profile;
    return Column(
      children: <Widget>[
        Padding(
          padding: EdgeInsets.only(left: 16, right: 16),
          child: TextFormField(
            decoration: InputDecoration(
              hintText: dic['contact.address'],
              labelText: dic['contact.address'],
              suffix: GestureDetector(
                child: Icon(Icons.camera_alt),
                onTap: () async {
                  final acc = (await Navigator.of(context).pushNamed(ScanPage.route)) as QRCodeAddressResult;
                  if (acc != null) {
                    setState(() {
                      _observationAddressCtrl.text = acc.address;
                      _observationNameCtrl.text = acc.name;
                    });
                  }
                },
              ),
            ),
            controller: _observationAddressCtrl,
            validator: (v) {
              if (!Fmt.isAddress(v.trim())) {
                return dic['contact.address.error'];
              }
              return null;
            },
          ),
        ),
        Padding(
          padding: EdgeInsets.only(left: 16, right: 16),
          child: TextFormField(
            decoration: InputDecoration(
              hintText: dic['contact.name'],
              labelText: dic['contact.name'],
            ),
            controller: _observationNameCtrl,
            validator: (v) {
              return v.trim().length > 0 ? null : dic['contact.name.error'];
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
      ],
    );
  }

  Future<void> _onAddObservationAccount() async {
    setState(() {});
    showCupertinoDialog(
      context: context,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: Container(),
          content: Container(height: 64, child: CupertinoActivityIndicator()),
        );
      },
    );

    var dic = I18n.of(context).profile;
    String address = _observationAddressCtrl.text.trim();
    Map pubKeyAddress = await webApi.account.decodeAddress([address]);
    String pubKey = pubKeyAddress.keys.toList()[0];
    Map<String, dynamic> acc = {
      'address': address,
      'name': _observationNameCtrl.text,
      'memo': _memoCtrl.text,
      'observation': true,
      'pubKey': pubKey,
    };
    // create new contact
    int exist = widget.store.settings.contactList.indexWhere((i) => i.address == address);
    if (exist > -1) {
      setState(() {});
      Navigator.of(context).pop();

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
      await widget.store.settings.addContact(acc);

      webApi.account.changeCurrentAccount(pubKey: pubKey);
      webApi.assets.fetchBalance();
      webApi.account.encodeAddress([pubKey]);
      webApi.account.getPubKeyIcons([pubKey]);
      setState(() {});
      // go to home page
      Navigator.popUntil(context, ModalRoute.withName('/'));
    }
  }

  String _validateInput(String v) {
    bool passed = false;
    Map<String, String> dic = I18n.of(context).account;
    String input = v.trim();
    switch (_keySelection) {
      case KeySelection.MNEMONIC:
        int len = input.split(' ').length;
        if (len == 12 || len == 24) {
          passed = true;
        }
        break;
      case KeySelection.RAW_SEED:
        if (input.length <= 32 || input.length == 66) {
          passed = true;
        }
        break;
      case KeySelection.KEYSTORE_JSON:
        try {
          jsonDecode(input);
          passed = true;
        } catch (_) {
          // ignore
        }
        break;
      case KeySelection.OBSERVATION:
        break;
    }
    return passed ? null : '${dic['import.invalid']} ${dic[_keyOptions[_keySelection.index]]}';
  }

  void _onKeyChange(String v) {
    if (_keySelection == KeySelection.KEYSTORE_JSON) {
      // auto set account name
      var json = jsonDecode(v.trim());
      if (json['meta']['name'] != null) {
        setState(() {
          _nameCtrl.value = TextEditingValue(text: json['meta']['name']);
        });
      }
    }
    setState(() {
      _keyCtrlText = v.trim();
    });
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _passCtrl.dispose();
    _keyCtrl.dispose();
    _observationAddressCtrl.dispose();
    _observationNameCtrl.dispose();
    _memoCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Map<String, String> dic = I18n.of(context).account;
    String selected = dic[_keyOptions[_keySelection.index]];
    return Column(
      children: <Widget>[
        Expanded(
          child: Form(
            key: _formKey,
//            autovalidate: true,
            child: ListView(
              children: <Widget>[
                ListTile(
                  title: Text(I18n.of(context).account['import.type']),
                  subtitle: Text(selected),
                  trailing: Icon(Icons.arrow_forward_ios, size: 18),
                  onTap: () {
                    showCupertinoModalPopup(
                      context: context,
                      builder: (_) => Container(
                        height: MediaQuery.of(context).copyWith().size.height / 3,
                        child: CupertinoPicker(
                          backgroundColor: Colors.white,
                          itemExtent: 56,
                          scrollController: FixedExtentScrollController(initialItem: _keySelection.index),
                          children: _keyOptions
                              .map((i) => Padding(padding: EdgeInsets.all(12), child: Text(dic[i])))
                              .toList(),
                          onSelectedItemChanged: (v) {
                            setState(() {
                              _keyCtrl.value = TextEditingValue(text: '');
                              _keySelection = KeySelection.values[v];
                            });
                          },
                        ),
                      ),
                    );
                  },
                ),
                _keySelection != KeySelection.OBSERVATION
                    ? Padding(
                        key: Key('account-source'),
                        padding: EdgeInsets.only(left: 16, right: 16),
                        child: TextFormField(
                          decoration: InputDecoration(
                            hintText: selected,
                            labelText: selected,
                          ),
                          controller: _keyCtrl,
                          maxLines: 2,
                          validator: _validateInput,
                          onChanged: _onKeyChange,
                        ),
                      )
                    : Container(),
                _keySelection == KeySelection.KEYSTORE_JSON
                    ? _buildNameAndPassInput()
                    : _keySelection == KeySelection.OBSERVATION
                        ? _buildAddressAndNameInput()
                        : AccountAdvanceOption(
                            seed: _keyCtrlText,
                            onChange: (data) {
                              setState(() {
                                _advanceOptions = data;
                              });
                            },
                          ),
              ],
            ),
          ),
        ),
        Container(
          key: Key('account-import-next'),
          padding: EdgeInsets.all(16),
          child: PrimaryButton(
            child: Text(I18n.of(context).home['next']),
            onPressed: () async {
              if (_formKey.currentState.validate() && !(_advanceOptions.error ?? false)) {
                if (_keySelection == KeySelection.OBSERVATION) {
                  _onAddObservationAccount();
                  return;
                }
                if (_keySelection == KeySelection.KEYSTORE_JSON) {
                  widget.store.account.setNewAccount(
                      _nameCtrl.text.isNotEmpty ? _nameCtrl.text.trim() : dic['create.default'], _passCtrl.text.trim());
                }
                widget.store.account.setNewAccountKey(_keyCtrl.text.trim());
                widget.onSubmit({
                  'keyType': _keyOptions[_keySelection.index],
                  'cryptoType': _advanceOptions.type ?? AccountAdvanceOptionParams.encryptTypeSR,
                  'derivePath': _advanceOptions.path ?? '',
                  'finish': _keySelection == KeySelection.KEYSTORE_JSON ? true : null,
                });
              }
            },
          ),
        ),
      ],
    );
  }
}

enum KeySelection {
  MNEMONIC,
  RAW_SEED,
  KEYSTORE_JSON,
  OBSERVATION,
}
