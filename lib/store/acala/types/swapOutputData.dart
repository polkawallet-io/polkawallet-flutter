import 'package:json_annotation/json_annotation.dart';

part 'swapOutputData.g.dart';

@JsonSerializable()
class SwapOutputData extends _SwapOutputData {
  static SwapOutputData fromJson(Map json) => _$SwapOutputDataFromJson(json);
}

abstract class _SwapOutputData {
  List<String> path;
  double amount;
}
