import 'package:mobx/mobx.dart';

part 'democracy.g.dart';

class DemocracyStore extends _DemocracyStore with _$DemocracyStore {}

abstract class _DemocracyStore with Store {
  @observable
  String description = '';

  @observable
  bool done = false;
}
