// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'acala.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic

mixin _$AcalaStore on _AcalaStore, Store {
  final _$loansAtom = Atom(name: '_AcalaStore.loans');

  @override
  Map<String, LoanData> get loans {
    _$loansAtom.context.enforceReadPolicy(_$loansAtom);
    _$loansAtom.reportObserved();
    return super.loans;
  }

  @override
  set loans(Map<String, LoanData> value) {
    _$loansAtom.context.conditionallyRunInAction(() {
      super.loans = value;
      _$loansAtom.reportChanged();
    }, _$loansAtom, name: '${_$loansAtom.name}_set');
  }

  final _$_AcalaStoreActionController = ActionController(name: '_AcalaStore');

  @override
  void setAccountLoans(List data) {
    final _$actionInfo = _$_AcalaStoreActionController.startAction();
    try {
      return super.setAccountLoans(data);
    } finally {
      _$_AcalaStoreActionController.endAction(_$actionInfo);
    }
  }
}

mixin _$LoanData on _LoanData, Store {}
