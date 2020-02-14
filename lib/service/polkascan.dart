import 'package:http/http.dart';

const String endpoint = 'https://polkascan.io/kusama/api/v1';
const int list_page_size = 10;

class PolkaScanApi {
  static Future<String> fetchTxs(String address, int page) async {
    Response res = await get(
        '$endpoint/balances/transfer?&filter[address]=$address&page[number]=$page&page[size]=$list_page_size');
    return res.body;
  }
}
