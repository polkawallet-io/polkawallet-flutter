import 'package:mobx/mobx.dart';
import 'package:polka_wallet/store/app.dart';
import 'package:polka_wallet/store/gov/types/proposalInfoData.dart';
import 'package:polka_wallet/store/gov/types/referendumInfoData.dart';
import 'package:polka_wallet/store/gov/types/councilInfoData.dart';
import 'package:polka_wallet/store/gov/types/treasuryOverviewData.dart';
import 'package:polka_wallet/store/gov/types/treasuryTipData.dart';

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
  CouncilInfoData council = CouncilInfoData();

  @observable
  List<CouncilMotionData> councilMotions = [];

  @observable
  Map<String, Map<String, dynamic>> councilVotes;

  @observable
  Map<String, dynamic> userCouncilVotes;

  @observable
  List<ReferendumInfo> referendums;

  @observable
  List voteConvictions;

  @observable
  List<ProposalInfoData> proposals = [];

  @observable
  TreasuryOverviewData treasuryOverview = TreasuryOverviewData();

  @observable
  List<TreasuryTipData> treasuryTips;

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
    referendums = List.of(ls.map((i) => ReferendumInfo.fromJson(
        i as Map<String, dynamic>, rootStore.account.currentAddress)));
  }

  @action
  void setReferendumVoteConvictions(List ls) {
    voteConvictions = ls;
  }

  @action
  void setProposals(List ls) {
    proposals = ls
        .map((i) => ProposalInfoData.fromJson(Map<String, dynamic>.of(i)))
        .toList();
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

  @action
  void setTreasuryOverview(Map data) {
    treasuryOverview = TreasuryOverviewData.fromJson(data);
  }

  @action
  void setTreasuryTips(List data) {
    treasuryTips = data
        .map((e) => TreasuryTipData.fromJson(Map<String, dynamic>.of(e)))
        .toList();
  }

  @action
  void setCouncilMotions(List data) {
    councilMotions = data
        .map((e) => CouncilMotionData.fromJson(Map<String, dynamic>.of(e)))
        .toList();
  }

  @action
  void clearState() {
    referendums = [];
    proposals = [];
    council = CouncilInfoData();
    councilMotions = [];
    treasuryOverview = TreasuryOverviewData();
    treasuryTips = [];
  }
}
