import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:polka_wallet/common/components/willPopScopWrapper.dart';
import 'package:polka_wallet/common/consts/settings.dart';
import 'package:polka_wallet/page-acala/earn/addLiquidityPage.dart';
import 'package:polka_wallet/page-acala/earn/earnHistoryPage.dart';
import 'package:polka_wallet/page-acala/earn/earnPage.dart';
import 'package:polka_wallet/page-acala/earn/withdrawLiquidityPage.dart';
import 'package:polka_wallet/page-acala/homa/homaHistoryPage.dart';
import 'package:polka_wallet/page-acala/homa/homaPage.dart';
import 'package:polka_wallet/page-acala/homa/mintPage.dart';
import 'package:polka_wallet/page-acala/homa/redeemPage.dart';
import 'package:polka_wallet/page-acala/homePage.dart';
import 'package:polka_wallet/page-acala/loan/loanAdjustPage.dart';
import 'package:polka_wallet/page-acala/loan/loanCreatePage.dart';
import 'package:polka_wallet/page-acala/loan/loanHistoryPage.dart';
import 'package:polka_wallet/page-acala/loan/loanPage.dart';
import 'package:polka_wallet/page-acala/loan/loanTxDetailPage.dart';
import 'package:polka_wallet/page-acala/swap/swapHistoryPage.dart';
import 'package:polka_wallet/page-acala/swap/swapPage.dart';
import 'package:polka_wallet/page-laminar/margin/laminarMarginPoolDepositPage.dart';
import 'package:polka_wallet/page-laminar/margin/laminarMarginPositions.dart';
import 'package:polka_wallet/page-laminar/swap/laminarSwapHistoryPage.dart';
import 'package:polka_wallet/page-laminar/swap/laminarSwapPage.dart';
import 'package:polka_wallet/page/account/scanPage.dart';
import 'package:polka_wallet/page/account/txConfirmPage.dart';
import 'package:polka_wallet/page/account/uos/qrSenderPage.dart';
import 'package:polka_wallet/page/account/uos/qrSignerPage.dart';
import 'package:polka_wallet/page/asExtension/walletExtensionSignPage.dart';
import 'package:polka_wallet/page/assets/announcementPage.dart';
import 'package:polka_wallet/page/assets/asset/assetPage.dart';
import 'package:polka_wallet/page/assets/claim/attestPage.dart';
import 'package:polka_wallet/page/assets/claim/claimPage.dart';
import 'package:polka_wallet/page/assets/receive/receivePage.dart';
import 'package:polka_wallet/page/assets/transfer/currencySelectPage.dart';
import 'package:polka_wallet/page/assets/transfer/detailPage.dart';
import 'package:polka_wallet/page/assets/transfer/transferCrossChainPage.dart';
import 'package:polka_wallet/page/assets/transfer/transferPage.dart';
import 'package:polka_wallet/page/governance/council/candidateDetailPage.dart';
import 'package:polka_wallet/page/governance/council/candidateListPage.dart';
import 'package:polka_wallet/page/governance/council/councilPage.dart';
import 'package:polka_wallet/page/governance/council/councilVotePage.dart';
import 'package:polka_wallet/page/governance/council/motionDetailPage.dart';
import 'package:polka_wallet/page/governance/democracy/democracyPage.dart';
import 'package:polka_wallet/page/governance/democracy/proposalDetailPage.dart';
import 'package:polka_wallet/page/governance/democracy/referendumVotePage.dart';
import 'package:polka_wallet/page/asExtension/dAppWrapperPage.dart';
import 'package:polka_wallet/page/governance/treasury/spendProposalPage.dart';
import 'package:polka_wallet/page/governance/treasury/submitProposalPage.dart';
import 'package:polka_wallet/page/governance/treasury/submitTipPage.dart';
import 'package:polka_wallet/page/governance/treasury/tipDetailPage.dart';
import 'package:polka_wallet/page/governance/treasury/treasuryPage.dart';
import 'package:polka_wallet/page/networkSelectPage.dart';
import 'package:polka_wallet/page/profile/aboutPage.dart';
import 'package:polka_wallet/page/profile/account/accountManagePage.dart';
import 'package:polka_wallet/page/profile/account/changeNamePage.dart';
import 'package:polka_wallet/page/profile/account/changePasswordPage.dart';
import 'package:polka_wallet/page/profile/account/exportAccountPage.dart';
import 'package:polka_wallet/page/profile/account/exportResultPage.dart';
import 'package:polka_wallet/page/profile/recovery/createRecoveryPage.dart';
import 'package:polka_wallet/page/profile/recovery/friendListPage.dart';
import 'package:polka_wallet/page/profile/recovery/initiateRecoveryPage.dart';
import 'package:polka_wallet/page/profile/recovery/recoveryProofPage.dart';
import 'package:polka_wallet/page/profile/recovery/recoverySettingPage.dart';
import 'package:polka_wallet/page/profile/contacts/contactListPage.dart';
import 'package:polka_wallet/page/profile/contacts/contactPage.dart';
import 'package:polka_wallet/page/profile/contacts/contactsPage.dart';
import 'package:polka_wallet/page/profile/recovery/recoveryStatePage.dart';
import 'package:polka_wallet/page/profile/recovery/vouchRecoveryPage.dart';
import 'package:polka_wallet/page/profile/settings/remoteNodeListPage.dart';
import 'package:polka_wallet/page/profile/settings/settingsPage.dart';
import 'package:polka_wallet/page/profile/settings/ss58PrefixListPage.dart';
import 'package:polka_wallet/page/staking/actions/accountSelectPage.dart';
import 'package:polka_wallet/page/staking/actions/bondExtraPage.dart';
import 'package:polka_wallet/page/staking/actions/bondPage.dart';
import 'package:polka_wallet/page/staking/actions/rewardDetailPage.dart';
import 'package:polka_wallet/page/staking/actions/setControllerPage.dart';
import 'package:polka_wallet/page/staking/validators/nominatePage.dart';
import 'package:polka_wallet/page/staking/actions/payoutPage.dart';
import 'package:polka_wallet/page/staking/actions/redeemPage.dart';
import 'package:polka_wallet/page/staking/actions/setPayeePage.dart';
import 'package:polka_wallet/page/staking/actions/stakingDetailPage.dart';
import 'package:polka_wallet/page/staking/actions/unbondPage.dart';
import 'package:polka_wallet/page/staking/validators/validatorDetailPage.dart';
import 'package:polka_wallet/service/graphql.dart';
import 'package:polka_wallet/service/substrateApi/api.dart';
import 'package:polka_wallet/service/notification.dart';
import 'package:polka_wallet/service/walletApi.dart';
import 'package:polka_wallet/store/app.dart';
import 'package:polka_wallet/store/settings.dart';
import 'package:polka_wallet/utils/UI.dart';

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
    } else if (_appStore.settings.endpoint.info ==
        networkEndpointLaminar.info) {
      setState(() {
        _theme = appThemeLaminar;
      });
    } else if (_appStore.settings.endpoint.info == networkEndpointKusama.info) {
      setState(() {
        _theme = appThemeKusama;
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

  Future<void> _checkUpdate(BuildContext context) async {
    final versions = await WalletApi.getLatestVersion();
    UI.checkUpdate(context, versions, autoCheck: true);
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

      _checkUpdate(context);
    }
    return _appStore.account.accountListAll.length;
  }

  @override
  void dispose() {
    showCupertinoDialog(
      context: context,
      builder: (BuildContext context) {
        final Map<String, String> dic = I18n.of(context).assets;
        return CupertinoAlertDialog(
          title: Container(),
          content: Text('${dic['copy']} ${dic['success']}'),
        );
      },
    );

    didReceiveLocalNotificationSubject.close();
    selectNotificationSubject.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ClientProvider(
      uri: GraphQLConfig['httpUri'],
      subscriptionUri: GraphQLConfig['wsUri'],
      child: MaterialApp(
        title: 'PolkaWallet',
        debugShowCheckedModeBanner: false,
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
                  return WillPopScopWrapper(
                    child: FutureBuilder<int>(
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
                    ),
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
          QrSignerPage.route: (_) => QrSignerPage(_appStore),
          QrSenderPage.route: (_) => QrSenderPage(),
          DAppWrapperPage.route: (_) => DAppWrapperPage(_appStore),
          WalletExtensionSignPage.route: (_) =>
              WalletExtensionSignPage(_appStore),
          // assets
          AssetPage.route: (_) => AssetPage(_appStore),
          TransferPage.route: (_) => TransferPage(_appStore),
          TransferCrossChainPage.route: (_) =>
              TransferCrossChainPage(_appStore),
          ReceivePage.route: (_) => ReceivePage(_appStore),
          TransferDetailPage.route: (_) => TransferDetailPage(_appStore),
          CurrencySelectPage.route: (_) => CurrencySelectPage(),
          ClaimPage.route: (_) => ClaimPage(_appStore),
          AttestPage.route: (_) => AttestPage(_appStore),
          AnnouncementPage.route: (_) => AnnouncementPage(),
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
          RewardDetailPage.route: (_) => RewardDetailPage(_appStore),
          SetControllerPage.route: (_) => SetControllerPage(_appStore),
          AccountSelectPage.route: (_) => AccountSelectPage(_appStore),
          // governance
          DemocracyPage.route: (_) => DemocracyPage(_appStore),
          CouncilPage.route: (_) => CouncilPage(_appStore),
          MotionDetailPage.route: (_) => MotionDetailPage(_appStore),
          TreasuryPage.route: (_) => TreasuryPage(_appStore),
          SpendProposalPage.route: (_) => SpendProposalPage(_appStore),
          TipDetailPage.route: (_) => TipDetailPage(_appStore),
          SubmitProposalPage.route: (_) => SubmitProposalPage(_appStore),
          SubmitTipPage.route: (_) => SubmitTipPage(_appStore),
          CandidateDetailPage.route: (_) => CandidateDetailPage(_appStore),
          CouncilVotePage.route: (_) => CouncilVotePage(_appStore),
          CandidateListPage.route: (_) => CandidateListPage(_appStore),
          ReferendumVotePage.route: (_) => ReferendumVotePage(_appStore),
          ProposalDetailPage.route: (_) => ProposalDetailPage(_appStore),
          // profile
          AccountManagePage.route: (_) => AccountManagePage(_appStore),
          ContactsPage.route: (_) => ContactsPage(_appStore),
          ContactListPage.route: (_) => ContactListPage(_appStore),
          ContactPage.route: (_) => ContactPage(_appStore),
          ChangeNamePage.route: (_) => ChangeNamePage(_appStore.account),
          ChangePasswordPage.route: (_) =>
              ChangePasswordPage(_appStore.account),
          SettingsPage.route: (_) =>
              SettingsPage(_appStore.settings, _changeLang),
          ExportAccountPage.route: (_) => ExportAccountPage(_appStore.account),
          ExportResultPage.route: (_) => ExportResultPage(),
          RemoteNodeListPage.route: (_) =>
              RemoteNodeListPage(_appStore.settings),
          SS58PrefixListPage.route: (_) =>
              SS58PrefixListPage(_appStore.settings),
          AboutPage.route: (_) => AboutPage(),
          RecoverySettingPage.route: (_) => RecoverySettingPage(_appStore),
          RecoveryStatePage.route: (_) => RecoveryStatePage(_appStore),
          RecoveryProofPage.route: (_) => RecoveryProofPage(_appStore),
          CreateRecoveryPage.route: (_) => CreateRecoveryPage(_appStore),
          FriendListPage.route: (_) => FriendListPage(_appStore),
          InitiateRecoveryPage.route: (_) => InitiateRecoveryPage(_appStore),
          VouchRecoveryPage.route: (_) => VouchRecoveryPage(_appStore),

          // acala-network
          SwapPage.route: (_) => SwapPage(_appStore),
          LoanPage.route: (_) => LoanPage(_appStore),
          LoanCreatePage.route: (_) => LoanCreatePage(_appStore),
          LoanAdjustPage.route: (_) => LoanAdjustPage(_appStore),
          LoanHistoryPage.route: (_) => LoanHistoryPage(_appStore),
          LoanTxDetailPage.route: (_) => LoanTxDetailPage(_appStore),
          SwapHistoryPage.route: (_) => SwapHistoryPage(_appStore),
          EarnPage.route: (_) => EarnPage(_appStore),
          AddLiquidityPage.route: (_) => AddLiquidityPage(_appStore),
          WithdrawLiquidityPage.route: (_) => WithdrawLiquidityPage(_appStore),
          EarnHistoryPage.route: (_) => EarnHistoryPage(_appStore),
          HomaPage.route: (_) => HomaPage(_appStore),
          MintPage.route: (_) => MintPage(_appStore),
          HomaRedeemPage.route: (_) => HomaRedeemPage(_appStore),
          HomaHistoryPage.route: (_) => HomaHistoryPage(_appStore),

          // laminar flow exchange
          LaminarSwapPage.route: (_) => LaminarSwapPage(_appStore),
          LaminarSwapHistoryPage.route: (_) =>
              LaminarSwapHistoryPage(_appStore),
          LaminarMarginPageWrapper.route: (_) =>
              LaminarMarginPageWrapper(_appStore),
          LaminarMarginPoolDepositPage.route: (_) =>
              LaminarMarginPoolDepositPage(_appStore),
        },
      ),
    );
  }
}
