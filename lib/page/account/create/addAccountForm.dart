import 'package:encointer_wallet/common/components/gradientElements.dart';
import 'package:encointer_wallet/common/theme.dart';
import 'package:encointer_wallet/page/account/import/importAccountPage.dart';
import 'package:encointer_wallet/store/app.dart';
import 'package:encointer_wallet/utils/translations/index.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:encointer_wallet/utils/translations/translations.dart';

class AddAccountForm extends StatelessWidget {
  AddAccountForm({this.isImporting, this.setNewAccount, this.submitting, this.onSubmit, this.store});
  final Function setNewAccount;
  final Function onSubmit;
  final bool submitting;
  final AppStore store;
  final bool isImporting;

  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nameCtrl = new TextEditingController();

  @override
  Widget build(BuildContext context) {
    final Translations dic = I18n.of(context).translationsForLocale();

    return Form(
      key: _formKey,
      child: Column(
        children: <Widget>[
          Expanded(
            child: ListView(
              padding: EdgeInsets.fromLTRB(16, 0, 16, 16),
              children: <Widget>[
                SizedBox(height: 80),
                Center(
                  child: Text(I18n.of(context).translationsForLocale().profile.accountNameChoose,
                      style: Theme.of(context).textTheme.headline2),
                ),
                SizedBox(height: 10),
                Center(
                  child: Container(
                    width: 300,
                    child: Text(
                      I18n.of(context).translationsForLocale().profile.accountNameChooseHint,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headline2.copyWith(
                            color: Colors.black,
                          ),
                    ),
                  ),
                ),
                SizedBox(height: 30),
                Column(
                  children: <Widget>[
                    TextFormField(
                      key: Key('create-account-name'),
                      decoration: InputDecoration(
                        enabledBorder: const OutlineInputBorder(
                          // width: 0.0 produces a thin "hairline" border
                          borderSide: const BorderSide(color: Colors.transparent, width: 0.0),
                          borderRadius: BorderRadius.horizontal(left: Radius.circular(15), right: Radius.circular(15)),
                        ),
                        filled: true,
                        fillColor: encointerLightBlue,
                        hintText: dic.account.createHint,
                        labelText: I18n.of(context).translationsForLocale().profile.accountName,
                      ),
                      controller: _nameCtrl,
                    ),
                  ],
                ),
              ],
            ),
          ),
          !isImporting
              ? Padding(
                  padding: EdgeInsets.fromLTRB(16, 0, 16, 0),
                  child: Container(
                    child: Center(
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(padding: EdgeInsets.symmetric(vertical: 16)),
                          key: Key('import-account'),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Iconsax.import_2),
                              SizedBox(width: 10),
                              Text(I18n.of(context).translationsForLocale().home.accountImport,
                                  style: Theme.of(context).textTheme.headline3),
                            ],
                          ),
                          onPressed: () {
                            Navigator.pushNamed(context, ImportAccountPage.route);
                          },
                        ),
                      ),
                    ),
                  ),
                )
              : Container(),
          Container(
            key: Key('create-account-confirm'),
            padding: EdgeInsets.all(16),
            child: PrimaryButton(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Iconsax.add_square),
                  SizedBox(width: 12),
                  Text(
                    I18n.of(context).translationsForLocale().profile.accountCreate,
                    style: Theme.of(context).textTheme.headline3.copyWith(
                          color: encointerLightBlue,
                        ),
                  ),
                ],
              ),
              onPressed: () {
                if (_formKey.currentState.validate()) {
                  setNewAccount(
                      _nameCtrl.text.isNotEmpty ? _nameCtrl.text : dic.account.createDefault, store.settings.cachedPin);
                  onSubmit();
                } else {
                  print("formKey.currentState.validate failed");
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
