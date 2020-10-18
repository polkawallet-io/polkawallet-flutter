import 'dart:convert';

import 'package:mobx/mobx.dart';

part 'attestationState.g.dart';

class AttestationState = _AttestationState with _$AttestationState;

abstract class _AttestationState with Store {
  _AttestationState(this.pubKey);
  String pubKey;

  @observable
  bool done = false;

  // your claim, attested by other
  @observable
  String yourAttestation;

  // other claim, attested by me
  @observable
  String otherAttestation;

  @observable
  CurrentAttestationStep currentAttestationStep = CurrentAttestationStep.STEP1;

  @override
  String toString() {
    return jsonEncode(this);
  }

  @action
  void setYourAttestation(String att) {
    yourAttestation = att;
    done = true;
    print("attestation done for " + pubKey);
  }

  @action
  void setOtherAttestation(String att) {
    otherAttestation = att;
    print("set your attestation for other: " + pubKey);
  }

  @action
  void setAttestationStep(CurrentAttestationStep step) {
    currentAttestationStep = step;
  }
}

enum CurrentAttestationStep { STEP1, STEP2, STEP3, FINISHED }
