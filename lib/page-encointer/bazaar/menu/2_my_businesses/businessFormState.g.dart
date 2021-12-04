// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'businessFormState.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic

mixin _$BusinessFormState on _BusinessFormState, Store {
  final _$nameAtom = Atom(name: '_BusinessFormState.name');

  @override
  String get name {
    _$nameAtom.reportRead();
    return super.name;
  }

  @override
  set name(String value) {
    _$nameAtom.reportWrite(value, super.name, () {
      super.name = value;
    });
  }

  final _$descriptionAtom = Atom(name: '_BusinessFormState.description');

  @override
  String get description {
    _$descriptionAtom.reportRead();
    return super.description;
  }

  @override
  set description(String value) {
    _$descriptionAtom.reportWrite(value, super.description, () {
      super.description = value;
    });
  }

  final _$streetAtom = Atom(name: '_BusinessFormState.street');

  @override
  String get street {
    _$streetAtom.reportRead();
    return super.street;
  }

  @override
  set street(String value) {
    _$streetAtom.reportWrite(value, super.street, () {
      super.street = value;
    });
  }

  final _$streetAddendumAtom = Atom(name: '_BusinessFormState.streetAddendum');

  @override
  String get streetAddendum {
    _$streetAddendumAtom.reportRead();
    return super.streetAddendum;
  }

  @override
  set streetAddendum(String value) {
    _$streetAddendumAtom.reportWrite(value, super.streetAddendum, () {
      super.streetAddendum = value;
    });
  }

  final _$zipCodeAtom = Atom(name: '_BusinessFormState.zipCode');

  @override
  String get zipCode {
    _$zipCodeAtom.reportRead();
    return super.zipCode;
  }

  @override
  set zipCode(String value) {
    _$zipCodeAtom.reportWrite(value, super.zipCode, () {
      super.zipCode = value;
    });
  }

  final _$cityAtom = Atom(name: '_BusinessFormState.city');

  @override
  String get city {
    _$cityAtom.reportRead();
    return super.city;
  }

  @override
  set city(String value) {
    _$cityAtom.reportWrite(value, super.city, () {
      super.city = value;
    });
  }

  final _$_BusinessFormStateActionController = ActionController(name: '_BusinessFormState');

  @override
  void validateName(dynamic value) {
    final _$actionInfo = _$_BusinessFormStateActionController.startAction(name: '_BusinessFormState.validateName');
    try {
      return super.validateName(value);
    } finally {
      _$_BusinessFormStateActionController.endAction(_$actionInfo);
    }
  }

  @override
  void validateDescription(dynamic value) {
    final _$actionInfo =
        _$_BusinessFormStateActionController.startAction(name: '_BusinessFormState.validateDescription');
    try {
      return super.validateDescription(value);
    } finally {
      _$_BusinessFormStateActionController.endAction(_$actionInfo);
    }
  }

  @override
  void validateStreet(dynamic value) {
    final _$actionInfo = _$_BusinessFormStateActionController.startAction(name: '_BusinessFormState.validateStreet');
    try {
      return super.validateStreet(value);
    } finally {
      _$_BusinessFormStateActionController.endAction(_$actionInfo);
    }
  }

  @override
  void validateStreetAddendum(dynamic value) {
    final _$actionInfo =
        _$_BusinessFormStateActionController.startAction(name: '_BusinessFormState.validateStreetAddendum');
    try {
      return super.validateStreetAddendum(value);
    } finally {
      _$_BusinessFormStateActionController.endAction(_$actionInfo);
    }
  }

  @override
  void validateZipCode(dynamic value) {
    final _$actionInfo = _$_BusinessFormStateActionController.startAction(name: '_BusinessFormState.validateZipCode');
    try {
      return super.validateZipCode(value);
    } finally {
      _$_BusinessFormStateActionController.endAction(_$actionInfo);
    }
  }

  @override
  void validateCity(dynamic value) {
    final _$actionInfo = _$_BusinessFormStateActionController.startAction(name: '_BusinessFormState.validateCity');
    try {
      return super.validateCity(value);
    } finally {
      _$_BusinessFormStateActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
name: ${name},
description: ${description},
street: ${street},
streetAddendum: ${streetAddendum},
zipCode: ${zipCode},
city: ${city}
    ''';
  }
}

mixin _$BusinessFormErrorState on _BusinessFormErrorState, Store {
  Computed<bool> _$hasErrorsComputed;

  @override
  bool get hasErrors =>
      (_$hasErrorsComputed ??= Computed<bool>(() => super.hasErrors, name: '_BusinessFormErrorState.hasErrors')).value;

  final _$nameAtom = Atom(name: '_BusinessFormErrorState.name');

  @override
  String get name {
    _$nameAtom.reportRead();
    return super.name;
  }

  @override
  set name(String value) {
    _$nameAtom.reportWrite(value, super.name, () {
      super.name = value;
    });
  }

  final _$descriptionAtom = Atom(name: '_BusinessFormErrorState.description');

  @override
  String get description {
    _$descriptionAtom.reportRead();
    return super.description;
  }

  @override
  set description(String value) {
    _$descriptionAtom.reportWrite(value, super.description, () {
      super.description = value;
    });
  }

  final _$streetAtom = Atom(name: '_BusinessFormErrorState.street');

  @override
  String get street {
    _$streetAtom.reportRead();
    return super.street;
  }

  @override
  set street(String value) {
    _$streetAtom.reportWrite(value, super.street, () {
      super.street = value;
    });
  }

  final _$streetAddendumAtom = Atom(name: '_BusinessFormErrorState.streetAddendum');

  @override
  String get streetAddendum {
    _$streetAddendumAtom.reportRead();
    return super.streetAddendum;
  }

  @override
  set streetAddendum(String value) {
    _$streetAddendumAtom.reportWrite(value, super.streetAddendum, () {
      super.streetAddendum = value;
    });
  }

  final _$zipCodeAtom = Atom(name: '_BusinessFormErrorState.zipCode');

  @override
  String get zipCode {
    _$zipCodeAtom.reportRead();
    return super.zipCode;
  }

  @override
  set zipCode(String value) {
    _$zipCodeAtom.reportWrite(value, super.zipCode, () {
      super.zipCode = value;
    });
  }

  final _$cityAtom = Atom(name: '_BusinessFormErrorState.city');

  @override
  String get city {
    _$cityAtom.reportRead();
    return super.city;
  }

  @override
  set city(String value) {
    _$cityAtom.reportWrite(value, super.city, () {
      super.city = value;
    });
  }

  @override
  String toString() {
    return '''
name: ${name},
description: ${description},
street: ${street},
streetAddendum: ${streetAddendum},
zipCode: ${zipCode},
city: ${city},
hasErrors: ${hasErrors}
    ''';
  }
}
