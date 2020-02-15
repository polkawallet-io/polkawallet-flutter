import 'package:flutter/material.dart';

import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:polka_wallet/page/assets/secondary/asset/asset.dart';
import 'package:polka_wallet/page/assets/secondary/receive/receive.dart';
import 'package:polka_wallet/page/assets/secondary/scan.dart';
import 'package:polka_wallet/page/assets/secondary/transfer/detail.dart';
import 'package:polka_wallet/page/assets/secondary/transfer/transfer.dart';
import 'package:polka_wallet/page/assets/secondary/transfer/transferConfirm.dart';
import 'package:polka_wallet/page/profile/secondary/about.dart';
import 'package:polka_wallet/page/profile/secondary/account/changeName.dart';
import 'package:polka_wallet/page/profile/secondary/account/changePassword.dart';
import 'package:polka_wallet/page/profile/secondary/contacts/contact.dart';
import 'package:polka_wallet/page/profile/secondary/contacts/contactList.dart';
import 'package:polka_wallet/page/profile/secondary/contacts/contacts.dart';
import 'package:polka_wallet/page/profile/secondary/settings/remoteNode.dart';
import 'package:polka_wallet/page/profile/secondary/settings/settings.dart';
import 'package:polka_wallet/page/staking/secondary/detail.dart';
import 'package:polka_wallet/store/app.dart';
import 'package:polka_wallet/utils/localStorage.dart';

import 'utils/i18n/index.dart';
import 'common/theme.dart';

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
  final _appStore = AppStore();

  Locale _locale = const Locale('en', '');

  void _changeLang(String code) {
    Locale res;
    switch (code) {
      case 'zh':
        res = const Locale('zh', '');
        break;
      case 'en':
        res = const Locale('en', '');
        break;
      default:
        res = Locale.cachedLocale;
    }
    setState(() {
      _locale = res;
    });
  }

  Future<void> _initLocaleFromLocalStorage() async {
    String value = await LocalStorage.getLocale();
    _changeLang(value);
  }

  @override
  void initState() {
    _appStore.init(context);

    _initLocaleFromLocalStorage();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PolkaWallet',
      localizationsDelegates: [
        AppLocalizationsDelegate(_locale),
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
//      darkTheme: darkTheme,
      routes: {
        '/': (_) => Observer(
            builder: (_) => _appStore.account.accountList.length > 0
                ? Home(_appStore)
                : CreateAccountEntry()),
        '/account/entry': (_) => CreateAccountEntry(),
        '/account/create': (_) =>
            CreateAccount(_appStore.account.setNewAccount),
        '/account/backup': (_) => BackupAccount(_appStore),
        '/account/import': (_) => ImportAccount(_appStore),
        '/account/scan': (_) => Scan(),
        '/assets/detail': (_) => AssetPage(_appStore),
        '/assets/transfer': (_) => Transfer(_appStore),
        '/assets/transfer/confirm': (_) => TransferConfirm(_appStore),
        '/assets/receive': (_) => Receive(_appStore.account),
        '/assets/tx': (_) => TransferDetail(_appStore),
        '/staking/tx': (_) => StakingDetail(_appStore),
        '/profile/account': (_) =>
            AccountManage(_appStore.api, _appStore.account),
        '/profile/contacts': (_) => Contacts(_appStore.settings),
        '/contacts/list': (_) => ContactList(_appStore.settings),
        '/profile/contact': (_) => Contact(_appStore.settings),
        '/profile/name': (_) => ChangeName(_appStore.api, _appStore.account),
        '/profile/password': (_) =>
            ChangePassword(_appStore.api, _appStore.account),
        '/profile/settings': (_) => Settings(_appStore.settings, _changeLang),
        '/profile/endpoint': (_) =>
            RemoteNode(_appStore.api, _appStore.settings),
        '/profile/about': (_) => About(),
      },
    );
  }
}
