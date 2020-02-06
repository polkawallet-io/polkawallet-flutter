import 'package:flutter/material.dart';

import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:polka_wallet/page/assets/secondary/asset/asset.dart';
import 'package:polka_wallet/page/assets/secondary/receive/receive.dart';
import 'package:polka_wallet/page/assets/secondary/scan.dart';
import 'package:polka_wallet/page/assets/secondary/transfer/detail.dart';
import 'package:polka_wallet/page/assets/secondary/transfer/transfer.dart';
import 'package:polka_wallet/page/profile/secondary/about.dart';
import 'package:polka_wallet/page/profile/secondary/account/changeName.dart';
import 'package:polka_wallet/page/profile/secondary/account/changePassword.dart';
import 'package:polka_wallet/page/profile/secondary/contacts/contact.dart';
import 'package:polka_wallet/page/profile/secondary/contacts/contacts.dart';
import 'package:polka_wallet/page/profile/secondary/settings/remoteNode.dart';
import 'package:polka_wallet/page/profile/secondary/settings/settings.dart';
import 'package:polka_wallet/service/api.dart';
import 'package:polka_wallet/store/settings.dart';

import 'utils/i18n/index.dart';
import 'common/theme.dart';

import 'package:polka_wallet/store/account.dart';

import 'package:polka_wallet/page/home.dart';
import 'package:polka_wallet/page/assets/secondary/createAccount/createAccount.dart';
import 'package:polka_wallet/page/assets/secondary/createAccount/backupAccount.dart';
import 'package:polka_wallet/page/assets/secondary/importAccount/importAccount.dart';
import 'package:polka_wallet/page/assets/secondary/createAccountEntry.dart';
import 'package:polka_wallet/page/profile/secondary/account/Account.dart';

void main() => runApp(WalletApp());

class WalletApp extends StatefulWidget {
  const WalletApp();

  @override
  _WalletAppState createState() => _WalletAppState();
}

class _WalletAppState extends State<WalletApp> {
  final _accountStore = AccountStore();
  final _settingStore = SettingsStore();

  Api _api;

  @override
  void initState() {
    _accountStore.loadAccount();
    _settingStore.loadEndpoint();
    _settingStore.loadContacts();

    _api = Api(
        context: context,
        accountStore: _accountStore,
        settingsStore: _settingStore);

    _api.init();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PolkaWallet',
      localizationsDelegates: [
        const AppLocalizationsDelegate(),
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: [
        const Locale('en', ''),
        const Locale('zh', ''),
      ],
      initialRoute: '/',
      theme: appTheme,
      routes: {
        '/': (_) => Observer(
              builder: (_) => _accountStore.accountList.length > 0
                  ? Home(_api, _settingStore, _accountStore)
                  : CreateAccountEntry(),
            ),
        '/account/entry': (_) => CreateAccountEntry(),
        '/account/create': (_) => CreateAccount(_accountStore.setNewAccount),
        '/account/backup': (_) => BackupAccount(_api, _accountStore),
        '/account/import': (_) => ImportAccount(_api, _accountStore),
        '/account/scan': (_) => Scan(),
        '/assets/detail': (_) => AssetPage(_accountStore, _settingStore),
        '/assets/transfer': (_) => Transfer(_api, _accountStore, _settingStore),
        '/assets/receive': (_) => Receive(_accountStore),
        '/assets/tx': (_) => TransferDetail(_accountStore, _settingStore),
        '/profile/account': (_) => AccountManage(_accountStore),
        '/profile/contacts': (_) => Contacts(_settingStore),
        '/profile/contact': (_) => Contact(_settingStore),
        '/profile/name': (_) => ChangeName(_api, _accountStore),
        '/profile/password': (_) => ChangePassword(_api, _accountStore),
        '/profile/settings': (_) => Settings(_settingStore),
        '/profile/endpoint': (_) => RemoteNode(_settingStore),
        '/profile/about': (_) => About(),
      },
    );
  }
}
