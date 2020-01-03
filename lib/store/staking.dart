import 'package:mobx/mobx.dart';
import 'package:json_annotation/json_annotation.dart';

part 'staking.g.dart';

@JsonSerializable()
class StakingStore extends _StakingStore with _$StakingStore {
  StakingStore(String description) : super(description);
}

abstract class _StakingStore with Store {
  _StakingStore(this.description);

  @observable
  String description = '';

  @observable
  bool done = false;
}
