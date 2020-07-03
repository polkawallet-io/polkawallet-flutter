import 'package:polka_wallet/service/substrateApi/api.dart';

class ClaimUtil {
  static String getStatementSentence(String statement) {
    bool isRegular = statement == 'Regular';
    String url = isRegular
        ? 'https://statement.polkadot.network/regular.html'
        : 'https://statement.polkadot.network/saft.html';

    String hash = isRegular
        ? 'Qmc1XYqT6S39WNp2UeiRUrZichUWUPpGEThDE6dAb3f6Ny'
        : 'QmXEkMahfhHJPzT3RjkXiZVFi77ZeVeuxtAjhojGRNYckz';
    return 'I hereby agree to the terms of the statement whose SHA-256 multihash is $hash. (This may be found at the URL: $url)';
  }

  static Future<String> fetchClaimAmount(Api webApi, String ethAddress) async {
    var res = await webApi.evalJavascript(
        'api.query.claims.claims(claim.addrToChecksum("$ethAddress")).then(res => res.toHuman())');
    return res;
  }

  static Future<String> fetchStatementKind(
      Api webApi, String ethAddress) async {
    var statement = await webApi.evalJavascript(
        'api.query.claims.signing(claim.addrToChecksum("$ethAddress")).then(res => res.toHuman())');
    return statement;
  }
}
