import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:polka_wallet/common/consts/settings.dart';
import 'package:polka_wallet/page-acala/exchange/exchangePage.dart';
import 'package:polka_wallet/page-acala/homePage.dart';
import 'package:polka_wallet/page-acala/loan/loanAdjustPage.dart';
import 'package:polka_wallet/page-acala/loan/loanCreatePage.dart';
import 'package:polka_wallet/page-acala/loan/loanHistoryPage.dart';
import 'package:polka_wallet/page-acala/loan/loanPage.dart';
import 'package:polka_wallet/page/account/scanPage.dart';
import 'package:polka_wallet/page/account/txConfirmPage.dart';
import 'package:polka_wallet/page/assets/asset/assetPage.dart';
import 'package:polka_wallet/page/assets/receive/receivePage.dart';
import 'package:polka_wallet/page/assets/transfer/currencySelectPage.dart';
import 'package:polka_wallet/page/assets/transfer/detailPage.dart';
import 'package:polka_wallet/page/assets/transfer/transferPage.dart';
import 'package:polka_wallet/page/governance/council/candidateDetailPage.dart';
import 'package:polka_wallet/page/governance/council/candidateListPage.dart';
import 'package:polka_wallet/page/governance/council/councilVotePage.dart';
import 'package:polka_wallet/page/governance/democracy/referendumVotePage.dart';
import 'package:polka_wallet/page/networkSelectPage.dart';
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
import 'package:polka_wallet/store/settings.dart';

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
  AppStore _appStore;

  Locale _locale = const Locale('en', '');
  ThemeData _theme = appTheme;

  void _changeTheme() {
    if (_appStore.settings.endpoint.info == networkEndpointAcala.info) {
      setState(() {
        _theme = appThemeAcala;
      });
    } else {
      setState(() {
        _theme = appTheme;
      });
    }
  }

  void _changeLang(BuildContext context, String code) {
    Locale res;
    switch (code) {
      case 'zh':
        res = const Locale('zh', '');
        break;
      case 'en':
        res = const Locale('en', '');
        break;
      default:
        res = Localizations.localeOf(context);
    }
    setState(() {
      _locale = res;
    });
  }

  Future<int> _initStore(BuildContext context) async {
    if (_appStore == null) {
      _appStore = globalAppStore;
      print('initailizing app state');
      print('sys locale: ${Localizations.localeOf(context)}');
      await _appStore.init(Localizations.localeOf(context).toString());

      // init webApi after store initiated
      webApi = Api(context, _appStore);
      webApi.init();

      _changeLang(context, _appStore.settings.localeCode);
      _changeTheme();
    }

    return _appStore.account.accountList.length;
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
      theme: _theme,
//      darkTheme: darkTheme,
      routes: {
        HomePage.route: (context) => Observer(
              builder: (_) {
                EndpointData network = _appStore != null
                    ? _appStore.settings.endpoint
                    : EndpointData();
                return FutureBuilder<int>(
                  future: _initStore(context),
                  builder: (_, AsyncSnapshot<int> snapshot) {
                    if (snapshot.hasData) {
                      return snapshot.data > 0
                          ? network.info == networkEndpointAcala.info
                              ? AcalaHomePage(_appStore)
                              : HomePage(_appStore)
                          : CreateAccountEntryPage();
                    } else {
                      return Container();
                    }
                  },
                );
              },
            ),
        NetworkSelectPage.route: (_) =>
            NetworkSelectPage(_appStore, _changeTheme),
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
        ReceivePage.route: (_) => ReceivePage(_appStore),
        TransferDetailPage.route: (_) => TransferDetailPage(_appStore),
        CurrencySelectPage.route: (_) => CurrencySelectPage(),
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
        AccountSelectPage.route: (_) => AccountSelectPage(_appStore),
        // governance
        CandidateDetailPage.route: (_) => CandidateDetailPage(_appStore),
        CouncilVotePage.route: (_) => CouncilVotePage(_appStore),
        CandidateListPage.route: (_) => CandidateListPage(_appStore),
        ReferendumVotePage.route: (_) => ReferendumVotePage(_appStore),
        // profile
        AccountManagePage.route: (_) => AccountManagePage(_appStore),
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

        // acala-network
        ExchangePage.route: (_) => ExchangePage(_appStore),
        LoanPage.route: (_) => LoanPage(_appStore),
        LoanCreatePage.route: (_) => LoanCreatePage(_appStore),
        LoanAdjustPage.route: (_) => LoanAdjustPage(_appStore),
        LoanHistoryPage.route: (_) => LoanHistoryPage(_appStore),
      },
    );
  }
}
