// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'txData.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TxData _$TxDataFromJson(Map<String, dynamic> json) {
  return TxData()
    ..blockNum = json['block_num'] as int
    ..blockTimestamp = json['block_timestamp'] as int
    ..accountId = json['account_id'] as String
    ..module = json['call_module'] as String
    ..call = json['call_module_function'] as String
    ..hash = json['extrinsic_hash'] as String
    ..txNumber = json['extrinsic_index'] as String
    ..fee = json['fee'] as String
    ..params = json['params'] as String
    ..nonce = json['nonce'] as int
    ..success = json['success'] as bool;
}

Map<String, dynamic> _$TxDataToJson(TxData instance) => <String, dynamic>{
      'block_num': instance.blockNum,
      'block_timestamp': instance.blockTimestamp,
      'account_id': instance.accountId,
      'call_module': instance.module,
      'call_module_function': instance.call,
      'extrinsic_hash': instance.hash,
      'extrinsic_index': instance.txNumber,
      'fee': instance.fee,
      'params': instance.params,
      'nonce': instance.nonce,
      'success': instance.success,
    };
