import 'package:mobx/mobx.dart';

part 'bazaarItemVerticalState.g.dart';

class BazaarItemVerticalState = _BazaarItemVerticalState with _$BazaarItemVerticalState;

abstract class _BazaarItemVerticalState with Store {
  @observable
  bool liked = false;

  @action
  void toggleLiked() {
    liked = !liked;
  }
}
