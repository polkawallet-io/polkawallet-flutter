import 'dart:convert';

import 'package:polka_wallet/common/consts/settings.dart';
import 'package:polka_wallet/service/substrateApi/api.dart';
import 'package:polka_wallet/store/app.dart';
import 'package:polka_wallet/store/encointer/types/attestation.dart';
import 'package:polka_wallet/store/encointer/types/claimOfAttendance.dart';
import 'package:polka_wallet/store/encointer/types/encointerBalanceData.dart';
import 'package:polka_wallet/store/encointer/types/encointerTypes.dart';
import 'package:polka_wallet/store/encointer/types/location.dart';
import 'package:polka_wallet/utils/format.dart';

/// Api to interface with the `js_encointer_service.js`
///
/// Note: If a call fails on the js side, the corresponding message completer will not be
/// freed. This means that the same call cannot be launched a second time as from the dart
/// side if allow multiple==false in evalJavascript, which is the default.
///
/// NOTE: In this case a `hot_restart` instead of `hot_reload` is needed in order to clear that cache.
///
/// NOTE: If the js-code was changed a rebuild of the application is needed to update the code.

class ApiEncointer {
  ApiEncointer(this.apiRoot);

  final Api apiRoot;
  final store = globalAppStore;

  Future<CeremonyPhase> getCurrentPhase() async {
    Map res = await apiRoot.evalJavascript('encointer.getCurrentPhase()');

    var phase = getEnumFromString(CeremonyPhase.values, res.values.toList()[0].toString().toUpperCase());
    print("Phase enum: " + phase.toString());
    store.encointer.setCurrentPhase(phase);
    return phase;
  }

  Future<int> getCurrentCeremonyIndex() async {
    int cIndex = await apiRoot.evalJavascript('encointer.getCurrentCeremonyIndex()');
    print("Current Ceremony index: " + cIndex.toString());
    store.encointer.setCurrentCeremonyIndex(cIndex);
    return cIndex;
  }

  Future<DateTime> getNextMeetupTime() async {
    if (store.encointer.currencyIdentifiers == null) {
      return null;
    }
    String cid = store.encointer.chosenCid ?? store.encointer.currencyIdentifiers[0];
    await getNextMeetupLocation();
    String loc = jsonEncode(store.encointer.nextMeetupLocation);
    int time = await apiRoot.evalJavascript('encointer.getNextMeetupTime("$cid", $loc)');
    print("Next Meetup Time: " + time.toString());
    store.encointer.setNextMeetupTime(time);
    return DateTime.fromMillisecondsSinceEpoch(time);
  }

  Future<int> getMeetupIndex() async {
    String address = store.account.currentAccountPubKey;
    String cid = store.encointer.chosenCid;
    int cIndex = store.encointer.currentCeremonyIndex;
    int mIndex = await apiRoot.evalJavascript('encointer.getMeetupIndex("$cid", "$cIndex","$address")');
    print("Next Meetup Index: " + mIndex.toString());
    store.encointer.setMeetupIndex(mIndex);
    return mIndex;
  }

  Future<void> getNextMeetupLocation() async {
    String address = store.account.currentAccountPubKey;
    String cid = store.encointer.chosenCid;
    if (cid.isEmpty) {
      return; // zero means: not registered
    }
    int mIndex = await getMeetupIndex();
    Map<String, dynamic> locj =
        await apiRoot.evalJavascript('encointer.getNextMeetupLocation("$cid", "$mIndex","$address")');
    print("Next Meetup Location: " + locj.toString());
    Location loc = Location.fromJson(locj);
    store.encointer.setNextMeetupLocation(loc);
  }

  Future<int> getParticipantIndex() async {
    String address = store.account.currentAccountPubKey;
    String cid = store.encointer.chosenCid;
    if (cid.isEmpty) {
      return 0; // zero means: not registered
    }
    int cIndex = await getCurrentCeremonyIndex();
    print("Getting participant index for " + address);
    int pIndex = await apiRoot.evalJavascript('encointer.getParticipantIndex("$cid", "$cIndex" ,"$address")');
    print("Participant Index: " + pIndex.toString());
    store.encointer.setParticipantIndex(pIndex);
    return pIndex;
  }

  Future<void> getParticipantCount() async {
    String cid = store.encointer.chosenCid;
    int cIndex = store.encointer.currentCeremonyIndex;
    int pCount = await apiRoot.evalJavascript('encointer.getParticipantCount("$cid", "$cIndex")');
    print("Participant Count: " + pCount.toString());
    store.encointer.setParticipantCount(pCount);
  }

  Future<List<String>> getMeetupRegistry() async {
    int cIndex = await getCurrentCeremonyIndex();
    String cid = store.encointer.chosenCid;
    if (cid.isEmpty) {
      return new List(); // empty
    }
    int mIndex = await getMeetupIndex();
    print("get meetup registry for cindex " + cIndex.toString() + " mindex " + mIndex.toString() + " cid " + cid);
    List<dynamic> meetupRegistry =
        await apiRoot.evalJavascript('encointer.getMeetupRegistry("$cid", "$cIndex", "$mIndex")');
    print("Participants: " + meetupRegistry.toString());
    return meetupRegistry.map((e) => e.toString()).toList();
  }

  Future<void> subscribeCurrentPhase(String channel, Function callback) async {
    apiRoot.subscribeMessage('encointer.subscribeCurrentPhase("$channel")', channel, callback);
  }

  Future<void> subscribeTimestamp(String channel) async {
    apiRoot.subscribeMessage(
        'encointer.subscribeTimestamp("$channel")', channel, (data) => {store.encointer.setTimestamp(data)});
  }

  Future<List<String>> getCurrencyIdentifiers() async {
    Map<String, dynamic> res = await apiRoot.evalJavascript('encointer.getCurrencyIdentifiers()');

    List<String> cids = new List<String>();
    res['cids'].forEach((e) {
      cids.add(e.toString());
    });

    print("CID: " + cids.toString());
    store.encointer.setCurrencyIdentifiers(cids);
    return cids;
  }

  Future<String> getClaimOfAttendance(participants) async {
    var perfectMeetupTime = await getNextMeetupTime();
    var claim = jsonEncode(ClaimOfAttendance(
        store.account.currentAccountPubKey,
        store.encointer.currentCeremonyIndex,
        store.encointer.chosenCid,
        store.encointer.meetupIndex,
        store.encointer.nextMeetupLocation,
        perfectMeetupTime.millisecondsSinceEpoch,
        participants));
    print(claim);
    String claimHex = await apiRoot.evalJavascript('encointer.getClaimOfAttendance($claim)');
    return claimHex;
  }

  Future<Attestation> parseAttestation(String attestationHex) async {
    var attJson = await apiRoot.evalJavascript('encointer.parseAttestation("$attestationHex")');
    //print("Attestation json: " + attJson.toString());
    Attestation att = Attestation.fromJson(attJson);
    //print("Attestation parsed: " + attJson.toString());
    return att;
  }

  Future<ClaimOfAttendance> parseClaimOfAttendance(String claimHex) async {
    var claimJson = await apiRoot.evalJavascript('encointer.parseClaimOfAttendance("$claimHex")');
    //print("Attestation json: " + attJson.toString());
    ClaimOfAttendance claim = ClaimOfAttendance.fromJson(claimJson);
    //print("Attestation parsed: " + attJson.toString());
    return claim;
  }

  Future<AttestationResult> attestClaimOfAttendance(String claimHex, String password) async {
    var pubKey = store.account.currentAccountPubKey;
    var att = await apiRoot.evalJavascript('account.attestClaimOfAttendance("$claimHex", "$pubKey", "$password")');
    AttestationResult attestation = AttestationResult.fromJson(att);
    print("Att: ${attestation.toString()}");
    return attestation;
  }

  Future<dynamic> sendFaucetTx() async {
    var address = store.account.currentAddress;
    var amount = Fmt.tokenInt(faucetAmount.toString(), ert_decimals);
    var res = await apiRoot.evalJavascript('account.sendFaucetTx("$address", "$amount")');
    // print("Faucet Result :" + res.toString());
    return res;
  }

  Future<List<EncointerBalanceData>> getBalances() async {
    var pubKey = store.account.currentAccountPubKey;
    var data = await apiRoot.evalJavascript('encointer.getBalances("$pubKey")');

    List<EncointerBalanceData> encointerBalances = new List<EncointerBalanceData>();
    data.map((e) => EncointerBalanceData.fromJson(e)).toList().forEach((e) {
      encointerBalances.add(e);
    });

//    print("encointerBalances list: " + encointerBalances.toString());
    encointerBalances.forEach((e) {
      store.encointer.addBalanceEntry(e.cid, e.balanceEntry);
    });
    return encointerBalances;
  }

// untested
  Future<dynamic> getBalanceFromWorker() async {
    var pubKey = store.account.currentAccountPubKey;
    print("Public key:" + pubKey);
    var cid = store.encointer.chosenCid;
    var balance = await apiRoot.evalJavascript('worker.getBalance("$pubKey", "$cid", "123qwe")');
    print("balance: " + balance);
  }
}
