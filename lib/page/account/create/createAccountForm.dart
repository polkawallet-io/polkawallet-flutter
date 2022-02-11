import 'package:encointer_wallet/common/components/gradientElements.dart';
import 'package:encointer_wallet/common/theme.dart';
import 'package:encointer_wallet/page/account/create/createPinPage.dart';
import 'package:encointer_wallet/store/app.dart';
import 'package:encointer_wallet/utils/translations/index.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:encointer_wallet/utils/translations/translations.dart';

class CreateAccountForm extends StatelessWidget {
  CreateAccountForm({this.store});
//todo get rid of the setNewAccount method where password is stored
  final AppStore store;

  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nameCtrl = new TextEditingController();

  @override
  Widget build(BuildContext context) {
    final Translations dic = I18n.of(context).translationsForLocale();

    return Form(
      key: _formKey,
      child: Column(
        children: <Widget>[
          SizedBox(height: 80),
          Expanded(
            child: ListView(
              padding: EdgeInsets.fromLTRB(16, 0, 16, 16),
              children: <Widget>[
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
                            color: encointerBlack,
                          ),
                    ),
                  ),
                ),
                SizedBox(height: 50),
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
          Container(
            key: Key('create-account-next'),
            padding: EdgeInsets.all(16),
            child: PrimaryButton(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Iconsax.login_1),
                  SizedBox(width: 12),
                  Text(
                    dic.account.next,
                    style: Theme.of(context).textTheme.headline3.copyWith(
                          color: encointerLightBlue,
                        ),
                  ),
                ],
              ),
              onPressed: () {
                if (_formKey.currentState.validate()) {
                  var args = {"name": '${_nameCtrl.text}'};
                  Navigator.pushNamed(context, CreatePinPage.route, arguments: args);
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
