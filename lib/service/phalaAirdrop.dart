import 'dart:convert';

import 'package:http/http.dart';

class PhalaAirdropApi {
  static const String endpoint =
      'https://stakedrop.phala.network/api/whitelist';

  static Future<List> fetchWhiteList() async {
    Response res = await get(endpoint);
    try {
      final data = jsonDecode(res.body);
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
