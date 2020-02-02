import 'package:http/http.dart';

const String endpoint = 'https://polkascan.io/kusama-cc3/api/v1';

class PolkaScanApi {
  static Future<String> fetchTxs(String address) async {
    Response res =
        await get('$endpoint/balances/transfer?&filter[address]=$address');
    return res.body;
  }

  static Future<String> fetchBlock(String hash) async {
    Response res = await get('$endpoint/block/$hash');
    return res.body;
  }
}
