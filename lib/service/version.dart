import 'dart:convert';

import 'package:http/http.dart';

class VersionApi {
  static const String _endpoint = 'https://apps.acala.network/polkawallet';

  static Future<Map> getLatestVersion() async {
    try {
      Response res = await get('$_endpoint/versions.json');
      if (res == null) {
        return null;
      } else {
        return jsonDecode(res.body) as Map;
      }
    } catch (err) {
      print(err);
      return null;
    }
  }
}
