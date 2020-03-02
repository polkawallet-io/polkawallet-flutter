import 'package:http/http.dart';

const String endpoint = 'https://host-02.polkascan.io/kusama/api/v1';
const int tx_list_page_size = 10;

class PolkaScanApi {
  static Future<String> fetchTxs(String address, int page) async {
    Response res = await get(
        '$endpoint/balances/transfer?filter[address]=$address&page[number]=$page&page[size]=$tx_list_page_size');
    return res.body;
  }

  static Future<String> fetchTx(String hash) async {
    Response res = await get('$endpoint/extrinsic/0x$hash');
    return res.body;
  }

  static Future<String> fetchStaking(String address, int page) async {
    Response res = await get(
        '$endpoint/extrinsic?filter[module_id]=staking&filter[address]=$address&page[number]=$page&page[size]=$tx_list_page_size');
    return res.body;
  }
}
