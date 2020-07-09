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

  final _$_AttestationStateActionController =
      ActionController(name: '_AttestationState');

  @override
  void setAttestation(String att) {
    final _$actionInfo = _$_AttestationStateActionController.startAction(
        name: '_AttestationState.setAttestation');
    try {
      return super.setAttestation(att);
    } finally {
      _$_AttestationStateActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
done: ${done},
yourAttestation: ${yourAttestation}
    ''';
  }
}
