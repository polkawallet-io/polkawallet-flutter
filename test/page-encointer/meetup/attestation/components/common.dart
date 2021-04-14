import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:encointer_wallet/common/components/roundedButton.dart';
import 'package:encointer_wallet/page-encointer/meetup/attestation/components/qrCode.dart';
import 'package:encointer_wallet/page-encointer/meetup/attestation/components/scanQrCode.dart';
import 'package:encointer_wallet/page-encointer/meetup/attestation/components/stateMachineWidget.dart';
import 'package:encointer_wallet/store/app.dart';
import 'package:encointer_wallet/store/encointer/types/attestationState.dart';
import 'package:encointer_wallet/utils/i18n/index.dart';

import 'package:encointer_wallet/mocks/data/mockAccountData.dart';
import 'package:encointer_wallet/mocks/data/mockEncointerData.dart';
import 'package:encointer_wallet/mocks/storage/localStorage.dart';

Widget makeTestableWidget({Widget child}) {
  return MediaQuery(
    data: MediaQueryData(),
    child: MaterialApp(
      localizationsDelegates: [
        AppLocalizationsDelegate(const Locale('en', '')),
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      home: Scaffold(
        body: child,
      ),
    ),
  );
}

Map<int, AttestationState> buildAttestationStateMap(AppStore store, List<dynamic> pubKeys) {
  final map = Map<int, AttestationState>();
  pubKeys.asMap().forEach((i, key) => !(key == store.account.currentAddress)
          ? map.putIfAbsent(i, () => AttestationState(key))
          : store.encointer.myMeetupRegistryIndex = i // track our index as it defines if we must show our qr-code first
      );

  print("My index in meetup registry is " + store.encointer.myMeetupRegistryIndex.toString());
  return map;
}

Future<void> goBackOnePage(WidgetTester tester) async {
  Finder backButton = find.byTooltip('Back');
  if (backButton.evaluate().isEmpty) {
    backButton = find.byType(CupertinoNavigationBarBackButton);
  }

  expect(backButton, findsOneWidget, reason: 'One back button expected on screen');
  await tester.tap(backButton);
  await tester.pumpAndSettle();
}

Future<ScanQrCode> navigateToScanner(
  WidgetTester tester,
) async {
  var scanQrCodeFinder = find.byType(ScanQrCode);
  expect(scanQrCodeFinder, findsOneWidget);

  ScanQrCode scanner = scanQrCodeFinder.evaluate().first.widget;
  return Future.value(scanner);
}

Future<void> navigateToQrCodeAndTapConfirmButton(WidgetTester tester) async {
  var qrCodeFinder = find.byType(QrCode);
  expect(qrCodeFinder, findsOneWidget);
  // make sure that the rounded button, we find is in the QrCode widget
  var strictButtonMatcher = find.descendant(of: qrCodeFinder, matching: find.byType(RoundedButton));
  expect(strictButtonMatcher, findsOneWidget);
  RoundedButton button = strictButtonMatcher.evaluate().first.widget;
  button.onPressed();
  await tester.pumpAndSettle();
}

Future<void> goBackOneAttestationStep(WidgetTester tester) async {
  var backButtonFinder = find.byKey(StateMachineWidget.backButtonKey);
  expect(backButtonFinder, findsOneWidget);
  await tester.tap(find.byKey(StateMachineWidget.backButtonKey));
  await tester.pumpAndSettle();
}

Future<AppStore> setupStore() async {
  AppStore root = globalAppStore;
  root.localStorage = getMockLocalStorage();

  accList = [testAcc];
  currentAccountPubKey = accList[0]['pubKey'];

  await root.init('_en');

  accList.add(endoEncointer);
  root.encointer.attestations = buildAttestationStateMap(root, pubKeys);
  root.encointer.claimHex = claimHex;
  expect(root.encointer.attestations.length, 2);
  return root;
}