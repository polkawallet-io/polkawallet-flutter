// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'governance.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CouncilInfo _$CouncilInfoFromJson(Map<String, dynamic> json) {
  return CouncilInfo()
    ..desiredSeats = json['desiredSeats'] as int
    ..termDuration = json['termDuration'] as int
    ..votingBond = json['votingBond'] as int
    ..members = (json['members'] as List)
        ?.map((e) => (e as List)?.map((e) => e as String)?.toList())
        ?.toList()
    ..runnersUp = (json['runnersUp'] as List)
        ?.map((e) => (e as List)?.map((e) => e as String)?.toList())
        ?.toList()
    ..candidates = (json['candidates'] as List)
        ?.map((e) => (e as List)?.map((e) => e as String)?.toList())
        ?.toList()
    ..candidateCount = json['candidateCount'] as int
    ..candidacyBond = json['candidacyBond'] as int;
}

Map<String, dynamic> _$CouncilInfoToJson(CouncilInfo instance) =>
    <String, dynamic>{
      'desiredSeats': instance.desiredSeats,
      'termDuration': instance.termDuration,
      'votingBond': instance.votingBond,
      'members': instance.members,
      'runnersUp': instance.runnersUp,
      'candidates': instance.candidates,
      'candidateCount': instance.candidateCount,
      'candidacyBond': instance.candidacyBond,
    };

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic

mixin _$GovernanceStore on _GovernanceStore, Store {
  final _$councilAtom = Atom(name: '_GovernanceStore.council');

  @override
  CouncilInfo get council {
    _$councilAtom.context.enforceReadPolicy(_$councilAtom);
    _$councilAtom.reportObserved();
    return super.council;
  }

  @override
  set council(CouncilInfo value) {
    _$councilAtom.context.conditionallyRunInAction(() {
      super.council = value;
      _$councilAtom.reportChanged();
    }, _$councilAtom, name: '${_$councilAtom.name}_set');
  }

  final _$_GovernanceStoreActionController =
      ActionController(name: '_GovernanceStore');

  @override
  void setCouncilInfo(Map info) {
    final _$actionInfo = _$_GovernanceStoreActionController.startAction();
    try {
      return super.setCouncilInfo(info);
    } finally {
      _$_GovernanceStoreActionController.endAction(_$actionInfo);
    }
  }
}

mixin _$CouncilInfo on _CouncilInfo, Store {}
