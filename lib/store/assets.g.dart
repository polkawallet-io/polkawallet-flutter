// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'assets.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AssetsStore _$AssetsStoreFromJson(Map<String, dynamic> json) {
  return AssetsStore()
    ..description = json['description'] as String
    ..newAccount = json['newAccount'] == null
        ? null
        : Account.fromJson(json['newAccount'] as Map<String, dynamic>);
}

Map<String, dynamic> _$AssetsStoreToJson(AssetsStore instance) =>
    <String, dynamic>{
      'description': instance.description,
      'newAccount': instance.newAccount,
    };

Account _$AccountFromJson(Map<String, dynamic> json) {
  return Account()
    ..address = json['address'] as String
    ..isLocked = json['isLocked'] as bool
    ..mnemonic = json['mnemonic'] as String
    ..seed = json['seed'] as String;
}

Map<String, dynamic> _$AccountToJson(Account instance) => <String, dynamic>{
      'address': instance.address,
      'isLocked': instance.isLocked,
      'mnemonic': instance.mnemonic,
      'seed': instance.seed,
    };

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic

mixin _$AssetsStore on _AssetsStore, Store {
  final _$descriptionAtom = Atom(name: '_AssetsStore.description');

  @override
  String get description {
    _$descriptionAtom.context.enforceReadPolicy(_$descriptionAtom);
    _$descriptionAtom.reportObserved();
    return super.description;
  }

  @override
  set description(String value) {
    _$descriptionAtom.context.conditionallyRunInAction(() {
      super.description = value;
      _$descriptionAtom.reportChanged();
    }, _$descriptionAtom, name: '${_$descriptionAtom.name}_set');
  }

  final _$newAccountAtom = Atom(name: '_AssetsStore.newAccount');

  @override
  Account get newAccount {
    _$newAccountAtom.context.enforceReadPolicy(_$newAccountAtom);
    _$newAccountAtom.reportObserved();
    return super.newAccount;
  }

  @override
  set newAccount(Account value) {
    _$newAccountAtom.context.conditionallyRunInAction(() {
      super.newAccount = value;
      _$newAccountAtom.reportChanged();
    }, _$newAccountAtom, name: '${_$newAccountAtom.name}_set');
  }

  final _$setNewAccountAsyncAction = AsyncAction('setNewAccount');

  @override
  Future<dynamic> setNewAccount(Map<String, dynamic> res) {
    return _$setNewAccountAsyncAction.run(() => super.setNewAccount(res));
  }
}

mixin _$Account on _Account, Store {
  final _$addressAtom = Atom(name: '_Account.address');

  @override
  String get address {
    _$addressAtom.context.enforceReadPolicy(_$addressAtom);
    _$addressAtom.reportObserved();
    return super.address;
  }

  @override
  set address(String value) {
    _$addressAtom.context.conditionallyRunInAction(() {
      super.address = value;
      _$addressAtom.reportChanged();
    }, _$addressAtom, name: '${_$addressAtom.name}_set');
  }

  final _$isLockedAtom = Atom(name: '_Account.isLocked');

  @override
  bool get isLocked {
    _$isLockedAtom.context.enforceReadPolicy(_$isLockedAtom);
    _$isLockedAtom.reportObserved();
    return super.isLocked;
  }

  @override
  set isLocked(bool value) {
    _$isLockedAtom.context.conditionallyRunInAction(() {
      super.isLocked = value;
      _$isLockedAtom.reportChanged();
    }, _$isLockedAtom, name: '${_$isLockedAtom.name}_set');
  }

  final _$mnemonicAtom = Atom(name: '_Account.mnemonic');

  @override
  String get mnemonic {
    _$mnemonicAtom.context.enforceReadPolicy(_$mnemonicAtom);
    _$mnemonicAtom.reportObserved();
    return super.mnemonic;
  }

  @override
  set mnemonic(String value) {
    _$mnemonicAtom.context.conditionallyRunInAction(() {
      super.mnemonic = value;
      _$mnemonicAtom.reportChanged();
    }, _$mnemonicAtom, name: '${_$mnemonicAtom.name}_set');
  }

  final _$seedAtom = Atom(name: '_Account.seed');

  @override
  String get seed {
    _$seedAtom.context.enforceReadPolicy(_$seedAtom);
    _$seedAtom.reportObserved();
    return super.seed;
  }

  @override
  set seed(String value) {
    _$seedAtom.context.conditionallyRunInAction(() {
      super.seed = value;
      _$seedAtom.reportChanged();
    }, _$seedAtom, name: '${_$seedAtom.name}_set');
  }
}
