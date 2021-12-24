import 'dart:convert';

import 'package:encointer_wallet/service/substrateApi/api.dart';
import 'package:encointer_wallet/store/encointer/types/communities.dart';
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

  Future<int> participantCount(CommunityIdentifier cid, int cIndex) async {
    return apiRoot
        .evalJavascript('encointer.getParticipantCount(${jsonEncode(cid)}, "$cIndex")')
        .then((value) => int.parse(value));
  }

  Future<int> participantIndex(CommunityIdentifier cid, int cIndex, String pubKey) async {
    return apiRoot
        .evalJavascript('encointer.getParticipantIndex(${jsonEncode(cid)}, "$cIndex" ,"$pubKey")')
        .then((value) => int.parse(value));
  }

  Future<int> meetupIndex(CommunityIdentifier cid, int cIndex, String pubKey) async {
    return apiRoot
        .evalJavascript('encointer.getMeetupIndex(${jsonEncode(cid)}, "$cIndex","$pubKey")')
        .then((value) => int.parse(value));
  }

  Future<List<String>> meetupRegistry(CommunityIdentifier cid, int cIndex, int mIndex) async {
    return apiRoot
        .evalJavascript('encointer.getMeetupRegistry(${jsonEncode(cid)}, "$cIndex", "$mIndex")')
        .then((value) => List<String>.from(value));
  }
}

class Balances {
  Balances(this.apiRoot);

  final Api apiRoot;

  Future<BalanceEntry> balance(CommunityIdentifier cid, String pubKey) async {
    Map<String, dynamic> balance = await apiRoot.evalJavascript('encointer.getBalance(${jsonEncode(cid)}, "$pubKey")');
    return BalanceEntry.fromJson(balance);
  }
}
