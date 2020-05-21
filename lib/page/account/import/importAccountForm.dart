import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:polka_wallet/common/components/accountAdvanceOption.dart';
import 'package:polka_wallet/common/components/roundedButton.dart';
import 'package:polka_wallet/store/account.dart';
import 'package:polka_wallet/utils/i18n/index.dart';

class ImportAccountForm extends StatefulWidget {
  const ImportAccountForm(this.accountStore, this.onSubmit);

  final AccountStore accountStore;
  final Function onSubmit;

  @override
  _ImportAccountFormState createState() =>
      _ImportAccountFormState(accountStore, onSubmit);
}

// TODO: add mnemonic word check & selection
class _ImportAccountFormState extends State<ImportAccountForm> {
  _ImportAccountFormState(this.accountStore, this.onSubmit);

  final AccountStore accountStore;
  final Function onSubmit;

  final List<String> _keyOptions = [
    AccountStore.seedTypeMnemonic,
    AccountStore.seedTypeRawSeed,
    AccountStore.seedTypeKeystore,
  ];

  int _keySelection = 0;

  final _formKey = GlobalKey<FormState>();

  final TextEditingController _keyCtrl = new TextEditingController();
  final TextEditingController _nameCtrl = new TextEditingController();
  final TextEditingController _passCtrl = new TextEditingController();

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
              hintText: dic['create.name'],
              labelText: dic['create.name'],
            ),
            controller: _nameCtrl,
            validator: (v) {
              return v.trim().length > 0 ? null : dic['create.name.error'];
            },
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
                icon: Icon(
                  CupertinoIcons.clear_thick_circled,
                  color: Theme.of(context).unselectedWidgetColor,
                ),
                onPressed: () {
                  WidgetsBinding.instance
                      .addPostFrameCallback((_) => _passCtrl.clear());
                },
              ),
            ),
            controller: _passCtrl,
            obscureText: true,
            validator: (v) {
              return v.trim().length > 0 ? null : dic['create.password.error'];
            },
          ),
        ),
      ],
    );
  }

  String _validateInput(String v) {
    bool passed = false;
    Map<String, String> dic = I18n.of(context).account;
    String input = v.trim();
    switch (_keySelection) {
      case 0:
        int len = input.split(' ').length;
        if (len == 12 || len == 24) {
          passed = true;
        }
        break;
      case 1:
        if (input.length <= 32 || input.length == 66) {
          passed = true;
        }
        break;
      case 2:
        try {
          jsonDecode(input);
          passed = true;
        } catch (_) {
          // ignore
        }
    }
    return passed
        ? null
        : '${dic['import.invalid']} ${dic[_keyOptions[_keySelection]]}';
  }

  void _onKeyChange(String v) {
    if (_keySelection == 2) {
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Map<String, String> dic = I18n.of(context).account;
    String selected = dic[_keyOptions[_keySelection]];
    return Column(
      children: <Widget>[
        Expanded(
          child: Form(
            key: _formKey,
            autovalidate: true,
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
                        height:
                            MediaQuery.of(context).copyWith().size.height / 3,
                        child: CupertinoPicker(
                          backgroundColor: Colors.white,
                          itemExtent: 56,
                          scrollController: FixedExtentScrollController(
                              initialItem: _keySelection),
                          children: _keyOptions
                              .map((i) => Padding(
                                  padding: EdgeInsets.all(12),
                                  child: Text(dic[i])))
                              .toList(),
                          onSelectedItemChanged: (v) {
                            setState(() {
                              _keyCtrl.value = TextEditingValue(text: '');
                              _keySelection = v;
                            });
                          },
                        ),
                      ),
                    );
                  },
                ),
                Padding(
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
                ),
                _keySelection == 2
                    ? _buildNameAndPassInput()
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
          padding: EdgeInsets.all(16),
          child: RoundedButton(
            text: I18n.of(context).home['next'],
            onPressed: () async {
              if (_formKey.currentState.validate() &&
                  !(_advanceOptions.error ?? false)) {
                if (_keySelection == 2) {
                  accountStore.setNewAccount(
                      _nameCtrl.text.trim(), _passCtrl.text.trim());
                }
                accountStore.setNewAccountKey(_keyCtrl.text.trim());
                onSubmit({
                  'keyType': _keyOptions[_keySelection],
                  'cryptoType': _advanceOptions.type ??
                      AccountAdvanceOptionParams.encryptTypeSR,
                  'derivePath': _advanceOptions.path ?? '',
                  'finish': _keySelection == 2 ? true : null,
                });
              }
            },
          ),
        ),
      ],
    );
  }
}
