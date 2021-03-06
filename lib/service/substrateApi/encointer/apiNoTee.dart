import 'package:encointer_wallet/service/substrateApi/api.dart';
import 'package:encointer_wallet/store/encointer/types/encointerBalanceData.dart';

class ApiNoTee {
  ApiNoTee(this.apiRoot)
      : ceremonies = Ceremonies(apiRoot),
        balances = Balances(apiRoot);

  final Api apiRoot;
  final Ceremonies ceremonies;
  final Balances balances;
}

class Ceremonies {
  Ceremonies(this.apiRoot);

  final Api apiRoot;

  Future<int> participantCount(String cid, int cIndex) async {
    return await apiRoot.evalJavascript('encointer.getParticipantCount("$cid", "$cIndex")');
  }

  Future<int> participantIndex(String cid, int cIndex, String pubKey) async {
    return await apiRoot.evalJavascript('encointer.getParticipantIndex("$cid", "$cIndex" ,"$pubKey")');
  }

  Future<int> meetupIndex(String cid, int cIndex, String pubKey) async {
    return await await apiRoot.evalJavascript('encointer.getMeetupIndex("$cid", "$cIndex","$pubKey")');
  }

  Future<List<String>> meetupRegistry(String cid, int cIndex, int mIndex) async {
    List<dynamic> meetupRegistry =
        await apiRoot.evalJavascript('encointer.getMeetupRegistry("$cid", "$cIndex", "$mIndex")');
    return meetupRegistry.map((e) => e.toString()).toList();
  }
}

class Balances {
  Balances(this.apiRoot);

  final Api apiRoot;

  Future<BalanceEntry> balance(String cid, String pubKey) async {
    Map<String, dynamic> balance = await apiRoot.evalJavascript('encointer.getBalance("$cid", "$pubKey")');
    return BalanceEntry.fromJson(balance);
  }
}
