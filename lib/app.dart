import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:polka_wallet/page/account/scanPage.dart';
import 'package:polka_wallet/page/account/txConfirmPage.dart';
import 'package:polka_wallet/page/assets/asset/assetPage.dart';
import 'package:polka_wallet/page/assets/receive/receivePage.dart';
import 'package:polka_wallet/page/assets/transfer/detailPage.dart';
import 'package:polka_wallet/page/assets/transfer/transferPage.dart';
import 'package:polka_wallet/page/governance/council/candidateDetailPage.dart';
import 'package:polka_wallet/page/governance/council/candidateListPage.dart';
import 'package:polka_wallet/page/governance/council/councilVotePage.dart';
import 'package:polka_wallet/page/profile/aboutPage.dart';
import 'package:polka_wallet/page/profile/account/accountManagePage.dart';
import 'package:polka_wallet/page/profile/account/changeNamePage.dart';
import 'package:polka_wallet/page/profile/account/changePasswordPage.dart';
import 'package:polka_wallet/page/profile/account/exportAccountPage.dart';
import 'package:polka_wallet/page/profile/account/exportResultPage.dart';
import 'package:polka_wallet/page/profile/contacts/contactListPage.dart';
import 'package:polka_wallet/page/profile/contacts/contactPage.dart';
import 'package:polka_wallet/page/profile/contacts/contactsPage.dart';
import 'package:polka_wallet/page/profile/settings/remoteNodeListPage.dart';
import 'package:polka_wallet/page/profile/settings/settingsPage.dart';
import 'package:polka_wallet/page/profile/settings/ss58PrefixListPage.dart';
import 'package:polka_wallet/page/staking/actions/accountSelectPage.dart';
import 'package:polka_wallet/page/staking/actions/bondExtraPage.dart';
import 'package:polka_wallet/page/staking/actions/bondPage.dart';
import 'package:polka_wallet/page/staking/actions/setControllerPage.dart';
import 'package:polka_wallet/page/staking/validators/nominatePage.dart';
import 'package:polka_wallet/page/staking/actions/payoutPage.dart';
import 'package:polka_wallet/page/staking/actions/redeemPage.dart';
import 'package:polka_wallet/page/staking/actions/setPayeePage.dart';
import 'package:polka_wallet/page/staking/actions/stakingDetailPage.dart';
import 'package:polka_wallet/page/staking/actions/unbondPage.dart';
import 'package:polka_wallet/page/staking/validators/validatorDetailPage.dart';
import 'package:polka_wallet/service/substrateApi/api.dart';
import 'package:polka_wallet/service/notification.dart';
import 'package:polka_wallet/store/app.dart';

import 'utils/i18n/index.dart';
import 'common/theme.dart';

import 'package:polka_wallet/page/homePage.dart';
import 'package:polka_wallet/page/account/create/createAccountPage.dart';
import 'package:polka_wallet/page/account/create/backupAccountPage.dart';
import 'package:polka_wallet/page/account/import/importAccountPage.dart';
import 'package:polka_wallet/page/account/createAccountEntryPage.dart';

class WalletApp extends StatefulWidget {
  const WalletApp();

  @override
  _WalletAppState createState() => _WalletAppState();
}

class _WalletAppState extends State<WalletApp> {
  final _appStore = globalAppStore;

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

  @override
  void initState() {
    if (!_appStore.isReady) {
      print('initailizing app state');
      _appStore.init().then((_) {
        // init webApi after store inited
        webApi = Api(context, _appStore);
        webApi.init();

        _changeLang(_appStore.settings.localeCode);
      });
    } else {
      print('app state exists');
    }

    super.initState();
  }

  @override
  void dispose() {
    didReceiveLocalNotificationSubject.close();
    selectNotificationSubject.close();
    super.dispose();
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
      initialRoute: HomePage.route,
      theme: appTheme,
//      darkTheme: darkTheme,
      routes: {
        HomePage.route: (_) => Observer(
            builder: (_) => _appStore.account.loading
                ? Container()
                : _appStore.account.accountList.length > 0
                    ? HomePage(_appStore)
                    : CreateAccountEntryPage()),
        // account
        CreateAccountEntryPage.route: (_) => CreateAccountEntryPage(),
        CreateAccountPage.route: (_) =>
            CreateAccountPage(_appStore.account.setNewAccount),
        BackupAccountPage.route: (_) => BackupAccountPage(_appStore),
        ImportAccountPage.route: (_) => ImportAccountPage(_appStore),
        ScanPage.route: (_) => ScanPage(),
        TxConfirmPage.route: (_) => TxConfirmPage(_appStore),
        // assets
        AssetPage.route: (_) => AssetPage(_appStore),
        TransferPage.route: (_) => TransferPage(_appStore),
        ReceivePage.route: (_) => ReceivePage(_appStore.account),
        TransferDetailPage.route: (_) => TransferDetailPage(_appStore),
        // staking
        StakingDetailPage.route: (_) => StakingDetailPage(_appStore),
        ValidatorDetailPage.route: (_) => ValidatorDetailPage(_appStore),
        BondPage.route: (_) => BondPage(_appStore),
        BondExtraPage.route: (_) => BondExtraPage(_appStore),
        UnBondPage.route: (_) => UnBondPage(_appStore),
        NominatePage.route: (_) => NominatePage(_appStore),
        SetPayeePage.route: (_) => SetPayeePage(_appStore),
        RedeemPage.route: (_) => RedeemPage(_appStore),
        PayoutPage.route: (_) => PayoutPage(_appStore),
        SetControllerPage.route: (_) => SetControllerPage(_appStore),
        AccountSelectPage.route: (_) => AccountSelectPage(_appStore.account),
        // governance
        CandidateDetailPage.route: (_) => CandidateDetailPage(_appStore),
        CouncilVotePage.route: (_) => CouncilVotePage(_appStore),
        CandidateListPage.route: (_) => CandidateListPage(_appStore),
        // profile
        AccountManagePage.route: (_) => AccountManagePage(_appStore.account),
        ContactsPage.route: (_) => ContactsPage(_appStore.settings),
        ContactListPage.route: (_) => ContactListPage(_appStore.settings),
        ContactPage.route: (_) => ContactPage(_appStore.settings),
        ChangeNamePage.route: (_) => ChangeNamePage(_appStore.account),
        ChangePasswordPage.route: (_) => ChangePasswordPage(_appStore.account),
        SettingsPage.route: (_) =>
            SettingsPage(_appStore.settings, _changeLang),
        ExportAccountPage.route: (_) => ExportAccountPage(_appStore.account),
        ExportResultPage.route: (_) => ExportResultPage(),
        RemoteNodeListPage.route: (_) => RemoteNodeListPage(_appStore.settings),
        SS58PrefixListPage.route: (_) => SS58PrefixListPage(_appStore.settings),
        AboutPage.route: (_) => AboutPage(),
      },
    );
  }
}
