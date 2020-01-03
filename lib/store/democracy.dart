import 'package:mobx/mobx.dart';
import 'package:json_annotation/json_annotation.dart';

part 'democracy.g.dart';

@JsonSerializable()
class DemocracyStore extends _DemocracyStore with _$DemocracyStore {
  DemocracyStore(String description) : super(description);
}

abstract class _DemocracyStore with Store {
  _DemocracyStore(this.description);

  @observable
  String description = '';

  @observable
  bool done = false;
}
