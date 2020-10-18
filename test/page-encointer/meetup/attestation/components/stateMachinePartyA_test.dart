import 'package:flutter_test/flutter_test.dart';
import 'package:polka_wallet/page-encointer/meetup/attestation/components/stateMachinePartyA.dart';
import 'package:polka_wallet/page-encointer/meetup/attestation/components/stateMachineWidget.dart';
import 'package:polka_wallet/service/substrateApi/api.dart';
import 'package:polka_wallet/store/app.dart';
import 'package:polka_wallet/store/encointer/types/attestationState.dart';

import '../../../../mocks/apiEncointer_mock.dart';
import '../../../../mocks/data/mockEncointerData.dart';
import '../../../../mocks/localStorage_mock.dart';
import 'common.dart';

void main() {
  AppStore root;
  List<dynamic> pubKeys;
  int otherMeetupRegistryIndex = 1;
  StateMachinePartyA stateMachineA;

  setUp(() async {
    root = globalAppStore;
    root.localStorage = getMockLocalStorage();
    await root.init('_en');

    webApi = Api(null, root);
    webApi.encointer = getMockApiEncointer();

    pubKeys = [accList[0], accNew].map((e) => e['pubKey']).toList();
    expect(pubKeys.length, 2);

    root.encointer.attestations = buildAttestationStateMap(root, pubKeys);
    expect(root.encointer.attestations.length, 2);

    stateMachineA = StateMachinePartyA(
      root,
      otherMeetupRegistryIndex: otherMeetupRegistryIndex,
    );
  });

  tearDown(() {
    root = null;
    webApi = null;
  });

  testWidgets('stateMachinePartyA happy flow', (WidgetTester tester) async {
    await tester.pumpWidget(makeTestableWidget(child: stateMachineA));
    expect(find.text(otherMeetupRegistryIndex.toString()), findsOneWidget);

    await _showClaimA(tester, root, otherMeetupRegistryIndex);
    await _scanAttestationAClaimB(tester, root, otherMeetupRegistryIndex);
    await _showAttestationB(tester, root, otherMeetupRegistryIndex);

    // verify that we have finished the attestation procedure
    expect(find.byType(StateMachinePartyA), findsOneWidget);
    expect(
        root.encointer.attestations[otherMeetupRegistryIndex].currentAttestationStep, CurrentAttestationStep.FINISHED);
  });

  group('goBackOneStep', () {
    testWidgets('A2_scanAttAClaimB back to A1_showClaimA', (WidgetTester tester) async {
      await tester.pumpWidget(makeTestableWidget(child: stateMachineA));
      await _showClaimA(tester, root, otherMeetupRegistryIndex);
      await goBackOneAttestationStep(tester);
      expect(
          root.encointer.attestations[otherMeetupRegistryIndex].currentAttestationStep, CurrentAttestationStep.STEP1);
    });
    testWidgets('A3_showAttB back to A2_scanAttAClaimB', (WidgetTester tester) async {
      await tester.pumpWidget(makeTestableWidget(child: stateMachineA));
      await _showClaimA(tester, root, otherMeetupRegistryIndex);
      await _scanAttestationAClaimB(tester, root, otherMeetupRegistryIndex);
      await goBackOneAttestationStep(tester);
      expect(
          root.encointer.attestations[otherMeetupRegistryIndex].currentAttestationStep, CurrentAttestationStep.STEP2);
    });
    testWidgets('finished back to A3_showAttB', (WidgetTester tester) async {
      await tester.pumpWidget(makeTestableWidget(child: stateMachineA));
      await _showClaimA(tester, root, otherMeetupRegistryIndex);
      await _scanAttestationAClaimB(tester, root, otherMeetupRegistryIndex);
      await _showAttestationB(tester, root, otherMeetupRegistryIndex);
      await goBackOneAttestationStep(tester);
      expect(
          root.encointer.attestations[otherMeetupRegistryIndex].currentAttestationStep, CurrentAttestationStep.STEP3);
    });
    testWidgets('finished back to A1_showClaimA', (WidgetTester tester) async {
      await tester.pumpWidget(makeTestableWidget(child: stateMachineA));
      await _showClaimA(tester, root, otherMeetupRegistryIndex);
      await _scanAttestationAClaimB(tester, root, otherMeetupRegistryIndex);
      await _showAttestationB(tester, root, otherMeetupRegistryIndex);
      await goBackOneAttestationStep(tester);
      expect(
          root.encointer.attestations[otherMeetupRegistryIndex].currentAttestationStep, CurrentAttestationStep.STEP3);
      await goBackOneAttestationStep(tester);
      expect(
          root.encointer.attestations[otherMeetupRegistryIndex].currentAttestationStep, CurrentAttestationStep.STEP2);
      await goBackOneAttestationStep(tester);
      expect(
          root.encointer.attestations[otherMeetupRegistryIndex].currentAttestationStep, CurrentAttestationStep.STEP1);
    });
  });
}

Future<void> _showClaimA(WidgetTester tester, AppStore root, int otherMeetupRegistryIndex) async {
  expect(find.byType(StateMachinePartyA), findsOneWidget);
  expect(root.encointer.attestations[otherMeetupRegistryIndex].currentAttestationStep, CurrentAttestationStep.STEP1);
  await tester.tap(find.byKey(StateMachineWidget.nextButtonKey));
  await tester.pumpAndSettle();
  await navigateToQrCodeAndTapConfirmButton(tester);
  expect(root.encointer.attestations[otherMeetupRegistryIndex].currentAttestationStep, CurrentAttestationStep.STEP2);
}

/// mocks AttestationAClaimB scan. Note: Currently, we have no means of really mocking the ScanQrCode widget.
Future<void> _scanAttestationAClaimB(WidgetTester tester, AppStore root, int otherMeetupRegistryIndex) async {
  expect(find.byType(StateMachinePartyA), findsOneWidget);
  expect(root.encointer.attestations[otherMeetupRegistryIndex].currentAttestationStep, CurrentAttestationStep.STEP2);

  // store AttestationA (my claim, attested by other)
  print("Party A: Store my attestation (AttA): " + attestationHex);
  root.encointer.addYourAttestation(otherMeetupRegistryIndex, attestationHex);
  root.encointer.addOtherAttestation(otherMeetupRegistryIndex, attestationHex);
  root.encointer.updateAttestationStep(otherMeetupRegistryIndex, CurrentAttestationStep.STEP3);

  await tester.pumpAndSettle();
  expect(root.encointer.attestations[otherMeetupRegistryIndex].currentAttestationStep, CurrentAttestationStep.STEP3);
}

Future<void> _showAttestationB(WidgetTester tester, AppStore root, int otherMeetupRegistryIndex) async {
  expect(find.byType(StateMachinePartyA), findsOneWidget);
  expect(root.encointer.attestations[otherMeetupRegistryIndex].currentAttestationStep, CurrentAttestationStep.STEP3);
  await tester.tap(find.byKey(StateMachineWidget.nextButtonKey));
  await tester.pumpAndSettle();
  await navigateToQrCodeAndTapConfirmButton(tester);
  expect(root.encointer.attestations[otherMeetupRegistryIndex].currentAttestationStep, CurrentAttestationStep.FINISHED);
}
