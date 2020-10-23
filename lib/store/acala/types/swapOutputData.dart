import 'package:json_annotation/json_annotation.dart';

part 'swapOutputData.g.dart';

@JsonSerializable()
class SwapOutputData extends _SwapOutputData {
  static SwapOutputData fromJson(Map json) => _$SwapOutputDataFromJson(json);
}

abstract class _SwapOutputData {
  List path;
  double amount;
  String input;
  String output;
}

@JsonSerializable()
class LPTokenData extends _LPTokenData {
  static LPTokenData fromJson(Map json) => _$LPTokenDataFromJson(json);
}

abstract class _LPTokenData {
  List<String> currencyId;
  String free;
}
