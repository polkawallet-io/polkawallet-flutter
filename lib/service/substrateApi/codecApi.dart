import 'dart:convert';
import 'dart:typed_data';

import 'package:encointer_wallet/service/substrateApi/api.dart';

const String ClaimOfAttendanceJSRegistryName = 'ClaimOfAttendance';

class CodecApi {
  CodecApi(this.apiRoot);

  final Api apiRoot;

  /// scale-decodes [hexStr] with the codec of [type].
  ///
  /// [type] must exist in the polkadot-js/api's type registry.
  Future<dynamic> decodeHex(String type, String hexStr) {
    return apiRoot.evalJavascript('codec.decode("$type", $hexStr)', allowRepeat: true);
  }

  /// scale-decodes [bytes] with the codec of [type].
  ///
  /// [type] must exist in the polkadot-js/api's type registry.
  Future<dynamic> decodeBytes(String type, Uint8List bytes) {
    return apiRoot.evalJavascript('codec.decode("$type", $bytes)', allowRepeat: true);
  }

  /// scale-encodes [obj] with the codec of [type].
  ///
  /// [obj] must implement `jsonSerializable`.
  /// [type] must exist in the polkadot-js/api's type registry.
  Future<String> encodeToHex(String type, dynamic obj) {
    return apiRoot
        .evalJavascript('codec.encodeToHex("$type", ${jsonEncode(obj)})', allowRepeat: true)
        .then((res) => res.toString()); // cast `dynamic` to `String`
  }

  /// scale-encodes [obj] with the codec of [type].
  ///
  /// [obj] must implement `jsonSerializable`.
  /// [type] must exist in the polkadot-js/api's type registry.
  Future<Uint8List> encodeToBytes(String type, dynamic obj) {
    return apiRoot
        .evalJavascript('codec.encode("$type", ${jsonEncode(obj)})', allowRepeat: true)
        .then((res) => List<int>.from(res.values))
        .then((l) => Uint8List.fromList(l));
  }
}
