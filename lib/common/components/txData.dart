import 'package:json_annotation/json_annotation.dart';

part 'txData.g.dart';

@JsonSerializable()
class TxData extends _TxData {
  static TxData fromJson(Map<String, dynamic> json) => _$TxDataFromJson(json);
}

abstract class _TxData {
  @JsonKey(name: 'block_num')
  int blockNum = 0;

  @JsonKey(name: 'block_timestamp')
  int blockTimestamp = 0;

  @JsonKey(name: 'account_id')
  String accountId = "";

  @JsonKey(name: 'call_module')
  String module = "";

  @JsonKey(name: 'call_module_function')
  String call = "";

  @JsonKey(name: 'extrinsic_hash')
  String hash = "";

  @JsonKey(name: 'extrinsic_index')
  String txNumber = "";

  String fee = "";

  String params = "";

  int nonce;
  bool success = true;
}
