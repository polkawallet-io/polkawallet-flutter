import 'dart:convert';

import 'package:http/http.dart';

class AcalaFaucetApi {
  static const String _endpoint = 'http://192.168.1.64:5555';

  static Future<String> getTokens(String address) async {
    String amount = jsonEncode({
      "ACA": 2,
      "aUSD": 2,
      "DOT": 2,
      "XBTC": 0.1,
    });
    try {
      Response res = await post('$_endpoint/bot-endpoint', body: {
        "address": address,
        "sender": address,
        "amount": amount,
      });
      return res.body;
    } catch (err) {
      print(err);
      return null;
    }
  }
}
