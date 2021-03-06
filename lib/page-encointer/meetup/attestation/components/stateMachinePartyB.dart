import 'package:encointer_wallet/common/components/activityIndicator.dart';
import 'package:encointer_wallet/page-encointer/meetup/attestation/components/qrCode.dart';
import 'package:encointer_wallet/page-encointer/meetup/attestation/components/scanQrCode.dart';
import 'package:encointer_wallet/page-encointer/meetup/attestation/components/stateMachineWidget.dart';
import 'package:encointer_wallet/service/substrateApi/api.dart';
import 'package:encointer_wallet/store/app.dart';
import 'package:encointer_wallet/store/encointer/types/attestation.dart';
import 'package:encointer_wallet/store/encointer/types/attestationState.dart';
import 'package:encointer_wallet/utils/i18n/index.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';

class StateMachinePartyB extends StatefulWidget {
  StateMachinePartyB(
    this.store, {
    this.otherMeetupRegistryIndex,
    this.myMeetupRegistryIndex,
    this.initialAttestationStep,
  }) : super();

  final AppStore store;
  final int otherMeetupRegistryIndex;
  final int myMeetupRegistryIndex;
  final CurrentAttestationStep initialAttestationStep;

  @override
  _StateMachinePartyBState createState() {
    return _StateMachinePartyBState(store);
  }
}

class _StateMachinePartyBState extends State<StateMachinePartyB> {
  _StateMachinePartyBState(this.store);

  final AppStore store;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  _scanClaimA() async {
    print("Party B: Scanning others' claimA now");
    String claimA = await Navigator.of(context).push(
      MaterialPageRoute<String>(
        builder: (BuildContext context) => ScanQrCode(instruction: "scan claimA"),
      ),
    );
    // is null if back button pressed
    if (claimA != null) {
      await _attestClaimA(claimA);
    }
  }

  _attestClaimA(String claimAhex) async {
    print("Party B: Received other claim (ClaimA): " + claimAhex.toString());

    // TODO: compare claimA to own. only sign valid claims. complain in UI and show differences otherwise
    // var claimA = await webApi.encointer.parseClaimOfAttendance(claimAhex);
    // print("ClaimA parsed: " + claimA.toString());
    //
    AttestationResult attestationA = await Navigator.of(context).push(
      PageRouteBuilder<AttestationResult>(
        opaque: false,
        pageBuilder: (BuildContext context, _, __) {
          return ActivityIndicator(
            title: "Attesting ClaimA",
            future: webApi.encointer.attestClaimOfAttendance(claimAhex, store.account.cachedPin),
          );
        },
      ),
    );

    print("Party B: Other attestation (AttA): " + attestationA.attestation.toString());
    // currently, parsing attestation fails, as it is returned as an `Attestation` from the js_service which implies the the location is in I32F32
    //      store.encointer.attestations[widget.otherMeetupRegistryIndex].otherAttestation = Attestation.fromJson(attestationA['attestation']);
    // print("Attestation: " + attestationA.toString());

    // store AttestationA (other claim, attested by me)
    print("Party B: Other attestationHex (AttA): " + attestationA.attestationHex);
    store.encointer.addOtherAttestation(widget.otherMeetupRegistryIndex, attestationA.attestationHex);
    store.encointer.updateAttestationStep(widget.otherMeetupRegistryIndex, CurrentAttestationStep.STEP2);
    print('Updated Attestation Step: ${CurrentAttestationStep.STEP2.toString()}');
  }

  _showAttAClaimB() async {
    String attA = store.encointer.attestations[widget.otherMeetupRegistryIndex].otherAttestation;
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (BuildContext context) => QrCode(
          store,
          title: 'AttestationA | claimB',
          qrCodeData: '$attA:${store.encointer.claimHex}',
        ),
      ),
    );
    store.encointer.updateAttestationStep(widget.otherMeetupRegistryIndex, CurrentAttestationStep.STEP3);
    print('Updated Attestation Step: ${CurrentAttestationStep.STEP3.toString()}');
  }

  _scanAttestationB() async {
    String attB = await Navigator.of(context).push(
      MaterialPageRoute<String>(
        builder: (BuildContext context) => ScanQrCode(instruction: "scan attestationB"),
      ),
    );
    // is null if back button pressed
    if (attB != null) {
      await _onScanAttB(attB);
    }
  }

  _onScanAttB(String attB) {
    print("Received AttestastionB: " + attB.toString());

    // TODO: verify signature and complain in UI if bad
    // var attestationB = await webApi.encointer.parseAttestation(attB);
    // print("attestationB parsed: " + attestationB.toString());

    // store AttestationB (my claim, attested by other)
    store.encointer.addYourAttestation(widget.otherMeetupRegistryIndex, attB.toString());
    store.encointer.updateAttestationStep(widget.otherMeetupRegistryIndex, CurrentAttestationStep.FINISHED);
    print('Updated Attestation Step: ${CurrentAttestationStep.FINISHED.toString()}');
  }

  @override
  Widget build(BuildContext context) {
    String other = store.encointer.attestations[widget.otherMeetupRegistryIndex].pubKey;

    return Observer(
      builder: (BuildContext context) => StateMachineWidget(
        otherParty: other,
        otherMeetupRegistryIndex: widget.otherMeetupRegistryIndex,
        myMeetupRegistryIndex: widget.myMeetupRegistryIndex,
        onBackward: () =>
            _goBackOneStep(store.encointer.attestations[widget.otherMeetupRegistryIndex].currentAttestationStep),
        onForward: () => _getCurrentAttestationStep(
            store.encointer.attestations[widget.otherMeetupRegistryIndex].currentAttestationStep),
        onForwardText: _nextStep(store.encointer.attestations[widget.otherMeetupRegistryIndex].currentAttestationStep),
      ),
    );
  }

  _updateAttestationStep(CurrentAttestationStep step) {
    store.encointer.updateAttestationStep(widget.otherMeetupRegistryIndex, step);
    print('Updated Attestation Step: ${step.toString()}');
  }

  String _nextStep(CurrentAttestationStep step) {
    final Map dic = I18n.of(context).encointer;
    switch (step) {
      case CurrentAttestationStep.STEP1:
        {
          return dic['attestation.partyB.step1'];
        }
      case CurrentAttestationStep.STEP2:
        {
          return dic['attestation.partyB.step2'];
        }
      case CurrentAttestationStep.STEP3:
        {
          return dic['attestation.partyB.step3'];
        }
      case CurrentAttestationStep.FINISHED:
        {
          return dic['finish'];
        }
      default:
        {
          return "attestation step not defined";
        }
    }
  }

  void _goBackOneStep(CurrentAttestationStep step) {
    switch (step) {
      case CurrentAttestationStep.STEP1:
        {
          Navigator.of(context).pop();
          return;
        }
      case CurrentAttestationStep.STEP2:
        {
          _updateAttestationStep(CurrentAttestationStep.STEP1);
          return;
        }
      case CurrentAttestationStep.STEP3:
        {
          _updateAttestationStep(CurrentAttestationStep.STEP2);
          return;
        }
      case CurrentAttestationStep.FINISHED:
        {
          _updateAttestationStep(CurrentAttestationStep.STEP3);
          return;
        }
    }
  }

  _getCurrentAttestationStep(CurrentAttestationStep step) {
    switch (step) {
      case CurrentAttestationStep.STEP1:
        {
          return _scanClaimA();
        }
      case CurrentAttestationStep.STEP2:
        {
          return _showAttAClaimB();
        }
      case CurrentAttestationStep.STEP3:
        {
          return _scanAttestationB();
        }
      case CurrentAttestationStep.FINISHED:
        {
          Navigator.of(context).pop();
          break;
        }
    }
  }
}
