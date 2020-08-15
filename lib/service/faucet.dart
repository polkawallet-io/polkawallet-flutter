import 'dart:convert';

import 'package:http/http.dart';

class FaucetApi {
  static const String _endpoint = 'https://api.polkawallet.io/faucet';

  static Future<String> getAcalaTokens(String address, String deviceId) async {
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

  static Future<String> getLaminarTokens(String address) async {
    try {
      Response res = await post(
        'https://laminar-faucet.herokuapp.com/faucet/web-endpoint',
        headers: {"Content-type": "application/json"},
        body: jsonEncode({"address": address}),
      );
      if (res.statusCode == 200) {
        return utf8.decode(res.bodyBytes);
      }
      return null;
    } catch (err) {
      print(err);
      return null;
    }
  }
}
