import 'package:mobx/mobx.dart';

part 'staking.g.dart';

class StakingStore extends _StakingStore with _$StakingStore {}

abstract class _StakingStore with Store {
  @observable
  ObservableMap<String, dynamic> overview = ObservableMap<String, dynamic>();

  @observable
  bool done = false;

  @computed
  ObservableList<String> get nextUps {
    if (overview['intentions'] == null) {
      return ObservableList<String>();
    }
    List<String> ls = List<String>.from(overview['intentions'].where((i) {
      bool ok = overview['validators'].indexOf(i) < 0;
      return ok;
    }));
    return ObservableList.of(ls);
  }

  @action
  void setOverview(Map<String, dynamic> data) {
    data.keys.forEach((key) => overview[key] = data[key]);
  }
}
