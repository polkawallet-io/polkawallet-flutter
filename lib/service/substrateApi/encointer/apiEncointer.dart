import 'dart:convert';

import 'package:encointer_wallet/common/consts/settings.dart';
import 'package:encointer_wallet/service/substrateApi/api.dart';
import 'package:encointer_wallet/store/app.dart';
import 'package:encointer_wallet/store/encointer/types/attestation.dart';
import 'package:encointer_wallet/store/encointer/types/claimOfAttendance.dart';
import 'package:encointer_wallet/store/encointer/types/encointerBalanceData.dart';
import 'package:encointer_wallet/store/encointer/types/encointerTypes.dart';
import 'package:encointer_wallet/store/encointer/types/location.dart';
import 'package:encointer_wallet/utils/format.dart';

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
  final String _timeStampSubscribeChannel = 'timestamp';
  final String _currentPhaseSubscribeChannel = 'currentPhase';
  final String _participantIndexChannel = 'participantIndex';
  final String _currencyIdentifiersChannel = 'currencyIdentifiers';
  final String _encointerBalanceChannel = 'encointerBalance';
  final String _shopRegistryChannel = 'shopRegistry';

  Future<void> startSubscriptions() async {
    print("api: starting encointer subscriptions");
    this.subscribeTimestamp();
    this.subscribeCurrentPhase();
    this.subscribeCurrencyIdentifiers();
    this.subscribeEncointerBalance();
    this.subscribeShopRegistry();
  }

  Future<void> stopSubscriptions() async {
    print("api: stopping encointer subscriptions");
    apiRoot.unsubscribeMessage(_currentPhaseSubscribeChannel);
    apiRoot.unsubscribeMessage(_timeStampSubscribeChannel);
    apiRoot.unsubscribeMessage(_participantIndexChannel);
    apiRoot.unsubscribeMessage(_currencyIdentifiersChannel);
    apiRoot.unsubscribeMessage(_encointerBalanceChannel);
    apiRoot.unsubscribeMessage(_shopRegistryChannel);
  }

  Future<CeremonyPhase> getCurrentPhase() async {
    print("api: getCurrentPhase");
    Map res = await apiRoot.evalJavascript('encointer.getCurrentPhase()');

    var phase = getEnumFromString(CeremonyPhase.values, res.values.toList()[0].toString().toUpperCase());
    print("api: Phase enum: " + phase.toString());
    store.encointer.setCurrentPhase(phase);
    return phase;
  }

  Future<int> getCurrentCeremonyIndex() async {
    print("api: getCurrentCeremonyIndex");
    int cIndex = await apiRoot.evalJavascript('encointer.getCurrentCeremonyIndex()');
    print("api: Current Ceremony index: " + cIndex.toString());
    store.encointer.setCurrentCeremonyIndex(cIndex);
    return cIndex;
  }

  Future<int> getMeetupIndex() async {
    String address = store.account.currentAccountPubKey;
    String cid = store.encointer.chosenCid;
    int cIndex = store.encointer.currentCeremonyIndex;

    if (address == null) return 0;
    if ((address.isEmpty) | (cid == null) | (cIndex == null)) {
      return 0;
    }
    print("api: getMeetupIndex");
    int mIndex = await apiRoot.evalJavascript('encointer.getMeetupIndex("$cid", "$cIndex","$address")');
    print("api: Next Meetup Index: " + mIndex.toString());
    store.encointer.setMeetupIndex(mIndex);
    return mIndex;
  }

  Future<void> getMeetupLocation() async {
    print("api: getMeetupLocation");
    String address = store.account.currentAccountPubKey;
    String cid = store.encointer.chosenCid;
    if (cid == null) {
      return; // zero means: not registered
    }
    int mIndex = store.encointer.meetupIndex;
    Map<String, dynamic> locj =
        await apiRoot.evalJavascript('encointer.getNextMeetupLocation("$cid", "$mIndex","$address")');
    print("api: Next Meetup Location: " + locj.toString());
    Location loc = Location.fromJson(locj);
    store.encointer.setMeetupLocation(loc);
  }

  Future<DateTime> getMeetupTime() async {
    print("api: getMeetupTime");
    if (store.encointer.currencyIdentifiers == null) {
      return null;
    }
    String cid = store.encointer.chosenCid ?? store.encointer.currencyIdentifiers[0];
    String loc = jsonEncode(store.encointer.meetupLocation);
    int time = await apiRoot.evalJavascript('encointer.getNextMeetupTime("$cid", $loc)');
    print("api: Next Meetup Time: " + time.toString());
    store.encointer.setMeetupTime(time);
    return DateTime.fromMillisecondsSinceEpoch(time);
  }

  Future<List<String>> getMeetupRegistry() async {
    print("api: getMeetupRegistry");
    int cIndex = store.encointer.currentCeremonyIndex;
    String cid = store.encointer.chosenCid;
    if (cid == null) {
      return new List(); // empty
    }
    int mIndex = store.encointer.meetupIndex;
    print("api: get meetup registry for cindex " + cIndex.toString() + " mindex " + mIndex.toString() + " cid " + cid);
    List<dynamic> meetupRegistry =
        await apiRoot.evalJavascript('encointer.getMeetupRegistry("$cid", "$cIndex", "$mIndex")');
    print("api: Participants: " + meetupRegistry.toString());
    var mreg = meetupRegistry.map((e) => e.toString()).toList();
    store.encointer.setMeetupRegistry(mreg);
    return mreg;
  }

  Future<int> getParticipantIndex() async {
    String address = store.account.currentAccountPubKey;
    String cid = store.encointer.chosenCid;
    if (cid == null) {
      return 0; // zero means: not registered
    }
    int cIndex = store.encointer.currentCeremonyIndex;
    print("api: Getting participant index for " + address);
    int pIndex = await apiRoot.evalJavascript('encointer.getParticipantIndex("$cid", "$cIndex" ,"$address")');
    print("api: Participant Index: " + pIndex.toString());
    store.encointer.setParticipantIndex(pIndex);
    return pIndex;
  }

  Future<void> getParticipantCount() async {
    String cid = store.encointer.chosenCid;
    int cIndex = store.encointer.currentCeremonyIndex;
    int pCount = await apiRoot.evalJavascript('encointer.getParticipantCount("$cid", "$cIndex")');
    print("api: Participant Count: " + pCount.toString());
    store.encointer.setParticipantCount(pCount);
  }

  Future<void> subscribeTimestamp() async {
    apiRoot.subscribeMessage('encointer.subscribeTimestamp("$_timeStampSubscribeChannel")', _timeStampSubscribeChannel,
        (data) => {store.encointer.setTimestamp(data)});
  }

  Future<void> subscribeCurrentPhase() async {
    apiRoot.subscribeMessage(
        'encointer.subscribeCurrentPhase("$_currentPhaseSubscribeChannel")', _currentPhaseSubscribeChannel, (data) {
      var phase = getEnumFromString(CeremonyPhase.values, data.toUpperCase());
      store.encointer.setCurrentPhase(phase);
      // update depending values
      switch (phase) {
        case CeremonyPhase.REGISTERING:
          this.getCurrentCeremonyIndex();
          break;
        case CeremonyPhase.ASSIGNING:
          this.getMeetupIndex();
          break;
        case CeremonyPhase.ATTESTING:
          break;
      }
    });
  }

  Future<void> subscribeCurrencyIdentifiers() async {
    apiRoot.subscribeMessage('encointer.subscribeCurrencyIdentifiers("$_currencyIdentifiersChannel")',
        _currencyIdentifiersChannel, (data) => {store.encointer.setCurrencyIdentifiers(data.cast<String>())});
  }

  Future<void> subscribeParticipantIndex() async {
    // try to unsubscribe first in case parameters have changed
    if (store.encointer.participantIndex != null) {
      apiRoot.unsubscribeMessage(_participantIndexChannel);
    }
    String account = store.account.currentAccountPubKey;
    String cid = store.encointer.chosenCid;
    if (cid == null) {
      return 0; // zero means: not registered
    }
    int cIndex = store.encointer.currentCeremonyIndex;
    apiRoot.subscribeMessage(
        'encointer.subscribeParticipantIndex("$_participantIndexChannel", "$cid", "$cIndex", "$account")',
        _participantIndexChannel, (data) {
      store.encointer.setParticipantIndex(data);
    });
  }

  Future<void> subscribeEncointerBalance() async {
    // unsubscribe from potentially other currency updates
    print('Substribe encointer balance');
    apiRoot.unsubscribeMessage(_encointerBalanceChannel);

    String account = store.account.currentAccountPubKey;
    String cid = store.encointer.chosenCid;
    if (cid == null) {
      return;
    }

    apiRoot.subscribeMessage(
      'encointer.subscribeBalance("$_encointerBalanceChannel", "$cid", "$account")',
      _encointerBalanceChannel,
      (data) {
        BalanceEntry balance = BalanceEntry.fromJson(data);
        store.encointer.addBalanceEntry(cid, balance);
      },
    );
  }

  Future<void> subscribeShopRegistry() async {
    // try to unsubscribe first in case parameters have changed
    if (store.encointer.shopRegistry != null) {
      apiRoot.unsubscribeMessage(_shopRegistryChannel);
    }
    String cid = store.encointer.chosenCid;
    if (cid == null) {
      return 0; // zero means: not registered
    }
    apiRoot.subscribeMessage('encointer.subscribeShopRegistry("$_shopRegistryChannel", "$cid")', _shopRegistryChannel,
        (data) {
      store.encointer.setShopRegistry(data.cast<String>());
    });
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

  void createClaimOfAttendance(int participants) {
    print("api: create claim with vote=$participants");
    var claim = ClaimOfAttendance(
        store.account.currentAccountPubKey,
        store.encointer.currentCeremonyIndex,
        store.encointer.chosenCid,
        store.encointer.meetupIndex,
        store.encointer.meetupLocation,
        store.encointer.meetupTime,
        participants);
    store.encointer.setMyClaim(claim);
  }

  Future<String> encodeClaimOfAttendance() async {
    print("api: encode claim to hex");
    var claim = jsonEncode(store.encointer.myClaim);
    print("api: $claim");
    String claimHex = await apiRoot.evalJavascript('encointer.getClaimOfAttendance($claim)');
    store.encointer.setClaimHex(claimHex);
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

// untested
  Future<dynamic> getBalanceFromWorker() async {
    var pubKey = store.account.currentAccountPubKey;
    print("Public key:" + pubKey);
    var cid = store.encointer.chosenCid;
    var balance = await apiRoot.evalJavascript('worker.getBalance("$pubKey", "$cid", "123qwe")');
    print("balance: " + balance);
  }

  // not yet used
  Future<List<String>> getShopRegistry() async {
    String cid = store.encointer.chosenCid;

    Map<String, dynamic> res = await apiRoot.evalJavascript('encointer.getShopRegistry("$cid")');

    List<String> shops = new List<String>();
    res['shops'].forEach((e) {
      shops.add(e.toString());
    });

    print("SHOPS: " + shops.toString());
    store.encointer.setShopRegistry(shops);
    return shops;
  }
}
