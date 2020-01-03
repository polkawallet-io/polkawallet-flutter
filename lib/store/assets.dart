import 'package:mobx/mobx.dart';
import 'package:json_annotation/json_annotation.dart';

part 'assets.g.dart';

@JsonSerializable()
class AssetsStore extends _AssetsStore with _$AssetsStore {
  AssetsStore(String description) : super(description);
}

abstract class _AssetsStore with Store {
  _AssetsStore(this.description);

  @observable
  String description = '';

  @observable
  bool done = false;
}
