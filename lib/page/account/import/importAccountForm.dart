import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:polka_wallet/common/components/roundedButton.dart';
import 'package:polka_wallet/service/substrateApi/api.dart';
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

  final List<String> _keyOptions = ['Mnemonic', 'Raw Seed', 'Keystore'];
  final List<String> _typeOptions = ['sr25519', 'ed25519'];

  int _keySelection = 0;
  int _typeSelection = 0;

  bool _expanded = false;
  String _derivePath = '';
  String _pathError;

  final _formKey = GlobalKey<FormState>();

  final TextEditingController _keyCtrl = new TextEditingController();
  final TextEditingController _nameCtrl = new TextEditingController();
  final TextEditingController _passCtrl = new TextEditingController();

  final TextEditingController _pathCtrl = new TextEditingController();

  String _checkDerivePath(String path) {
    String seed = _keyCtrl.text.trim();
    if (seed != "" && path != _derivePath) {
      webApi.account
          .checkDerivePath(seed, path, _typeOptions[_typeSelection])
          .then((res) {
        setState(() {
          _derivePath = path;
          _pathError = res != null ? 'Invalid derive path' : null;
        });
      });
    }
    return _pathError;
  }

  Widget _buildAdvancedOptions() {
    final dic = I18n.of(context).account;
    return Column(
      children: <Widget>[
        Padding(
          padding: EdgeInsets.only(top: 8),
          child: GestureDetector(
            child: Padding(
              padding: EdgeInsets.only(left: 8, top: 8),
              child: Row(
                children: <Widget>[
                  Icon(
                    _expanded ? Icons.arrow_drop_up : Icons.arrow_drop_down,
                    size: 30,
                    color: Theme.of(context).unselectedWidgetColor,
                  ),
                  Text(dic['advanced'])
                ],
              ),
            ),
            onTap: () {
              // clear state while advanced options closed
              if (_expanded) {
                setState(() {
                  _typeSelection = 0;
                  _pathCtrl.text = '';
                });
              }
              setState(() {
                _expanded = !_expanded;
              });
            },
          ),
        ),
        _expanded
            ? ListTile(
                title: Text(I18n.of(context).account['import.encrypt']),
                subtitle: Text(_typeOptions[_typeSelection]),
                trailing: Icon(Icons.arrow_forward_ios, size: 18),
                onTap: () {
                  showCupertinoModalPopup(
                    context: context,
                    builder: (_) => Container(
                      height: MediaQuery.of(context).copyWith().size.height / 3,
                      child: CupertinoPicker(
                        backgroundColor: Colors.white,
                        itemExtent: 56,
                        scrollController: FixedExtentScrollController(
                            initialItem: _typeSelection),
                        children: _typeOptions
                            .map((i) => Padding(
                                padding: EdgeInsets.all(16), child: Text(i)))
                            .toList(),
                        onSelectedItemChanged: (v) {
                          setState(() {
                            _typeSelection = v;
                          });
                        },
                      ),
                    ),
                  );
                },
              )
            : Container(),
        _expanded
            ? Padding(
                padding: EdgeInsets.fromLTRB(16, 0, 16, 0),
                child: TextFormField(
                  decoration: InputDecoration(
                    hintText: '//hard/soft///password',
                    labelText: dic['path'],
                  ),
                  controller: _pathCtrl,
                  validator: _checkDerivePath,
                ),
              )
            : Container(),
      ],
    );
  }

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

  @override
  Widget build(BuildContext context) {
    String validateInput(String v) {
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
            Map json = jsonDecode(input);
            passed = true;
            // auto set account name
            if (json['meta']['name'] != null) {
              setState(() {
                _nameCtrl.text = json['meta']['name'];
              });
            }
          } catch (_) {
            // ignore
          }
      }
      return passed
          ? null
          : '${dic['import.invalid']} ${_keyOptions[_keySelection]}';
    }

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
                  subtitle: Text(_keyOptions[_keySelection]),
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
                                  padding: EdgeInsets.all(16), child: Text(i)))
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
                      hintText: _keyOptions[_keySelection],
                      labelText: _keyOptions[_keySelection],
                    ),
                    controller: _keyCtrl,
                    maxLines: 2,
                    validator: validateInput,
                  ),
                ),
                _keySelection == 2
                    ? _buildNameAndPassInput()
                    : _buildAdvancedOptions(),
              ],
            ),
          ),
        ),
        Container(
          padding: EdgeInsets.all(16),
          child: RoundedButton(
            text: I18n.of(context).home['next'],
            onPressed: () {
              if (_formKey.currentState.validate()) {
                if (_keySelection == 2) {
                  accountStore.setNewAccount(
                      _nameCtrl.text.trim(), _passCtrl.text.trim());
                }
                accountStore.setNewAccountKey(_keyCtrl.text.trim());
                onSubmit({
                  'keyType': _keyOptions[_keySelection],
                  'cryptoType': _typeOptions[_typeSelection],
                  'derivePath': _pathCtrl.text.trim(),
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
