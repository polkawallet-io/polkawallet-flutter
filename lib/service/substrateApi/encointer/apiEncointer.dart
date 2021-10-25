import 'dart:convert';

import 'package:encointer_wallet/config/consts.dart';
import 'package:encointer_wallet/service/substrateApi/api.dart';
import 'package:encointer_wallet/store/app.dart';
import 'package:encointer_wallet/store/encointer/types/claimOfAttendance.dart';
import 'package:encointer_wallet/store/encointer/types/encointerBalanceData.dart';
import 'package:encointer_wallet/store/encointer/types/communities.dart';
import 'package:encointer_wallet/store/encointer/types/encointerTypes.dart';
import 'package:encointer_wallet/store/encointer/types/location.dart';
import 'package:encointer_wallet/store/encointer/types/proofOfAttendance.dart';
import 'package:encointer_wallet/store/encointer/types/bazaar.dart';
import 'package:encointer_wallet/mocks/data/mockBazaarData.dart';
import 'package:encointer_wallet/utils/format.dart';

import 'apiNoTee.dart';
import 'apiTeeProxy.dart';

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
  ApiEncointer(this.apiRoot)
      : _noTee = ApiNoTee(apiRoot),
        _teeProxy = ApiTeeProxy(apiRoot);

  final Api apiRoot;
  final store = globalAppStore;
  final String _currentPhaseSubscribeChannel = 'currentPhase';
  final String _participantIndexChannel = 'participantIndexChannel';
  final String _communityIdentifiersChannel = 'communityIdentifiers';
  final String _encointerBalanceChannel = 'encointerBalance';
  final String _businessRegistryChannel = 'businessRegistry';

  final ApiNoTee _noTee;
  final ApiTeeProxy _teeProxy;

  Future<void> startSubscriptions() async {
    print("api: starting encointer subscriptions");
    this.getPhaseDurations();
    this.subscribeCurrentPhase();
    this.subscribeCommunityIdentifiers();
    if (store.settings.endpointIsGesell) {
      this.subscribeParticipantIndex();
      this.subscribeEncointerBalance();
      this.subscribeBusinessRegistry();
    }
  }

  Future<void> stopSubscriptions() async {
    print("api: stopping encointer subscriptions");
    apiRoot.unsubscribeMessage(_currentPhaseSubscribeChannel);
    apiRoot.unsubscribeMessage(_communityIdentifiersChannel);
    apiRoot.unsubscribeMessage(_businessRegistryChannel);

    if (store.settings.endpointIsGesell) {
      apiRoot.unsubscribeMessage(_participantIndexChannel);
      apiRoot.unsubscribeMessage(_encointerBalanceChannel);
      apiRoot.unsubscribeMessage(_businessRegistryChannel);
    }
  }

  /// Queries the Scheduler pallet: encointerScheduler.currentPhase().
  ///
  /// This is on-chain in Cantillon.
  Future<CeremonyPhase> getCurrentPhase() async {
    print("api: getCurrentPhase");
    Map res = await apiRoot.evalJavascript('encointer.getCurrentPhase()');

    var phase = ceremonyPhaseFromString(res.values.toList()[0].toString().toUpperCase());
    print("api: Phase enum: " + phase.toString());
    store.encointer.setCurrentPhase(phase);
    return phase;
  }

  /// Queries the Scheduler pallet: encointerScheduler.currentPhase().
  ///
  /// This should be done only once at app-startup, as this is practically const.
  ///
  /// This is on-chain in Cantillon.
  Future<void> getPhaseDurations() async {
    Map<CeremonyPhase, int> phaseDurations = await apiRoot
        .evalJavascript('encointer.getPhaseDurations()')
        .then((m) => Map.from(m).map((key, value) => MapEntry(ceremonyPhaseFromString(key), int.parse(value))));
    print("Phase durations: ${phaseDurations.toString()}");
    store.encointer.phaseDurations = phaseDurations;
  }

  /// Queries the Scheduler pallet: encointerScheduler.currentCeremonyIndex().
  ///
  /// This is on-chain in Cantillon.
  Future<int> getCurrentCeremonyIndex() async {
    print("api: getCurrentCeremonyIndex");
    int cIndex = await apiRoot.evalJavascript('encointer.getCurrentCeremonyIndex()').then((index) => int.parse(index));
    print("api: Current Ceremony index: " + cIndex.toString());
    store.encointer.setCurrentCeremonyIndex(cIndex);
    return cIndex;
  }

  /// Queries the Ceremonies pallet: encointerCeremonies.meetupIndex([cid, cIndex], address).
  ///
  /// This is off-chain and trusted in Cantillon.
  Future<int> getMeetupIndex() async {
    print("api: getMeetupIndex");
    String cid = store.encointer.chosenCid;
    String pubKey = store.account.currentAccountPubKey;

    if (pubKey == null) return 0;
    if ((pubKey.isEmpty) | (cid == null)) {
      return 0;
    }

    int mIndex = store.settings.endpointIsGesell
        ? await _noTee.ceremonies.meetupIndex(cid, store.encointer.currentCeremonyIndex, pubKey)
        : await _teeProxy.ceremonies.meetupIndex(cid, pubKey, store.account.cachedPin);

    print("api: Next Meetup Index: " + mIndex.toString());
    store.encointer.setMeetupIndex(mIndex);
    return mIndex;
  }

  /// Queries the Communities pallet: encointerCommunities.locations(cid)
  ///
  /// Fixme: JS currently returns locations[0] instead of locations[mIndex -1].
  ///
  /// This is on-chain in Cantillon
  Future<void> getMeetupLocation() async {
    print("api: getMeetupLocation");
    String address = store.account.currentAccountPubKey;
    String cid = store.encointer.chosenCid;
    if (cid == null) {
      return;
    }
    int mIndex = store.encointer.meetupIndex;
    Map<String, dynamic> locj =
        await apiRoot.evalJavascript('encointer.getNextMeetupLocation("$cid", "$mIndex","$address")');
    print("api: Next Meetup Location: " + locj.toString());
    Location loc = Location.fromJson(locj);
    store.encointer.setMeetupLocation(loc);
  }

  /// Queries the Communities pallet: encointerCommunities.communityMetadata(cid)
  ///
  /// This is on-chain in Cantillon
  Future<void> getCommunityMetadata() async {
    print("api: getCommunityMetadata");
    String cid = store.encointer.chosenCid;
    if (cid == null) {
      return;
    }

    CommunityMetadata meta = await apiRoot
        .evalJavascript('encointer.getCommunityMetadata("$cid")')
        .then((m) => CommunityMetadata.fromJson(m));

    print("api: community metadata: " + meta.toString());
    store.encointer.setCommunityMetadata(meta);
  }

  /// Queries the Communities and the Balances pallet:
  ///   encointerCommunities.demurragePerBloc(cid)
  ///   encointerBalances.defaultDemurragePerBlock
  ///
  /// Returns the community specific demurrage if defined,
  /// otherwise the default demurrage from the balances pallet
  /// is returned.
  ///
  /// This is on-chain in Cantillon
  Future<void> getDemurrage() async {
    String cid = store.encointer.chosenCid;
    if (cid == null) {
      return;
    }

    double dem = await apiRoot.evalJavascript('encointer.getDemurrage("$cid")');
    print("api: fetched demurrage: $dem");
    store.encointer.setDemurrage(dem);
  }

  /// Calls the custom rpc: api.rpc.communities.communitiesGetAll()
  Future<void> communitiesGetAll() async {
    List<CidName> cn = await apiRoot
        .evalJavascript('encointer.communitiesGetAll()')
        .then((list) => List.from(list).map((cn) => CidName.fromJson(cn)).toList());

    print("api: CidNames: " + cn.toString());
    store.encointer.setCommunities(cn);
  }

  /// Queries the Scheduler pallet: encointerScheduler./-currentPhase(), -phaseDurations(phase), -nextPhaseTimestamp().
  ///
  /// Fixme: Sometimes the PhaseAwareBox takes ages to update. This might be due to multiple network requests on JS side.
  /// We could fetch the phaseDurations at application startup, cache them and supply them in the call here.
  Future<DateTime> getMeetupTime() async {
    print("api: getMeetupTime");
    if (store.encointer.communityIdentifiers == null) {
      return null;
    }
    String cid = store.encointer.chosenCid ?? store.encointer.communityIdentifiers[0];
    String loc = jsonEncode(store.encointer.meetupLocation);

    int time = await apiRoot.evalJavascript(
        'encointer.getNextMeetupTime("$cid", $loc, "${toValue(store.encointer.currentPhase)}", ${store.encointer.currentPhaseDuration})');
    print("api: Next Meetup Time: " + time.toString());
    store.encointer.setMeetupTime(time);
    return DateTime.fromMillisecondsSinceEpoch(time);
  }

  /// Queries the Ceremonies pallet: encointerCeremonies.meetupRegistry([cid, cIndex], mIndex).
  ///
  /// This is off-chain and trusted in Cantillon.
  Future<List<String>> getMeetupRegistry() async {
    print("api: getMeetupRegistry");
    int cIndex = store.encointer.currentCeremonyIndex;
    String cid = store.encointer.chosenCid ?? [];
    String pubKey = store.account.currentAccountPubKey;
    int mIndex = store.encointer.meetupIndex;
    print("api: get meetup registry for cindex " + cIndex.toString() + " mindex " + mIndex.toString() + " cid " + cid);

    List<String> registry = store.settings.endpointIsGesell
        ? await _noTee.ceremonies.meetupRegistry(cid, cIndex, mIndex)
        : await _teeProxy.ceremonies.meetupRegistry(cid, pubKey, store.account.cachedPin);
    print("api: Participants: " + registry.toString());
    store.encointer.setMeetupRegistry(registry);
    return registry;
  }

  /// Queries the Ceremonies pallet: encointerCeremonies.participantIndex([cid, cIndex], address).
  ///
  /// This is off-chain and trusted in Cantillon.
  Future<int> getParticipantIndex() async {
    String cid = store.encointer.chosenCid;
    if (cid == null) {
      return 0; // zero means: not registered
    }

    String pubKey = store.account.currentAccountPubKey;
    print("api: Getting participant index for " + pubKey);
    int pIndex = store.settings.endpointIsGesell
        ? await _noTee.ceremonies.participantIndex(cid, store.encointer.currentCeremonyIndex, pubKey)
        : await _teeProxy.ceremonies.participantIndex(cid, pubKey, store.account.cachedPin);

    print("api: Participant Index: " + pIndex.toString());
    store.encointer.setParticipantIndex(pIndex);
    return pIndex;
  }

  /// Queries the Ceremonies pallet: encointer.Ceremonies.participantCount([cid, cIndex]).
  ///
  /// This is off-chain but public in Cantillon, accessible with PublicGetter::participantCount(cid).
  Future<void> getParticipantCount() async {
    int pCount = store.settings.endpointIsGesell
        ? await _noTee.ceremonies.participantCount(store.encointer.chosenCid, store.encointer.currentCeremonyIndex)
        : await _teeProxy.ceremonies.participantCount(store.encointer.chosenCid);

    print("api: Participant Count: " + pCount.toString());
    return pCount;
  }

  /// Queries the EncointerBalances pallet: encointer.encointerBalances.balance(cid, address).
  ///
  /// This is off-chain and trusted in Cantillon, accessible with TrustedGetter::balance(cid, accountId).
  Future<void> getEncointerBalance() async {
    String pubKey = store.account.currentAccountPubKey;
    String cid = store.encointer.chosenCid;
    if (cid == null) {
      return;
    }

    print("Getting encointer balance for ${Fmt.communityIdentifier(cid)}");

    BalanceEntry bEntry = store.settings.endpointIsGesell
        ? await _noTee.balances.balance(cid, pubKey)
        : await _teeProxy.balances.balance(cid, pubKey, store.account.cachedPin);

    print("bEntryJson: ${bEntry.toString()}");
    store.encointer.addBalanceEntry(cid, bEntry);
  }

  Future<void> subscribeCurrentPhase() async {
    apiRoot.subscribeMessage(
        'encointer.subscribeCurrentPhase("$_currentPhaseSubscribeChannel")', _currentPhaseSubscribeChannel, (data) {
      var phase = ceremonyPhaseFromString(data.toUpperCase());
      store.encointer.setCurrentPhase(phase);
    });
  }

  /// Subscribes to storage changes in the Scheduler pallet: encointerScheduler.currentPhase().
  ///
  /// This is on-chain in Cantillon.
  Future<void> subscribeCommunityIdentifiers() async {
    apiRoot.subscribeMessage(
        'encointer.subscribeCommunityIdentifiers("$_communityIdentifiersChannel")', _communityIdentifiersChannel,
        (data) async {
      store.encointer.setCommunityIdentifiers(data.cast<String>());

      await this.communitiesGetAll();
    });
  }

  /// Subscribes to storage changes in the Ceremonies pallet: encointerCeremonies.participantIndex([cid, cIndex], address).
  ///
  /// This if off-chain in Cantillon. Hence, subscriptions are not supported.
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
          store.encointer.setParticipantIndex(int.parse(data));
    });
  }

  /// Subscribes to storage changes in the EncointerBalances pallet: encointerBalances.balance(cid, address).
  ///
  /// This is off-chain in Cantillon. Hence, subscriptions are not supported.
  Future<void> subscribeEncointerBalance() async {
    // unsubscribe from potentially other community updates
    print('Subscribe encointer balance');
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

  Future<void> subscribeBusinessRegistry() async {
    // todo: implement subscribing
  }

  /// Queries the EncointerCurrencies pallet: encointerCurrencies.communityIdentifiers().
  ///
  /// This is on-chain in Cantillon.
  Future<List<String>> getCommunityIdentifiers() async {
    Map<String, dynamic> res = await apiRoot.evalJavascript('encointer.getCommunityIdentifiers()');

    List<String> cids = List<String>.from(res['cids']);
    print("CID: " + cids.toString());
    store.encointer.setCommunityIdentifiers(cids);
    return cids;
  }

  Future<dynamic> sendFaucetTx() async {
    var address = store.account.currentAddress;
    var amount = Fmt.tokenInt(faucetAmount.toString(), ert_decimals);
    var res = await apiRoot.evalJavascript('account.sendFaucetTx("$address", "$amount")');
    // print("Faucet Result :" + res.toString());
    return res;
  }

  // Below are functions that simply use the Scale-codec already implemented in polkadot-js/api such that we do not
  // have to implement the codec ourselves.
  Future<ClaimOfAttendance> signClaimOfAttendance(int participants, String password) async {
    var claim = ClaimOfAttendance(
        store.account.currentAccountPubKey,
        store.encointer.currentCeremonyIndex,
        store.encointer.chosenCid,
        store.encointer.meetupIndex,
        store.encointer.meetupLocation,
        store.encointer.meetupTime,
        participants);

    var claimSigned =  await apiRoot.evalJavascript('encointer.signClaimOfAttendance(${jsonEncode(claim)}, "$password")')
        .then((c) => ClaimOfAttendance.fromJson(c));

    return claimSigned;
  }

  Future<ProofOfAttendance> getProofOfAttendance() async {
    var pubKey = store.account.currentAccountPubKey;
    var cid = store.encointer.chosenCid;
    var cIndex = store.encointer.currentCeremonyIndex;
    var pin = store.account.cachedPin;
    var proofJs =
        await apiRoot.evalJavascript('encointer.getProofOfAttendance("$pubKey", "$cid", "${cIndex - 1}", "$pin")');
    ProofOfAttendance proof = ProofOfAttendance.fromJson(proofJs);
    print("Proof: ${proof.toString()}");
    return proof;
  }

  /// Get all the registered businesses for the current `chosenCid`
  Future<List<AccountBusinessTuple>> getBusinesses() async {

      // set the store because the current bazaar data model reads the values from the store.
      store.encointer.setbusinessRegistry(allMockBusinesses);
      return allMockBusinesses;
  }

  /// Get all the registered offerings for the current `chosenCid`
  Future<List<OfferingData>> getOfferings() async {

    // Todo: @armin you'd probably extend the encointer store and also set the store here.
    return allMockOfferings;
  }

  /// Get all the registered offerings for the business with [bid]
  Future<List<OfferingData>> getOfferingsForBusiness(BusinessIdentifier bid) async {

    // Todo: @armin you'd probably extend the encointer store and also set the store here.
    return business1MockOfferings;
  }
}
