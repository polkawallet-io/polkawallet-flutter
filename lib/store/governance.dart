import 'package:mobx/mobx.dart';
import 'package:polka_wallet/store/account.dart';
import 'package:json_annotation/json_annotation.dart';

part 'governance.g.dart';

class GovernanceStore extends _GovernanceStore with _$GovernanceStore {
  GovernanceStore(AccountStore store) : super(store);
}

abstract class _GovernanceStore with Store {
  _GovernanceStore(AccountStore store);

  @observable
  CouncilInfo council = CouncilInfo();

  @action
  void setCouncilInfo(Map info) {
    council = CouncilInfo.fromJson(info);
  }
}

@JsonSerializable()
class CouncilInfo extends _CouncilInfo with _$CouncilInfo {
  static CouncilInfo fromJson(Map<String, dynamic> json) =>
      _$CouncilInfoFromJson(json);
  static Map<String, dynamic> toJson(CouncilInfo acc) =>
      _$CouncilInfoToJson(acc);
}

abstract class _CouncilInfo with Store {
  int desiredSeats;
  int termDuration;
  int votingBond;

  List<List<String>> members;
  List<List<String>> runnersUp;
  List<List<String>> candidates;

  int candidateCount;
  int candidacyBond;
}
