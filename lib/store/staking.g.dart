// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'staking.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic

mixin _$StakingStore on _StakingStore, Store {
  Computed<ObservableList<String>> _$nextUpsComputed;

  @override
  ObservableList<String> get nextUps => (_$nextUpsComputed ??=
          Computed<ObservableList<String>>(() => super.nextUps))
      .value;

  final _$overviewAtom = Atom(name: '_StakingStore.overview');

  @override
  ObservableMap<String, dynamic> get overview {
    _$overviewAtom.context.enforceReadPolicy(_$overviewAtom);
    _$overviewAtom.reportObserved();
    return super.overview;
  }

  @override
  set overview(ObservableMap<String, dynamic> value) {
    _$overviewAtom.context.conditionallyRunInAction(() {
      super.overview = value;
      _$overviewAtom.reportChanged();
    }, _$overviewAtom, name: '${_$overviewAtom.name}_set');
  }

  final _$doneAtom = Atom(name: '_StakingStore.done');

  @override
  bool get done {
    _$doneAtom.context.enforceReadPolicy(_$doneAtom);
    _$doneAtom.reportObserved();
    return super.done;
  }

  @override
  set done(bool value) {
    _$doneAtom.context.conditionallyRunInAction(() {
      super.done = value;
      _$doneAtom.reportChanged();
    }, _$doneAtom, name: '${_$doneAtom.name}_set');
  }

  final _$_StakingStoreActionController =
      ActionController(name: '_StakingStore');

  @override
  void setOverview(Map<String, dynamic> data) {
    final _$actionInfo = _$_StakingStoreActionController.startAction();
    try {
      return super.setOverview(data);
    } finally {
      _$_StakingStoreActionController.endAction(_$actionInfo);
    }
  }
}
