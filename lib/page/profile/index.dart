import 'package:encointer_wallet/common/components/addressIcon.dart';
import 'package:encointer_wallet/common/components/passwordInputDialog.dart';
import 'package:encointer_wallet/common/theme.dart';
import 'package:encointer_wallet/page/account/create/addAccountPage.dart';
import 'package:encointer_wallet/page/profile/aboutPage.dart';
import 'package:encointer_wallet/page/profile/account/accountManagePage.dart';
import 'package:encointer_wallet/page/profile/account/changePasswordPage.dart';
import 'package:encointer_wallet/service/substrateApi/api.dart';
import 'package:encointer_wallet/store/account/types/accountData.dart';
import 'package:encointer_wallet/store/app.dart';
import 'package:encointer_wallet/store/settings.dart';
import 'package:encointer_wallet/utils/format.dart';
import 'package:encointer_wallet/utils/translations/index.dart';
import 'package:encointer_wallet/utils/translations/translations.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:iconsax/iconsax.dart';

class Profile extends StatefulWidget {
  Profile(this.store);

  final AppStore store;

  @override
  _ProfileState createState() => _ProfileState(store);
}

class _ProfileState extends State<Profile> {
  _ProfileState(this.store);

  final AppStore store;
  final Api api = webApi;
  EndpointData _selectedNetwork;

  Future<void> _onSelect(AccountData i, String address) async {
    if (address != store.account.currentAddress) {
      print("changing from addres ${store.account.currentAddress} to $address");

      store.account.setCurrentAccount(i.pubKey);
      await store.loadAccountCache();

      webApi.fetchAccountData();
    }
  }

  Future<void> _onAddAccount() async {
    var arg = {'isImporting': false};
    Navigator.of(context).pushNamed(AddAccountPage.route, arguments: arg);
  }

  // What type is a reputations? is it a string?
  // Future<void> _getReputations() async {
  //   await webApi.encointer.getReputations();
  // }

  Future<void> _showPasswordDialog(BuildContext context) async {
    await showCupertinoDialog(
      context: context,
      builder: (_) {
        return Container(
          child: showPasswordInputDialog(
            context,
            store.account.currentAccount,
            Text(I18n.of(context).translationsForLocale().profile.unlock),
            (password) {
              setState(() {
                store.settings.setPin(password);
              });
            },
          ),
        );
      },
    );
  }

  List<Widget> _buildAccountList() {
    List<Widget> res = [];

    List<AccountData> accounts = store.account.accountListAll;

    res.addAll(accounts.map((i) {
      String address = i.address;
      if (store.account.pubKeyAddressMap[_selectedNetwork.ss58] != null) {
        address = store.account.pubKeyAddressMap[_selectedNetwork.ss58][i.pubKey];
      }
      return InkWell(
        child: Column(
          children: [
            Stack(
              children: [
                AddressIcon(
                  '',
                  size: 70,
                  pubKey: i.pubKey,
                  // addressToCopy: address,
                  tapToCopy: false,
                ),
                Positioned(
                  bottom: 0, right: 0, //give the values according to your requirement
                  child: Icon(Iconsax.edit, color: encointerBlue),
                ),
              ],
            ),
            SizedBox(height: 6),
            Text(
              Fmt.accountName(context, i),
              style: Theme.of(context).textTheme.headline4,
            ),
            // This sizedBox is here to define a distance between the accounts
            SizedBox(width: 100),
          ],
        ),
        onTap: () => {
          _onSelect(i, address),
          Navigator.pushNamed(context, AccountManagePage.route),
        },
      );
    }).toList());
    return res;
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var h3Grey = Theme.of(context).textTheme.headline3.copyWith(color: encointerGrey);
    _selectedNetwork = store.settings.endpoint;

    // if all accounts are deleted, go to createAccountPage
    if (store.account.accountListAll.isEmpty) {
      store.settings.setPin('');
      Future.delayed(Duration.zero, () {
        Navigator.popUntil(context, ModalRoute.withName('/'));
      });
    }
    final Translations dic = I18n.of(context).translationsForLocale();

    return Observer(
      builder: (_) {
        return Scaffold(
          appBar: AppBar(
            title: Text(dic.profile.title),
            iconTheme: IconThemeData(color: encointerGrey), //change your color here,
            centerTitle: true,
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
          ),
          body: Observer(
            builder: (_) {
              if (_selectedNetwork == null) return Container();
              return ListView(
                children: <Widget>[
                  Container(
                    padding: EdgeInsets.all(16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text(
                          '${dic.profile.accounts}',
                          style: Theme.of(context).textTheme.headline2.copyWith(color: encointerBlack),
                        ),
                        IconButton(
                            icon: Icon(Iconsax.add_square),
                            color: encointerBlue,
                            onPressed: () {
                              store.settings.cachedPin.isEmpty ? _showPasswordDialog(context) : _onAddAccount();
                            }),
                      ],
                    ),
                  ),
                  Container(
                    height: 130,
                    child: ShaderMask(
                      shaderCallback: (Rect bounds) {
                        return LinearGradient(
                          begin: Alignment.centerRight,
                          end: Alignment.centerLeft,
                          colors: [
                            Theme.of(context).scaffoldBackgroundColor.withOpacity(0.0),
                            Theme.of(context).scaffoldBackgroundColor,
                            Theme.of(context).scaffoldBackgroundColor,
                            Theme.of(context).scaffoldBackgroundColor.withOpacity(0.0),
                          ],
                          stops: [0.0, 0.1, 0.9, 1.0],
                        ).createShader(bounds);
                      },
                      child: ListView(
                        children: _buildAccountList(),
                        scrollDirection: Axis.horizontal,
                      ),
                      // blendMode: BlendMode.dstATop,
                    ),
                  ),
                  ListTile(
                    title: Text(
                      dic.profile.passChange,
                      style: Theme.of(context).textTheme.headline3,
                    ),
                    trailing: Icon(Icons.arrow_forward_ios, size: 18),
                    onTap: () => Navigator.pushNamed(context, ChangePasswordPage.route),
                  ),
                  ListTile(
                    // Todo: Remove all accounts is buggy: #318
                    title: Text("Remove all Accounts"),
                    onTap: () => showCupertinoDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return CupertinoAlertDialog(title: Text("Are you sure you want to remove all accounts?"),
                              // content: Text(dic.profile.passErrorTxt),
                              actions: <Widget>[
                                CupertinoButton(
                                  // key: Key('error-dialog-ok'),
                                  child: Text(I18n.of(context).translationsForLocale().home.cancel),
                                  onPressed: () => Navigator.of(context).pop(),
                                ),
                                CupertinoButton(
                                    // key: Key('error-dialog-ok'),
                                    child: Text(I18n.of(context).translationsForLocale().home.ok),
                                    onPressed: () => {
                                          print("remove ${store.account.accountListAll}"),
                                          store.account.accountListAll.forEach((acc) {
                                            print("removing the account: $acc");
                                            store.account.removeAccount(acc);
                                          }),
                                          Navigator.popUntil(context, ModalRoute.withName('/')),
                                        }),
                              ]);
                        }),
                  ),
                  ListTile(
                    title: Text(dic.profile.reputationOverall, style: h3Grey),
                  ),
                  ListTile(
                    title: Text(dic.profile.reputationHistory, style: h3Grey),
                  ),
                  ListTile(
                    title: Text(dic.profile.about, style: Theme.of(context).textTheme.headline3),
                    trailing: Icon(Icons.arrow_forward_ios, size: 18),
                    onTap: () => Navigator.pushNamed(context, AboutPage.route),
                  ),
                  ListTile(
                    title: Text(dic.profile.developer, style: h3Grey),
                    trailing: Checkbox(
                      value: store.settings.developerMode,
                      onChanged: (_) => store.settings.toggleDeveloperMode(),
                    ),
                  ),
                  if (store.settings.developerMode)
                    // Column in case we add more developer options
                    Column(
                      children: <Widget>[
                        ListTile(
                          title: InkWell(
                            key: Key('choose-network'),
                            child: Observer(
                              builder: (_) => Text(
                                "Change network (current: ${store.settings.endpoint.info})",
                                style: Theme.of(context).textTheme.headline4,
                              ),
                            ),
                            onTap: () => Navigator.of(context).pushNamed('/network'),
                          ),
                          trailing: Padding(
                            padding: EdgeInsets.only(right: 13), // align with developer checkbox above
                            child: store.settings.isConnected
                                ? Icon(Icons.check, color: Colors.green)
                                : CupertinoActivityIndicator(),
                          ),
                        ),
                        ListTile(
                          title: Text(dic.profile.enableBazaar, style: h3Grey),
                          trailing: Checkbox(
                            value: store.settings.enableBazaar,
                            // Fixme: Need to change the tab to update the tabList. But, do we care? This is only
                            // temporary, and a developer option. It is unnecessary to include the complexity to update
                            // the parent widget from here.
                            onChanged: (_) => store.settings.toggleEnableBazaar(),
                          ),
                        ),
                      ],
                    ),
                ],
              );
            },
          ),
        );
      },
    );
  }
}
