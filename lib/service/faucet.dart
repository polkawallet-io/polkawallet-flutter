import 'dart:convert';

import 'package:http/http.dart';

class AcalaFaucetApi {
  static const String _endpoint = 'https://apps.acala.network/faucet';

  static Future<String> getTokens(String address, String deviceId) async {
    Map<String, String> headers = {"Content-type": "application/json"};
    String body = jsonEncode({
      "address": address,
      "sender": deviceId,
    });
    try {
      Response res =
          await post('$_endpoint/bot-endpoint', headers: headers, body: body);
      if (res.statusCode == 200) {
        return res.body;
      }
      return null;
    } catch (err) {
      print(err);
      return null;
    }
  }
}
