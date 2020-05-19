import 'package:json_annotation/json_annotation.dart';

part 'councilInfoData.g.dart';

@JsonSerializable()
class CouncilInfoData extends _CouncilInfoData {
  static CouncilInfoData fromJson(Map<String, dynamic> json) =>
      _$CouncilInfoDataFromJson(json);
  static Map<String, dynamic> toJson(CouncilInfoData info) =>
      _$CouncilInfoDataToJson(info);
}

abstract class _CouncilInfoData {
  int desiredSeats;
  int termDuration;
  String votingBond;//can overflow int

  List<List<String>> members;
  List<List<dynamic>> runnersUp;
  List<String> candidates;

  int candidateCount;
  String candidacyBond;//can overflow int
}
