
import 'package:mobx/mobx.dart';
import 'package:polka_wallet/common/components/passwordInputDialog.dart';

import 'attestation.dart';
import 'claimOfAttendance.dart';

part 'attestationState.g.dart';

class AttestationState = _AttestationState with _$AttestationState;

abstract class _AttestationState with Store {
  _AttestationState(this.pubKey);
  String pubKey;

  @observable
  bool done = false;

  @observable
  String yourAttestation;

  @action
  void setAttestation(String att) {
    yourAttestation = att;
    done = true;
    print("attestation done for " + pubKey);
  }

}