import 'package:mobx/mobx.dart';
import 'package:json_annotation/json_annotation.dart';

part 'profile.g.dart';

@JsonSerializable()
class ProfileStore extends _ProfileStore with _$ProfileStore {
  ProfileStore(String description) : super(description);
}

abstract class _ProfileStore with Store {
  _ProfileStore(this.description);

  @observable
  String description = '';

  @observable
  bool done = false;
}
