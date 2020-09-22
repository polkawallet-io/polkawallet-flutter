import 'package:biometric_storage/biometric_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:polka_wallet/common/components/addressIcon.dart';
import 'package:polka_wallet/common/components/passwordInputDialog.dart';
import 'package:polka_wallet/page/profile/account/changeNamePage.dart';
import 'package:polka_wallet/page/profile/account/changePasswordPage.dart';
import 'package:polka_wallet/page/profile/account/exportAccountPage.dart';
import 'package:polka_wallet/service/substrateApi/api.dart';
import 'package:polka_wallet/store/app.dart';
import 'package:polka_wallet/utils/format.dart';
import 'package:polka_wallet/utils/i18n/index.dart';

class AccountManagePage extends StatefulWidget {
  AccountManagePage(this.store);

  static final String route = '/profile/account';
  final AppStore store;

  @override
  _AccountManagePageState createState() => _AccountManagePageState();
}

class _AccountManagePageState extends State<AccountManagePage> {
  bool _supportBiometric = false; // if device support biometric
  bool _isBiometricAuthorized = false; // if user authorized biometric usage
  BiometricStorageFile _authStorage;

  void _onDeleteAccount(BuildContext context) {
    showCupertinoDialog(
      context: context,
      builder: (BuildContext context) {
        return PasswordInputDialog(
          title: Text(I18n.of(context).profile['delete.confirm']),
          account: widget.store.account.currentAccount,
          onOk: (_) {
            widget.store.account
                .removeAccount(widget.store.account.currentAccount)
                .then((_) {
              // refresh balance
              widget.store.assets.loadAccountCache();
              webApi.assets.fetchBalance();
              // refresh user's staking info
              widget.store.staking.loadAccountCache();
              webApi.staking.fetchAccountStaking();
            });
            Navigator.of(context).pop();
          },
        );
      },
    );
  }

  Future<void> _updateBiometricAuth(bool enable, String password) async {
    final pubKey = widget.store.account.currentAccountPubKey;
    bool result = !enable;
    if (enable) {
      try {
        await _authStorage.write(password);
        webApi.account.setBiometricEnabled(pubKey);
        result = enable;
      } catch (err) {
        // user may cancel the biometric auth. then we set biometric disabled
        webApi.account.setBiometricDisabled(pubKey);
      }
    } else {
      webApi.account.setBiometricDisabled(pubKey);
      result = enable;
    }

    if (result == enable) {
      setState(() {
        _isBiometricAuthorized = enable;
      });
    }
  }

  Future<void> _checkBiometricAuth() async {
    final response = await BiometricStorage().canAuthenticate();
    final supportBiometric = response == CanAuthenticateResponse.success;
    if (!supportBiometric) {
      return;
    }
    setState(() {
      _supportBiometric = supportBiometric;
    });
    final pubKey = widget.store.account.currentAccountPubKey;
    final storeFile =
        await webApi.account.getBiometricPassStoreFile(context, pubKey);
    final isAuthorized = webApi.account.getBiometricEnabled(pubKey);
    setState(() {
      _isBiometricAuthorized = isAuthorized;
      _authStorage = storeFile;
    });
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkBiometricAuth();
    });
  }

  @override
  Widget build(BuildContext context) {
    final Map<String, String> dic = I18n.of(context).profile;

    Color primaryColor = Theme.of(context).primaryColor;
    return Observer(
      builder: (_) => Scaffold(
        appBar: AppBar(
          title: Text(dic['account']),
          centerTitle: true,
          elevation: 0.0,
        ),
        body: SafeArea(
          child: Column(
            children: <Widget>[
              Expanded(
                child: ListView(
                  children: <Widget>[
                    Container(
                      color: primaryColor,
                      padding: EdgeInsets.only(bottom: 16),
                      child: ListTile(
                        leading: AddressIcon(
                          '',
                          pubKey: widget.store.account.currentAccount.pubKey,
                        ),
                        title: Text(
                            widget.store.account.currentAccount.name ?? 'name',
                            style:
                                TextStyle(fontSize: 16, color: Colors.white)),
                        subtitle: Text(
                          Fmt.address(widget.store.account.currentAddress) ??
                              '',
                          style: TextStyle(fontSize: 16, color: Colors.white70),
                        ),
                      ),
                    ),
                    Container(padding: EdgeInsets.only(top: 16)),
                    ListTile(
                      title: Text(dic['name.change']),
                      trailing: Icon(Icons.arrow_forward_ios, size: 18),
                      onTap: () =>
                          Navigator.pushNamed(context, ChangeNamePage.route),
                    ),
                    ListTile(
                      title: Text(dic['pass.change']),
                      trailing: Icon(Icons.arrow_forward_ios, size: 18),
                      onTap: () => Navigator.pushNamed(
                          context, ChangePasswordPage.route),
                    ),
                    ListTile(
                      title: Text(dic['export']),
                      trailing: Icon(Icons.arrow_forward_ios, size: 18),
                      onTap: () => Navigator.of(context)
                          .pushNamed(ExportAccountPage.route),
                    ),
                    _supportBiometric
                        ? ListTile(
                            title: Text(
                                I18n.of(context).home['unlock.bio.enable']),
                            trailing: CupertinoSwitch(
                              value: _isBiometricAuthorized,
                              onChanged: (v) {
                                if (v != _isBiometricAuthorized) {
                                  showCupertinoDialog(
                                    context: context,
                                    builder: (_) {
                                      return PasswordInputDialog(
                                        title: Text(
                                            I18n.of(context).home['unlock']),
                                        account:
                                            widget.store.account.currentAccount,
                                        onOk: (password) {
                                          _updateBiometricAuth(v, password);
                                        },
                                      );
                                    },
                                  );
                                }
                              },
                            ),
                          )
                        : Container(),
                  ],
                ),
              ),
              Row(
                children: <Widget>[
                  Expanded(
                    child: FlatButton(
                      padding: EdgeInsets.all(16),
                      color: Colors.white,
                      textColor: Colors.red,
                      child: Text(dic['delete']),
                      onPressed: () => _onDeleteAccount(context),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
