import 'package:flutter/material.dart';

import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:polka_wallet/page/assets/secondary/asset/asset.dart';
import 'package:polka_wallet/page/assets/secondary/transfer/transfer.dart';
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
import 'package:polka_wallet/page/profile/secondary/Account.dart';

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
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: [
        const Locale('en', ''),
        const Locale('zh', ''),
      ],
      initialRoute: '/',
      theme: appTheme,
      routes: {
        '/': (_) => Home(_api, _settingStore, _accountStore),
        '/account/entry': (_) => CreateAccountEntry(),
        '/account/create': (_) => CreateAccount(_accountStore.setNewAccount),
        '/account/backup': (_) => BackupAccount(_api, _accountStore),
        '/account/import': (_) => ImportAccount(_api, _accountStore),
        '/assets/detail': (_) => AssetPage(_accountStore, _settingStore),
        '/assets/transfer': (_) => Transfer(_api, _accountStore, _settingStore),
        '/profile/account': (_) => AccountManage(_accountStore),
      },
    );
  }
}
