// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'acala.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic

mixin _$AcalaStore on _AcalaStore, Store {
  final _$loanTypesAtom = Atom(name: '_AcalaStore.loanTypes');

  @override
  List<LoanType> get loanTypes {
    _$loanTypesAtom.context.enforceReadPolicy(_$loanTypesAtom);
    _$loanTypesAtom.reportObserved();
    return super.loanTypes;
  }

  @override
  set loanTypes(List<LoanType> value) {
    _$loanTypesAtom.context.conditionallyRunInAction(() {
      super.loanTypes = value;
      _$loanTypesAtom.reportChanged();
    }, _$loanTypesAtom, name: '${_$loanTypesAtom.name}_set');
  }

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

  final _$pricesAtom = Atom(name: '_AcalaStore.prices');

  @override
  Map<String, BigInt> get prices {
    _$pricesAtom.context.enforceReadPolicy(_$pricesAtom);
    _$pricesAtom.reportObserved();
    return super.prices;
  }

  @override
  set prices(Map<String, BigInt> value) {
    _$pricesAtom.context.conditionallyRunInAction(() {
      super.prices = value;
      _$pricesAtom.reportChanged();
    }, _$pricesAtom, name: '${_$pricesAtom.name}_set');
  }

  final _$txsAtom = Atom(name: '_AcalaStore.txs');

  @override
  ObservableList<TxLoanData> get txs {
    _$txsAtom.context.enforceReadPolicy(_$txsAtom);
    _$txsAtom.reportObserved();
    return super.txs;
  }

  @override
  set txs(ObservableList<TxLoanData> value) {
    _$txsAtom.context.conditionallyRunInAction(() {
      super.txs = value;
      _$txsAtom.reportChanged();
    }, _$txsAtom, name: '${_$txsAtom.name}_set');
  }

  final _$txsLoadingAtom = Atom(name: '_AcalaStore.txsLoading');

  @override
  bool get txsLoading {
    _$txsLoadingAtom.context.enforceReadPolicy(_$txsLoadingAtom);
    _$txsLoadingAtom.reportObserved();
    return super.txsLoading;
  }

  @override
  set txsLoading(bool value) {
    _$txsLoadingAtom.context.conditionallyRunInAction(() {
      super.txsLoading = value;
      _$txsLoadingAtom.reportChanged();
    }, _$txsLoadingAtom, name: '${_$txsLoadingAtom.name}_set');
  }

  final _$_AcalaStoreActionController = ActionController(name: '_AcalaStore');

  @override
  void setAccountLoans(List list) {
    final _$actionInfo = _$_AcalaStoreActionController.startAction();
    try {
      return super.setAccountLoans(list);
    } finally {
      _$_AcalaStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setLoanTypes(List list) {
    final _$actionInfo = _$_AcalaStoreActionController.startAction();
    try {
      return super.setLoanTypes(list);
    } finally {
      _$_AcalaStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setPrices(List list) {
    final _$actionInfo = _$_AcalaStoreActionController.startAction();
    try {
      return super.setPrices(list);
    } finally {
      _$_AcalaStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setLoanTxs(List list, {bool reset = false}) {
    final _$actionInfo = _$_AcalaStoreActionController.startAction();
    try {
      return super.setLoanTxs(list, reset: reset);
    } finally {
      _$_AcalaStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setTxsLoading(bool loading) {
    final _$actionInfo = _$_AcalaStoreActionController.startAction();
    try {
      return super.setTxsLoading(loading);
    } finally {
      _$_AcalaStoreActionController.endAction(_$actionInfo);
    }
  }
}

mixin _$LoanData on _LoanData, Store {}

mixin _$LoanType on _LoanType, Store {}

mixin _$TxLoanData on _TxLoanData, Store {}
