import 'package:encointer_wallet/common/components/willPopScopWrapper.dart';
import 'package:encointer_wallet/config.dart';
import 'package:encointer_wallet/page-encointer/bazaar/business/businessOverviewPage.dart';
import 'package:encointer_wallet/page-encointer/bazaar/business/businessOverviewPanel.dart';
import 'package:encointer_wallet/page-encointer/bazaar/business/createBusinessForm.dart';
import 'package:encointer_wallet/page-encointer/bazaar/business/createBusinessPage.dart';
import 'package:encointer_wallet/page-encointer/bazaar/business/myBusinessPage.dart';
import 'package:encointer_wallet/page-encointer/homePage.dart';
import 'package:encointer_wallet/page-encointer/phases/assigning/assigningPage.dart';
import 'package:encointer_wallet/page-encointer/phases/attesting/attestingPage.dart';
import 'package:encointer_wallet/page-encointer/phases/registering/registerParticipantPanel.dart';
import 'package:encointer_wallet/page-encointer/phases/registering/registeringPage.dart';
import 'package:encointer_wallet/page/account/create/createAccountPage.dart';
import 'package:encointer_wallet/page/account/createAccountEntryPage.dart';
import 'package:encointer_wallet/page/account/import/importAccountPage.dart';
import 'package:encointer_wallet/page/account/scanPage.dart';
import 'package:encointer_wallet/page/account/txConfirmPage.dart';
import 'package:encointer_wallet/page/assets/asset/assetPage.dart';
import 'package:encointer_wallet/page/assets/receive/receivePage.dart';
import 'package:encointer_wallet/page/assets/transfer/currencySelectPage.dart';
import 'package:encointer_wallet/page/assets/transfer/detailPage.dart';
import 'package:encointer_wallet/page/assets/transfer/transferPage.dart';
import 'package:encointer_wallet/page/networkSelectPage.dart';
import 'package:encointer_wallet/page/profile/aboutPage.dart';
import 'package:encointer_wallet/page/profile/account/accountManagePage.dart';
import 'package:encointer_wallet/page/profile/account/changeNamePage.dart';
import 'package:encointer_wallet/page/profile/account/changePasswordPage.dart';
import 'package:encointer_wallet/page/profile/account/exportAccountPage.dart';
import 'package:encointer_wallet/page/profile/account/exportResultPage.dart';
import 'package:encointer_wallet/page/profile/contacts/contactListPage.dart';
import 'package:encointer_wallet/page/profile/contacts/contactPage.dart';
import 'package:encointer_wallet/page/profile/contacts/contactsPage.dart';
import 'package:encointer_wallet/page/profile/settings/remoteNodeListPage.dart';
import 'package:encointer_wallet/page/profile/settings/settingsPage.dart';
import 'package:encointer_wallet/page/profile/settings/ss58PrefixListPage.dart';
import 'package:encointer_wallet/service/notification.dart';
import 'package:encointer_wallet/service/substrateApi/api.dart';
import 'package:encointer_wallet/store/app.dart';
import 'package:encointer_wallet/utils/localStorage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_mobx/flutter_mobx.dart';

import 'common/theme.dart';
import 'mocks/api/api.dart';
import 'mocks/storage/localStorage.dart';
import 'utils/i18n/index.dart';

class WalletApp extends StatefulWidget {
  const WalletApp(this.config);

  final Config config;

  @override
  _WalletAppState createState() => _WalletAppState();
}

class _WalletAppState extends State<WalletApp> {
  AppStore _appStore;
  Locale _locale = const Locale('en', '');
  ThemeData _theme = appTheme;

  void _changeTheme() {
    if (_appStore.settings.endpointIsEncointer) {
      setState(() {
        _theme = appThemeEncointer;
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
      // Todo: Use provider pattern instead of globals, see: https://github.com/encointer/encointer-wallet-flutter/issues/132
      globalAppStore = widget.config.mockLocalStorage ? AppStore(getMockLocalStorage()) : AppStore(LocalStorage());
      _appStore = globalAppStore;
      print('initializing app state');
      print('sys locale: ${Localizations.localeOf(context)}');
      await _appStore.init(Localizations.localeOf(context).toString());

      // init webApi after store initiated
      webApi = widget.config.mockSubstrateApi ? MockApi(context, _appStore) : Api(context, _appStore);
      webApi.init();

      _changeLang(context, _appStore.settings.localeCode);
      _changeTheme();
    }
    return _appStore.account.accountListAll.length;
  }

  @protected
  @mustCallSuper
  void reassemble() {
    // this gets executed upon hot-restart or hot-reload only!
    super.reassemble();
    // TODO: reload dictionary in case it was updated
  }

  @override
  void dispose() {
    didReceiveLocalNotificationSubject.close();
    selectNotificationSubject.close();
    webApi.closeWebView();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'EncointerWallet',
      localizationsDelegates: [
        AppLocalizationsDelegate(_locale),
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: [
        const Locale('en', ''),
      ],
      initialRoute: widget.config.initialRoute,
      theme: _theme,
//      darkTheme: darkTheme,
      routes: {
        EncointerHomePage.route: (context) => Observer(
              builder: (_) {
                return WillPopScopWrapper(
                  child: FutureBuilder<int>(
                    future: _initStore(context),
                    builder: (_, AsyncSnapshot<int> snapshot) {
                      if (snapshot.hasData) {
                        return snapshot.data > 0 ? EncointerHomePage(_appStore) : CreateAccountEntryPage();
                      } else {
                        return CupertinoActivityIndicator();
                      }
                    },
                  ),
                );
              },
            ),
        NetworkSelectPage.route: (_) => NetworkSelectPage(_appStore, _changeTheme),
        // account
        CreateAccountEntryPage.route: (_) => CreateAccountEntryPage(),
        CreateAccountPage.route: (_) => CreateAccountPage(_appStore),
        ImportAccountPage.route: (_) => ImportAccountPage(_appStore),
        ScanPage.route: (_) => ScanPage(),
        TxConfirmPage.route: (_) => TxConfirmPage(_appStore),
        // assets
        AssetPage.route: (_) => AssetPage(_appStore),
        TransferPage.route: (_) => TransferPage(_appStore),
        ReceivePage.route: (_) => ReceivePage(_appStore),
        TransferDetailPage.route: (_) => TransferDetailPage(_appStore),
        CommunitySelectPage.route: (_) => CommunitySelectPage(),
        // profile
        AccountManagePage.route: (_) => AccountManagePage(_appStore),
        ContactsPage.route: (_) => ContactsPage(_appStore),
        ContactListPage.route: (_) => ContactListPage(_appStore),
        ContactPage.route: (_) => ContactPage(_appStore),
        ChangeNamePage.route: (_) => ChangeNamePage(_appStore.account),
        ChangePasswordPage.route: (_) => ChangePasswordPage(_appStore.account),
        SettingsPage.route: (_) => SettingsPage(_appStore.settings, _changeLang),
        ExportAccountPage.route: (_) => ExportAccountPage(_appStore.account),
        ExportResultPage.route: (_) => ExportResultPage(),
        RemoteNodeListPage.route: (_) => RemoteNodeListPage(_appStore.settings),
        SS58PrefixListPage.route: (_) => SS58PrefixListPage(_appStore.settings),
        AboutPage.route: (_) => AboutPage(),
        // encointer
        RegisteringPage.route: (_) => RegisteringPage(_appStore),
        RegisterParticipantPanel.route: (_) => RegisterParticipantPanel(_appStore),
        AssigningPage.route: (_) => AssigningPage(_appStore),
        AttestingPage.route: (_) => AttestingPage(_appStore),
        // bazaar
        CreateBusinessPage.route: (_) => CreateBusinessPage(_appStore),
        CreateBusinessForm.route: (_) => CreateBusinessForm(_appStore),
        BusinessOverviewPage.route: (_) => BusinessOverviewPage(_appStore),
        BusinessOverviewPanel.route: (_) => BusinessOverviewPanel(_appStore),
        MyBusinessPage.route: (_) => MyBusinessPage(_appStore),
      },
    );
  }
}
