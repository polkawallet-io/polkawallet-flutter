import 'package:json_annotation/json_annotation.dart';
import 'package:polka_wallet/store/gov/types/treasuryOverviewData.dart';

part 'proposalInfoData.g.dart';

@JsonSerializable()
class ProposalInfoData extends _ProposalInfoData {
  static ProposalInfoData fromJson(Map<String, dynamic> json) =>
      _$ProposalInfoDataFromJson(json);
}

abstract class _ProposalInfoData {
  dynamic balance;
  List<String> seconds;
  ProposalImageData image;
  String imageHash;
  String proposer;
  int index;
}

@JsonSerializable()
class ProposalImageData extends _ProposalImageData {
  static ProposalImageData fromJson(Map<String, dynamic> json) =>
      _$ProposalImageDataFromJson(json);
}

abstract class _ProposalImageData {
  dynamic balance;
  int at;
  String proposer;
  CouncilProposalData proposal;
}
