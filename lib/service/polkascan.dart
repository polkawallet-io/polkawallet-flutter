import 'package:http/http.dart';

const int tx_list_page_size = 10;

class PolkaScanApi {
  static const String endpoint = 'https://api-01.polkascan.io/kusama/api/v1';

  static const String module_balances = 'balances';
  static const String module_staking = 'staking';
  static const String module_democracy = 'democracy';

  static Future<String> fetchTransfers(String address, int page) async {
    Response res = await get(
        '$endpoint/balances/transfer?filter[address]=$address&page[number]=$page&page[size]=$tx_list_page_size');
    return res.body;
  }

  static Future<String> fetchTxs(
    String address, {
    String module,
    int page = 1,
  }) async {
    Response res = await get(
        '$endpoint/extrinsic?filter[module_id]=$module&filter[address]=$address&page[number]=$page&page[size]=$tx_list_page_size');
    return res.body;
  }

  static Future<String> fetchTx(String hash) async {
    Response res = await get('$endpoint/extrinsic/0x$hash');
    return res.body;
  }
}
