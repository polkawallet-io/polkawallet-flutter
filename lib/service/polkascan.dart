import 'dart:convert';

import 'package:http/http.dart';
import 'package:polka_wallet/common/consts/settings.dart';

const int tx_list_page_size = 10;

class PolkaScanApi {
  static const String module_balances = 'balances';
  static const String module_staking = 'staking';
  static const String module_democracy = 'democracy';

  static String getSnEndpoint(String network) {
    return 'https://$network.subscan.io/api/scan';
  }

  static String getPnEndpoint(String network) {
    if (network == networkEndpointAcala.info) {
      return 'https://api-03.polkascan.io/$network/api/v1';
    }
    return 'https://api-01.polkascan.io/$network/api/v1';
  }

  static Future<Map> fetchTransfers(
    String address,
    int page, {
    String network = 'kusama',
  }) async {
    String url = '${getSnEndpoint(network)}/transfers';
    print(url);
    Map<String, String> headers = {"Content-type": "application/json"};
    String body = jsonEncode({
      "page": page,
      "row": tx_list_page_size,
      "address": address,
    });
    Response res = await post(url, headers: headers, body: body);
    if (res.body != null) {
      return jsonDecode(res.body)['data'];
    }
    return {};
  }

  static Future<String> fetchTxs(
    String address, {
    String module,
    int page = 1,
    String network = 'kusama',
  }) async {
    Response res = await get(
        '${getPnEndpoint(network)}/extrinsic?filter[module_id]=$module&filter[address]=$address&page[number]=$page&page[size]=$tx_list_page_size');
    return res.body;
  }

  static Future<String> fetchTx(String hash,
      {String network = 'kusama'}) async {
    Response res = await get('${getPnEndpoint(network)}/extrinsic/0x$hash');
    return res.body;
  }
}
