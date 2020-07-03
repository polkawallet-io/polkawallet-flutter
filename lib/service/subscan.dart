import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart';

const int tx_list_page_size = 10;

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

class SubScanApi {
  static const String module_balances = 'Balances';
  static const String module_staking = 'Staking';
  static const String module_democracy = 'Democracy';
  static const String module_Recovery = 'Recovery';

  static String getSnEndpoint(String network) {
    if (network.contains('polkadot')) {
      network = 'polkadot-cc1';
    }
    return 'https://$network.subscan.io/api/scan';
  }

  static Future<Map> fetchTransfers(
    String address,
    int page, {
    String network = 'kusama',
  }) async {
    String url = '${getSnEndpoint(network)}/transfers';
    Map<String, String> headers = {
      "Content-type": "application/json",
      "Accept": "*/*"
    };
    String body = jsonEncode({
      "page": page,
      "row": tx_list_page_size,
      "address": address,
    });
    Response res = await post(url, headers: headers, body: body);
    if (res.body != null) {
      final obj = await compute(jsonDecode, res.body);
      return obj['data'];
    }
    return {};
  }

  static Future<Map> fetchTxs(
    String module, {
    String call,
    int page = 0,
    int size = tx_list_page_size,
    String sender,
    String network = 'kusama',
  }) async {
    String url = '${getSnEndpoint(network)}/extrinsics';
    Map<String, String> headers = {"Content-type": "application/json"};
    Map params = {
      "page": page,
      "row": size,
      "module": module,
    };
    if (sender != null) {
      params['address'] = sender;
    }
    if (call != null) {
      params['call'] = call;
    }
    String body = jsonEncode(params);
    Response res = await post(url, headers: headers, body: body);
    if (res.body != null) {
      final obj = await compute(jsonDecode, res.body);
      return obj['data'];
    }
    return {};
  }
}
