import 'package:encointer_wallet/common/components/gradientElements.dart';
import 'package:encointer_wallet/common/theme.dart';
import 'package:encointer_wallet/page-encointer/common/communityChooserOnMap.dart';
import 'package:encointer_wallet/store/app.dart';
import 'package:encointer_wallet/utils/format.dart';
import 'package:encointer_wallet/utils/i18n/index.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CreatePinForm extends StatelessWidget {
  CreatePinForm({this.setNewAccount, this.submitting, this.onSubmit, this.name, this.store});
//todo get rid of the setNewAccount method where password is stored
  final Function setNewAccount;
  final Function onSubmit;
  final bool submitting;
  final AppStore store;
  final String name;

  final _formKey = GlobalKey<FormState>();

  final TextEditingController _passCtrl = new TextEditingController();
  final TextEditingController _pass2Ctrl = new TextEditingController();

  @override
  Widget build(BuildContext context) {
    final Map<String, String> dic = I18n.of(context).account;
    final Map<String, String> dicProf = I18n.of(context).profile;

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
                  child: Text(dicProf['pin.secure'], style: Theme.of(context).textTheme.headline2),
                ),
                SizedBox(height: 10),
                Center(
                  child: Container(
                    width: 250,
                    child: Text(
                      dicProf['pin.hint'],
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headline2.copyWith(
                            color: encointerBlack,
                          ),
                    ),
                  ),
                ),
                SizedBox(height: 30),
                TextFormField(
                  key: Key('create-account-pin'),
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    enabledBorder: const OutlineInputBorder(
                      // width: 0.0 produces a thin "hairline" border
                      borderSide: const BorderSide(color: Colors.transparent, width: 0.0),
                      borderRadius: BorderRadius.horizontal(left: Radius.circular(15), right: Radius.circular(15)),
                    ),
                    filled: true,
                    fillColor: encointerLightBlue,
                    hintText: dic['create.password'],
                    labelText: dic['create.password'],
                  ),
                  controller: _passCtrl,
                  validator: (v) {
                    return Fmt.checkPassword(v.trim()) ? null : dic['create.password.error'];
                  },
                  obscureText: true,
                  inputFormatters: <TextInputFormatter>[FilteringTextInputFormatter.digitsOnly],
                ),
                SizedBox(height: 20),
                TextFormField(
                  key: Key('create-account-pin2'),
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    enabledBorder: const OutlineInputBorder(
                      // width: 0.0 produces a thin "hairline" border
                      borderSide: const BorderSide(color: Colors.transparent, width: 0.0),
                      borderRadius: BorderRadius.horizontal(left: Radius.circular(15), right: Radius.circular(15)),
                    ),
                    filled: true,
                    //todo define color
                    fillColor: Color(0xffF4F8F9),
                    hintText: dic['create.password2'],
                    labelText: dic['create.password2'],
                  ),
                  controller: _pass2Ctrl,
                  obscureText: true,
                  validator: (v) {
                    return _passCtrl.text != v ? dic['create.password2.error'] : null;
                  },
                  inputFormatters: <TextInputFormatter>[FilteringTextInputFormatter.digitsOnly],
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.info_outlined),
                      SizedBox(width: 12),
                      Container(
                        width: 250,
                        child: Text(
                          dicProf['pin.info'],
                          style: Theme.of(context).textTheme.headline4.copyWith(
                                color: encointerGrey,
                              ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Container(
            key: Key('create-account-confirm'),
            padding: EdgeInsets.all(16),
            child: PrimaryButton(
              child: Text(
                I18n.of(context).account['create'],
                style: Theme.of(context).textTheme.headline3.copyWith(
                      color: encointerLightBlue,
                    ),
              ),
              onPressed: () {
                if (_formKey.currentState.validate()) {
                  if (store.account.accountListAll.isEmpty) {
                    setNewAccount(this.name.isNotEmpty ? this.name : dic['create.default'], _passCtrl.text);
                  } else {
                    // cachedPin won't be empty, because cachedPin is verified not to be empty before user adds an account in profile/index.dart
                    setNewAccount(this.name.isNotEmpty ? this.name : dic['create.default'], store.settings.cachedPin);
                  }

                  onSubmit();

                  // Even if we do not choose a community, we go back to the home screen.
                  Navigator.popUntil(context, ModalRoute.withName('/'));

                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => CommunityChooserOnMap(store)),
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
