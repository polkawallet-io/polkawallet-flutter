import 'package:http/http.dart';
import 'package:polka_wallet/common/consts/settings.dart';

const int tx_list_page_size = 10;

class PolkaScanApi {
  static const String module_balances = 'balances';
  static const String module_staking = 'staking';
  static const String module_democracy = 'democracy';

  static String getEndpoint(String network) {
    if (network == networkEndpointAcala.info) {
      return 'https://api-03.polkascan.io/$network/api/v1';
    }
    return 'https://api-02.polkascan.io/$network/api/v1';
  }

  static Future<String> fetchTransfers(
    String address,
    int page, {
    String network = 'kusama',
  }) async {
    String url =
        '${getEndpoint(network)}/balances/transfer?filter[address]=$address&page[number]=$page&page[size]=$tx_list_page_size';
    print(url);
    Response res = await get(url);
    return res.body;
  }

  static Future<String> fetchTxs(
    String address, {
    String module,
    int page = 1,
    String network = 'kusama',
  }) async {
    Response res = await get(
        '${getEndpoint(network)}/extrinsic?filter[module_id]=$module&filter[address]=$address&page[number]=$page&page[size]=$tx_list_page_size');
    return res.body;
  }

  static Future<String> fetchTx(String hash,
      {String network = 'kusama'}) async {
    Response res = await get('${getEndpoint(network)}/extrinsic/0x$hash');
    return res.body;
  }
}
