import 'package:http/http.dart';

class VersionApi {
  static const String _endpoint = 'http://qiniu.xhhn.ltd';

  static Future<String> getLatestVersion() async {
    try {
      Response res = await get('$_endpoint/versions.json');
      return res.body;
    } catch (err) {
      print(err);
      return null;
    }
  }
}
