// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'acala.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic

mixin _$AcalaStore on _AcalaStore, Store {
  final _$testAtom = Atom(name: '_AcalaStore.test');

  @override
  String get test {
    _$testAtom.context.enforceReadPolicy(_$testAtom);
    _$testAtom.reportObserved();
    return super.test;
  }

  @override
  set test(String value) {
    _$testAtom.context.conditionallyRunInAction(() {
      super.test = value;
      _$testAtom.reportChanged();
    }, _$testAtom, name: '${_$testAtom.name}_set');
  }
}
