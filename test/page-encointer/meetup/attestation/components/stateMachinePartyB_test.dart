import 'package:flutter_test/flutter_test.dart';
import 'package:encointer_wallet/page-encointer/meetup/attestation/components/stateMachinePartyB.dart';
import 'package:encointer_wallet/page-encointer/meetup/attestation/components/stateMachineWidget.dart';
import 'package:encointer_wallet/service/substrateApi/api.dart';
import 'package:encointer_wallet/store/app.dart';
import 'package:encointer_wallet/store/encointer/types/attestationState.dart';

import '../../../../mocks/apiEncointer_mock.dart';
import '../../../../mocks/data/MockAccountData.dart';
import '../../../../mocks/data/mockEncointerData.dart';
import 'common.dart';

void main() {
  AppStore root;
  int otherMeetupRegistryIndex = 0;
  StateMachinePartyB stateMachineB;

  setUp(() async {
    root = await setupStore();

    webApi = Api(null, root);
    webApi.encointer = getMockApiEncointer();

    stateMachineB = StateMachinePartyB(
      root,
      otherMeetupRegistryIndex: otherMeetupRegistryIndex,
      myMeetupRegistryIndex: root.encointer.myMeetupRegistryIndex,
      initialAttestationStep: CurrentAttestationStep.STEP1,
    );
  });

  tearDown(() {
    root = null;
    webApi = null;
  });

  testWidgets('StateMachinePartyB happy flow', (WidgetTester tester) async {
    root.encointer.attestations = buildAttestationStateMap(root, pubKeys);
    await tester.pumpWidget(makeTestableWidget(child: stateMachineB));
    expect(find.text(otherMeetupRegistryIndex.toString()), findsOneWidget);

    await _scanClaimA(tester, root, otherMeetupRegistryIndex);
    await _showAttestationAClaimB(tester, root, otherMeetupRegistryIndex);
    await _scanAttestationB(tester, root, otherMeetupRegistryIndex);

    // verify that we have finished the attestation procedure
    expect(find.byType(StateMachinePartyB), findsOneWidget);
    expect(
        root.encointer.attestations[otherMeetupRegistryIndex].currentAttestationStep, CurrentAttestationStep.FINISHED);
  });

  group('goBackOneStep', () {
    testWidgets('B2_showAttAClaimB back to B1_scanClaimA', (WidgetTester tester) async {
      root.encointer.attestations = buildAttestationStateMap(root, pubKeys);
      await tester.pumpWidget(makeTestableWidget(child: stateMachineB));
      await _scanClaimA(tester, root, otherMeetupRegistryIndex);
      await goBackOneAttestationStep(tester);
      expect(
          root.encointer.attestations[otherMeetupRegistryIndex].currentAttestationStep, CurrentAttestationStep.STEP1);
    });
    testWidgets('B3_scanAttB  back to B2_showAttAClaimB', (WidgetTester tester) async {
      root.encointer.attestations = buildAttestationStateMap(root, pubKeys);
      await tester.pumpWidget(makeTestableWidget(child: stateMachineB));
      await _scanClaimA(tester, root, otherMeetupRegistryIndex);
      await _showAttestationAClaimB(tester, root, otherMeetupRegistryIndex);
      await goBackOneAttestationStep(tester);
      expect(
          root.encointer.attestations[otherMeetupRegistryIndex].currentAttestationStep, CurrentAttestationStep.STEP2);
    });
    testWidgets('finished back to B3_scanAttB', (WidgetTester tester) async {
      root.encointer.attestations = buildAttestationStateMap(root, pubKeys);
      await tester.pumpWidget(makeTestableWidget(child: stateMachineB));
      await _scanClaimA(tester, root, otherMeetupRegistryIndex);
      await _showAttestationAClaimB(tester, root, otherMeetupRegistryIndex);
      await _scanAttestationB(tester, root, otherMeetupRegistryIndex);
      await goBackOneAttestationStep(tester);
      expect(
          root.encointer.attestations[otherMeetupRegistryIndex].currentAttestationStep, CurrentAttestationStep.STEP3);
    });
    testWidgets('finished back to B1_scanClaimA', (WidgetTester tester) async {
      root.encointer.attestations = buildAttestationStateMap(root, pubKeys);
      await tester.pumpWidget(makeTestableWidget(child: stateMachineB));
      await _scanClaimA(tester, root, otherMeetupRegistryIndex);
      await _showAttestationAClaimB(tester, root, otherMeetupRegistryIndex);
      await _scanAttestationB(tester, root, otherMeetupRegistryIndex);
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

Future<void> _scanClaimA(WidgetTester tester, AppStore root, int otherMeetupRegistryIndex) async {
  expect(find.byType(StateMachinePartyB), findsOneWidget);
  expect(root.encointer.attestations[otherMeetupRegistryIndex].currentAttestationStep, CurrentAttestationStep.STEP1);

  root.encointer.addOtherAttestation(otherMeetupRegistryIndex, attestationHex);
  root.encointer.updateAttestationStep(otherMeetupRegistryIndex, CurrentAttestationStep.STEP2);
  await tester.pumpAndSettle();

  expect(root.encointer.attestations[otherMeetupRegistryIndex].currentAttestationStep, CurrentAttestationStep.STEP2);
}

Future<void> _showAttestationAClaimB(WidgetTester tester, AppStore root, int otherMeetupRegistryIndex) async {
  expect(find.byType(StateMachinePartyB), findsOneWidget);
  expect(root.encointer.attestations[otherMeetupRegistryIndex].currentAttestationStep, CurrentAttestationStep.STEP2);
  await tester.tap(find.byKey(StateMachineWidget.nextButtonKey));
  await tester.pumpAndSettle();
  await navigateToQrCodeAndTapConfirmButton(tester);
  expect(root.encointer.attestations[otherMeetupRegistryIndex].currentAttestationStep, CurrentAttestationStep.STEP3);
}

Future<void> _scanAttestationB(WidgetTester tester, AppStore root, int otherMeetupRegistryIndex) async {
  expect(find.byType(StateMachinePartyB), findsOneWidget);
  expect(root.encointer.attestations[otherMeetupRegistryIndex].currentAttestationStep, CurrentAttestationStep.STEP3);

  root.encointer.addYourAttestation(otherMeetupRegistryIndex, attestationHex);
  root.encointer.updateAttestationStep(otherMeetupRegistryIndex, CurrentAttestationStep.FINISHED);
  await tester.pumpAndSettle();

  expect(root.encointer.attestations[otherMeetupRegistryIndex].currentAttestationStep, CurrentAttestationStep.FINISHED);
}
