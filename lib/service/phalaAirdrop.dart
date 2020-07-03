import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart';

class PhalaAirdropApi {
  static const String endpoint =
      'https://stakedrop.phala.network/api/whitelist';

  static Future<List> fetchWhiteList() async {
    Response res = await get(endpoint);
    try {
      final data = await compute(jsonDecode, res.body);
      if (data['status'] == "ok") {
        return data['result'];
      }
      print('fetchWhiteList status: ${data['status']}');
    } catch (err) {
      print(err);
    }
    return [];
  }
}
