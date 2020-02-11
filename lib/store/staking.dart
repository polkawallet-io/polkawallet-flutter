import 'package:mobx/mobx.dart';
import 'package:json_annotation/json_annotation.dart';

part 'staking.g.dart';

class StakingStore extends _StakingStore with _$StakingStore {}

abstract class _StakingStore with Store {
  @observable
  String description = '';

  @observable
  bool done = false;
}
