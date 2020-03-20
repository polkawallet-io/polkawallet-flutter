import 'package:mobx/mobx.dart';
import 'package:polka_wallet/store/account.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:polka_wallet/utils/localStorage.dart';

part 'governance.g.dart';

class GovernanceStore extends _GovernanceStore with _$GovernanceStore {
  GovernanceStore(AccountStore store) : super(store);
}

abstract class _GovernanceStore with Store {
  _GovernanceStore(this.account);

  final AccountStore account;

  final String cacheCouncilKey = 'council';

  @observable
  int cacheCouncilTimestamp = 0;

  @observable
  int bestNumber = 0;

  @observable
  CouncilInfo council;

  @observable
  ObservableList<ReferendumInfo> referendums;

  @observable
  ObservableMap<int, ReferendumVotes> referendumVotes =
      ObservableMap<int, ReferendumVotes>();

  @observable
  ObservableList<Map> userReferendumVotes = ObservableList<Map>();

  @computed
  Map<int, int> get votedMap {
    Map<int, int> res = Map<int, int>();
    userReferendumVotes.forEach((i) {
      int id = i['detail']['params'][0]['value'];
      if (res[id] == null) {
        res[id] = i['detail']['params'][1]['value'];
      }
    });
    return res;
  }

  @action
  void setCouncilInfo(Map info, {bool shouldCache = true}) {
    council = CouncilInfo.fromJson(info);

    if (shouldCache) {
      cacheCouncilTimestamp = DateTime.now().millisecondsSinceEpoch;
      LocalStorage.setKV(
          cacheCouncilKey, {'data': info, 'cacheTime': cacheCouncilTimestamp});
    }
  }

  @action
  void setBestNumber(int number) {
    bestNumber = number;
  }

  @action
  void setReferendums(List ls) {
    referendums = ObservableList.of(
        ls.map((i) => ReferendumInfo.fromJson(i as Map<String, dynamic>)));
  }

  @action
  void setReferendumVotes(int index, Map votes) {
    referendumVotes[index] = ReferendumVotes.fromJson(votes);
  }

  @action
  void setUserReferendumVotes(String address, List ls) {
    if (account.currentAddress != address) return;

    userReferendumVotes.addAll(List<Map>.from(ls));
  }

  @action
  void clearSate() {
    userReferendumVotes = ObservableList<Map>();
  }

  @action
  Future<void> loadCache() async {
    Map data = await LocalStorage.getKV(cacheCouncilKey);
    if (data != null) {
      setCouncilInfo(data['data'], shouldCache: false);
      cacheCouncilTimestamp = data['cacheTime'];
    }
  }
}

@JsonSerializable()
class CouncilInfo extends _CouncilInfo with _$CouncilInfo {
  static CouncilInfo fromJson(Map<String, dynamic> json) =>
      _$CouncilInfoFromJson(json);
  static Map<String, dynamic> toJson(CouncilInfo info) =>
      _$CouncilInfoToJson(info);
}

abstract class _CouncilInfo with Store {
  int desiredSeats;
  int termDuration;
  int votingBond;

  List<List<String>> members;
  List<List<String>> runnersUp;
  List<String> candidates;

  int candidateCount;
  int candidacyBond;
}

@JsonSerializable()
class ReferendumInfo extends _ReferendumInfo with _$ReferendumInfo {
  static ReferendumInfo fromJson(Map<String, dynamic> json) =>
      _$ReferendumInfoFromJson(json);
  static Map<String, dynamic> toJson(ReferendumInfo info) =>
      _$ReferendumInfoToJson(info);
}

abstract class _ReferendumInfo with Store {
  int index;
  String hash;

  Map<String, dynamic> info;
  Map<String, dynamic> proposal;
  Map<String, dynamic> preimage;
  Map<String, dynamic> detail;
}

class ReferendumVotes extends _ReferendumVotes {
  static ReferendumVotes fromJson(Map<String, dynamic> json) {
    ReferendumVotes res = ReferendumVotes();
    res.voteCount = json['voteCount'];
    res.voteCountAye = json['voteCountAye'];
    res.voteCountNay = json['voteCountNay'];
    res.votedAye = int.parse('0x${json['votedAye']}');
    res.votedNay = int.parse('0x${json['votedNay']}');
    res.votedTotal = int.parse('0x${json['votedTotal']}');
    return res;
  }
}

abstract class _ReferendumVotes {
  int voteCount;
  int voteCountAye;
  int voteCountNay;
  int votedAye;
  int votedNay;
  int votedTotal;
}
