// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'attestationState.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic

mixin _$AttestationState on _AttestationState, Store {
  final _$doneAtom = Atom(name: '_AttestationState.done');

  @override
  bool get done {
    _$doneAtom.reportRead();
    return super.done;
  }

  @override
  set done(bool value) {
    _$doneAtom.reportWrite(value, super.done, () {
      super.done = value;
    });
  }

  final _$yourAttestationAtom = Atom(name: '_AttestationState.yourAttestation');

  @override
  String get yourAttestation {
    _$yourAttestationAtom.reportRead();
    return super.yourAttestation;
  }

  @override
  set yourAttestation(String value) {
    _$yourAttestationAtom.reportWrite(value, super.yourAttestation, () {
      super.yourAttestation = value;
    });
  }

  final _$otherAttestationAtom =
      Atom(name: '_AttestationState.otherAttestation');

  @override
  String get otherAttestation {
    _$otherAttestationAtom.reportRead();
    return super.otherAttestation;
  }

  @override
  set otherAttestation(String value) {
    _$otherAttestationAtom.reportWrite(value, super.otherAttestation, () {
      super.otherAttestation = value;
    });
  }

  final _$currentAttestationStepAtom =
      Atom(name: '_AttestationState.currentAttestationStep');

  @override
  CurrentAttestationStep get currentAttestationStep {
    _$currentAttestationStepAtom.reportRead();
    return super.currentAttestationStep;
  }

  @override
  set currentAttestationStep(CurrentAttestationStep value) {
    _$currentAttestationStepAtom
        .reportWrite(value, super.currentAttestationStep, () {
      super.currentAttestationStep = value;
    });
  }

  final _$_AttestationStateActionController =
      ActionController(name: '_AttestationState');

  @override
  void setYourAttestation(String att) {
    final _$actionInfo = _$_AttestationStateActionController.startAction(
        name: '_AttestationState.setYourAttestation');
    try {
      return super.setYourAttestation(att);
    } finally {
      _$_AttestationStateActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setOtherAttestation(String att) {
    final _$actionInfo = _$_AttestationStateActionController.startAction(
        name: '_AttestationState.setOtherAttestation');
    try {
      return super.setOtherAttestation(att);
    } finally {
      _$_AttestationStateActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setAttestationStep(CurrentAttestationStep step) {
    final _$actionInfo = _$_AttestationStateActionController.startAction(
        name: '_AttestationState.setAttestationStep');
    try {
      return super.setAttestationStep(step);
    } finally {
      _$_AttestationStateActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
done: ${done},
yourAttestation: ${yourAttestation},
otherAttestation: ${otherAttestation},
currentAttestationStep: ${currentAttestationStep}
    ''';
  }
}
