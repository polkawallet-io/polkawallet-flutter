import 'dart:convert';

import 'package:encointer_wallet/service/substrateApi/api.dart';
import 'package:encointer_wallet/store/encointer/types/communities.dart';
import 'package:encointer_wallet/store/encointer/types/encointerBalanceData.dart';
import 'package:encointer_wallet/store/encointer/types/workerApi.dart';

class ApiTeeProxy {
  ApiTeeProxy(this.apiRoot)
      : ceremonies = Ceremonies(apiRoot),
        balances = Balances(apiRoot);

  final Api apiRoot;
  final Ceremonies ceremonies;
  final Balances balances;
}

class Ceremonies {
  Ceremonies(this.apiRoot);

  final Api apiRoot;

  Future<int> participantIndex(CommunityIdentifier cid, String pubKey, String pin) async {
    return apiRoot
        .evalJavascript('worker.getParticipantIndex(${jsonEncode(PubKeyPinPair(pubKey, pin))}, ${jsonEncode(cid)})')
        .then((value) => int.parse(value));
  }

  Future<int> meetupIndex(CommunityIdentifier cid, String pubKey, String pin) async {
    return apiRoot
        .evalJavascript('worker.getMeetupIndex(${jsonEncode(PubKeyPinPair(pubKey, pin))}, ${jsonEncode(cid)})')
        .then((value) => int.parse(value));
  }

  Future<List<String>> meetupRegistry(CommunityIdentifier cid, String pubKey, String pin) async {
    return apiRoot
        .evalJavascript('worker.getMeetupRegistry(${jsonEncode(PubKeyPinPair(pubKey, pin))}, ${jsonEncode(cid)})')
        .then((value) => List<String>.from(value));
  }
}

class Balances {
  Balances(this.apiRoot);

  final Api apiRoot;

  Future<BalanceEntry> balance(CommunityIdentifier cid, String pubKey, String pin) async {
    return apiRoot
        .evalJavascript('worker.getBalance(${jsonEncode(PubKeyPinPair(pubKey, pin))}, ${jsonEncode(cid)})')
        .then((balance) => BalanceEntry.fromJson(balance));
  }
}
