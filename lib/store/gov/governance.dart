import 'package:mobx/mobx.dart';
import 'package:polka_wallet/store/app.dart';
import 'package:polka_wallet/store/gov/types/referendumInfoData.dart';
import 'package:polka_wallet/store/gov/types/councilInfoData.dart';

part 'governance.g.dart';

class GovernanceStore extends _GovernanceStore with _$GovernanceStore {
  GovernanceStore(AppStore store) : super(store);
}

abstract class _GovernanceStore with Store {
  _GovernanceStore(this.rootStore);

  final AppStore rootStore;

  final String cacheCouncilKey = 'council';

  String _getCacheKey(String key) {
    return '${rootStore.settings.endpoint.info}_$key';
  }

  @observable
  int cacheCouncilTimestamp = 0;

  @observable
  int bestNumber = 0;

  @observable
  CouncilInfoData council;

  @observable
  Map<String, Map<String, dynamic>> councilVotes;

  @observable
  Map<String, dynamic> userCouncilVotes;

  @observable
  ObservableList<ReferendumInfo> referendums;

  @action
  void setCouncilInfo(Map info, {bool shouldCache = true}) {
    council = CouncilInfoData.fromJson(info);

    if (shouldCache) {
      cacheCouncilTimestamp = DateTime.now().millisecondsSinceEpoch;
      rootStore.localStorage.setObject(_getCacheKey(cacheCouncilKey),
          {'data': info, 'cacheTime': cacheCouncilTimestamp});
    }
  }

  @action
  void setCouncilVotes(Map votes) {
    councilVotes = Map<String, Map<String, dynamic>>.from(votes);
  }

  @action
  void setUserCouncilVotes(Map votes) {
    userCouncilVotes = Map<String, dynamic>.from(votes);
  }

  @action
  void setBestNumber(int number) {
    bestNumber = number;
  }

  @action
  void setReferendums(List ls) {
    referendums = ObservableList.of(ls.map((i) => ReferendumInfo.fromJson(
        i as Map<String, dynamic>, rootStore.account.currentAddress)));
  }

  @action
  Future<void> loadCache() async {
    Map data =
        await rootStore.localStorage.getObject(_getCacheKey(cacheCouncilKey));
    if (data != null) {
      setCouncilInfo(data['data'], shouldCache: false);
      cacheCouncilTimestamp = data['cacheTime'];
    }
  }
}
