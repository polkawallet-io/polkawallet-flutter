import 'package:encointer_wallet/common/components/accountAdvanceOption.dart';
import 'package:encointer_wallet/common/components/gradientElements.dart';
import 'package:encointer_wallet/service/substrateApi/api.dart';
import 'package:encointer_wallet/store/account/account.dart';
import 'package:encointer_wallet/store/app.dart';
import 'package:encointer_wallet/utils/translations/index.dart';
import 'package:encointer_wallet/utils/translations/translations.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

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

  AccountAdvanceOptionParams _advanceOptions = AccountAdvanceOptionParams();

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

    final Translations dic = I18n.of(context).translationsForLocale();
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
    } else {
      // should this also be done in addAccountForm & createPinForm? probably..
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

  String _validateInput(String v, Map<KeySelection, String> translationsByKeySelection) {
    bool passed = false;
    final Translations dic = I18n.of(context).translationsForLocale();
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
      case KeySelection.OBSERVATION:
        break;
    }
    return passed ? null : '${dic.account.importInvalid} ${translationsByKeySelection[_keySelection]}'; // TODO armin
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
    final Translations dic = I18n.of(context).translationsForLocale();
    final Map<KeySelection, String> translationsByKeySelection = {
      KeySelection.MNEMONIC: dic.account.mnemonic,
      KeySelection.RAW_SEED: dic.account.rawSeed,
      KeySelection.OBSERVATION: dic.account.observe,
    };
    final Map<String, String> translationsByKeyOption = {
      _keyOptions[0]: dic.account.mnemonic,
      _keyOptions[1]: dic.account.rawSeed,
      _keyOptions[2]: dic.account.observe,
    };
    String selected = translationsByKeySelection[_keySelection];
    return Column(
      children: <Widget>[
        Expanded(
          child: Form(
            key: _formKey,
//            autovalidate: true,
            child: ListView(
              children: <Widget>[
                ListTile(
                  title: Text(I18n.of(context).translationsForLocale().home.accountImport),
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
                              .map((i) => Padding(
                                  padding: EdgeInsets.all(12), child: Text(translationsByKeyOption[i]))) // TODO armin
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
                          validator: (String value) => _validateInput(value, translationsByKeySelection),
                        ),
                      )
                    : Container(),
              ],
            ),
          ),
        ),
        Container(
          key: Key('account-import-next'),
          padding: EdgeInsets.all(16),
          child: PrimaryButton(
            child: Text(I18n.of(context).translationsForLocale().home.next),
            onPressed: () async {
              if (_formKey.currentState.validate() && !(_advanceOptions.error ?? false)) {
                if (_keySelection == KeySelection.OBSERVATION) {
                  _onAddObservationAccount();
                  return;
                }
                widget.store.account.setNewAccountKey(_keyCtrl.text.trim());
                widget.onSubmit({
                  'keyType': _keyOptions[_keySelection.index],
                  'cryptoType': _advanceOptions.type ?? AccountAdvanceOptionParams.encryptTypeSR,
                  'derivePath': _advanceOptions.path ?? '',
                  'finish': null, // TODO chrigi check obsolete code KeyStoreJson
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
  OBSERVATION,
}
