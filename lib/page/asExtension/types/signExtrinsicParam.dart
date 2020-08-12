import 'package:json_annotation/json_annotation.dart';

part 'signExtrinsicParam.g.dart';

@JsonSerializable()
class SignExtrinsicParam extends _SignExtrinsicParam {
  static SignExtrinsicParam fromJson(Map<String, dynamic> json) =>
      _$SignExtrinsicParamFromJson(json);
  static Map<String, dynamic> toJson(SignExtrinsicParam params) =>
      _$SignExtrinsicParamToJson(params);
}

abstract class _SignExtrinsicParam {
  String address;
  String blockHash;
  String blockNumber;
  String era;
  String genesisHash;
  String method;
  String nonce;
  List<String> signedExtensions;
  String specVersion;
  String tip;
  String transactionVersion;
  int version;
}

@JsonSerializable()
class SignBytesParam extends _SignBytesParam {
  static SignBytesParam fromJson(Map<String, dynamic> json) =>
      _$SignBytesParamFromJson(json);
  static Map<String, dynamic> toJson(SignBytesParam params) =>
      _$SignBytesParamToJson(params);
}

abstract class _SignBytesParam {
  String address;
  String data;
  String type;
}
