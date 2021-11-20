// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chain.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic

mixin _$ChainStore on _ChainStore, Store {
  Computed<dynamic> _$latestHeaderNumberComputed;

  @override
  dynamic get latestHeaderNumber => (_$latestHeaderNumberComputed ??=
          Computed<dynamic>(() => super.latestHeaderNumber, name: '_ChainStore.latestHeaderNumber'))
      .value;

  final _$latestHeaderAtom = Atom(name: '_ChainStore.latestHeader');

  @override
  Header get latestHeader {
    _$latestHeaderAtom.reportRead();
    return super.latestHeader;
  }

  @override
  set latestHeader(Header value) {
    _$latestHeaderAtom.reportWrite(value, super.latestHeader, () {
      super.latestHeader = value;
    });
  }

  final _$_ChainStoreActionController = ActionController(name: '_ChainStore');

  @override
  void setLatestHeader(Header latest) {
    final _$actionInfo = _$_ChainStoreActionController.startAction(name: '_ChainStore.setLatestHeader');
    try {
      return super.setLatestHeader(latest);
    } finally {
      _$_ChainStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
latestHeader: ${latestHeader},
latestHeaderNumber: ${latestHeaderNumber}
    ''';
  }
}
