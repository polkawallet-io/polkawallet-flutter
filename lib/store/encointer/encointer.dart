import 'package:encointer_wallet/common/consts/settings.dart';
import 'package:encointer_wallet/service/substrateApi/api.dart';
import 'package:encointer_wallet/store/app.dart';
import 'package:encointer_wallet/store/assets/types/transferData.dart';
import 'package:encointer_wallet/store/encointer/types/attestationState.dart';
import 'package:encointer_wallet/store/encointer/types/claimOfAttendance.dart';
import 'package:encointer_wallet/store/encointer/types/encointerBalanceData.dart';
import 'package:encointer_wallet/store/encointer/types/encointerTypes.dart';
import 'package:encointer_wallet/store/encointer/types/location.dart';
import 'package:encointer_wallet/utils/format.dart';
import 'package:mobx/mobx.dart';

part 'encointer.g.dart';

class EncointerStore extends _EncointerStore with _$EncointerStore {
  EncointerStore(AppStore store) : super(store);
}

abstract class _EncointerStore with Store {
  _EncointerStore(this.rootStore);

  final AppStore rootStore;
  final String cacheTxsTransferKey = 'transfer_txs';
  final String encointerCurrencyKey = 'wallet_encointer_currency';
  // offline meetup cache.
  final String encointerCurrentPhaseKey = 'wallet_encointer_current_phase';
  final String encointerMeetupIndexKey = 'wallet_encointer_meetup_index';
  final String encointerMeetupLocationKey = 'wallet_encointer_meetup_location';
  final String encointerMeetupRegistryKey = 'wallet_encointer_meetup_registry';
  final String encointerAttestationsKey = 'wallet_encointer_attestations';
  final String encointerMeetupTimeKey = 'wallet_encointer_meetup_time';

  // Note: In synchronous code, every modification of an @obervable is tracked by mobx and
  // fires a reaction. However, modifications in asynchronous code must be wrapped in
  // a @action block to fire a reaction.

  @observable
  var timeStamp;

  @observable
  CeremonyPhase currentPhase;

  @observable
  int currentCeremonyIndex;

  @observable
  int meetupIndex;

  @observable
  Location meetupLocation;

  @observable
  int meetupTime;

  @observable
  List<String> meetupRegistry;

  @observable
  int myMeetupRegistryIndex;

  @observable
  int participantIndex;

  @observable
  int participantCount;

  @observable
  ClaimOfAttendance myClaim;

  @observable
  Map<String, BalanceEntry> balanceEntries = new ObservableMap();

  @observable
  List<String> currencyIdentifiers;

  @observable
  String chosenCid;

  @observable
  String claimHex;

  @observable
  Map<int, AttestationState> attestations = Map<int, AttestationState>();

  @observable
  ObservableList<TransferData> txsTransfer = ObservableList<TransferData>();

  @action
  void setCurrentPhase(CeremonyPhase phase) {
    print("store: set currentPhase to $phase");
    if (currentPhase != phase) {
      // jsonEncode fails if we don't call toString for an enum
      cacheObject(encointerCurrentPhaseKey, phase.toString());
      currentPhase = phase;
      // update depending values without awaiting
      webApi.encointer.getCurrentCeremonyIndex();
    }
  }

  @action
  void setCurrentCeremonyIndex(index) {
    print("store: set currentCeremonyIndex to $index");
    currentCeremonyIndex = index;
    // update depending values without awaiting
    switch (currentPhase) {
      case CeremonyPhase.REGISTERING:
        // reset deprecated state to null
        purgeAttestations();
        setMeetupIndex();
        setMeetupLocation();
        setMeetupTime();
        setMeetupRegistry();
        setMyMeetupRegistryIndex();
        setMyClaim();
        setClaimHex();
        break;
      case CeremonyPhase.ASSIGNING:
        purgeAttestations();
        webApi.encointer.getMeetupIndex();
        break;
      case CeremonyPhase.ATTESTING:
        webApi.encointer.getMeetupIndex();
        break;
    }
    webApi.encointer.subscribeParticipantIndex();
  }

  @action
  void setMeetupIndex([int index]) {
    print("store: set meetupIndex to $index");
    if (meetupIndex != index) {
      cacheObject(encointerMeetupIndexKey, index);
      meetupIndex = index;
      if (index != null) {
        // update depending values
        webApi.encointer.getMeetupLocation();
        webApi.encointer.getMeetupRegistry();
      }
    }
  }

  @action
  void setMeetupLocation([Location location]) {
    print("store: set meetupLocation to $location");
    if (meetupLocation != location) {
      cacheObject(encointerMeetupLocationKey, location);
      meetupLocation = location;
      if (location != null) {
        // update depending values
        webApi.encointer.getMeetupTime();
      }
    }
  }

  @action
  void setMeetupTime([int time]) {
    print("store: set meetupTime to $time");
    if (meetupTime != time) {
      cacheObject(encointerMeetupTimeKey, time);
      meetupTime = time;
    }
  }

  /// Calculates the remaining time until the next meetup starts. As Gesell and Cantillon currently implement timewarp
  /// we cannot use the time received by the blockchain. Hence, we need to calculate it differently.
  int getTimeToMeetup() {
    var now = DateTime.now();
    if (10 <= now.minute && now.minute < 20) {
      return ((19 - now.minute) * 60 + 60 - now.second);
    } else if (40 <= now.minute && now.minute < 50) {
      return ((49 - now.minute) * 60 + 60 - now.second);
    } else {
      print("Warning: Invalid time to meetup");
      return 0;
    }
  }

  @action
  void setMeetupRegistry([List<String> reg]) {
    print("store: set meetupRegistry to $reg");
    cacheObject(encointerMeetupRegistryKey, reg);
    meetupRegistry = reg;
  }

  @action
  void setMyClaim([ClaimOfAttendance claim]) {
    print("store: set myClaim to $claim");
    myClaim = claim;
  }

  @action
  void setClaimHex([String claimHex]) {
    this.claimHex = claimHex;
  }

  @action
  void setMyMeetupRegistryIndex([int index]) {
    myMeetupRegistryIndex = index;
  }

  @action
  void setCurrencyIdentifiers(List<String> cids) {
    currencyIdentifiers = cids;
  }

  @action
  void setChosenCid(String cid) {
    if (chosenCid != cid) {
      chosenCid = cid;
      cacheObject(encointerCurrencyKey, cid);
      // update depending values without awaiting
      if (!rootStore.settings.loading) {
        webApi.encointer.getMeetupIndex();
        webApi.encointer.subscribeParticipantIndex();
        webApi.encointer.subscribeEncointerBalance();
      }
    }
  }

  @action
  void addYourAttestation(int idx, String att) {
    attestations[idx].setYourAttestation(att);
    cacheObject(encointerAttestationsKey, attestations);
  }

  @action
  void addOtherAttestation(int idx, String att) {
    attestations[idx].setOtherAttestation(att);
    cacheObject(encointerAttestationsKey, attestations);
  }

  @action
  void updateAttestationStep(int idx, CurrentAttestationStep step) {
    attestations[idx].setAttestationStep(step);
    cacheObject(encointerAttestationsKey, attestations);
  }

  @action
  void purgeAttestations() {
    attestations.clear();
    cacheObject(encointerAttestationsKey, attestations);
  }

  @action
  void addBalanceEntry(String cid, BalanceEntry balanceEntry) {
    balanceEntries[cid] = balanceEntry;
  }

  @action
  void setParticipantIndex(int pIndex) {
    participantIndex = pIndex;
  }

  @action
  void setParticipantCount(int pCount) {
    participantCount = pCount;
  }

  @action
  void setTimestamp(int time) {
    timeStamp = time;
  }

  @action
  Future<void> setTransferTxs(List list, {bool reset = false, needCache = true}) async {
    List transfers = list.map((i) {
      bool isCommunityCurrency = i['params'].length == 3;
      return {
        "block_timestamp": i['time'],
        "hash": i['hash'],
        "success": true,
        "from": rootStore.account.currentAddress,
        "to": i['params'][0],
        "token": isCommunityCurrency ? i['params'][1] : rootStore.settings.networkState.tokenSymbol,
        "amount": isCommunityCurrency ? Fmt.doubleFormat(i['params'][2]) : Fmt.balance(i['params'][1], ert_decimals),
      };
    }).toList();
    if (reset) {
      txsTransfer = ObservableList.of(transfers.map((i) => TransferData.fromJson(Map<String, dynamic>.from(i))));
    } else {
      txsTransfer.addAll(transfers.map((i) => TransferData.fromJson(Map<String, dynamic>.from(i))));
    }

    if (needCache && txsTransfer.length > 0) {
      _cacheTxs(transfers, cacheTxsTransferKey);
    }
  }

  @action
  Future<void> _cacheTxs(List list, String cacheKey) async {
    String pubKey = rootStore.account.currentAccount.pubKey;
    List cached = await rootStore.localStorage.getAccountCache(pubKey, cacheKey);
    if (cached != null) {
      cached.addAll(list);
    } else {
      cached = list;
    }
    rootStore.localStorage.setAccountCache(pubKey, cacheKey, cached);
  }

  @action
  Future<void> loadCache() async {
    var data = await loadObject(encointerCurrencyKey);
    if (data != null) {
      print("found cached choice of cid. will recover it: " + data.toString());
      setChosenCid(data);
    }

    // get meetup related data
    data = await loadObject(encointerAttestationsKey);
    if (data != null) {
      print("found cached attestations. will recover them");
      attestations = Map.castFrom<String, dynamic, int, AttestationState>(data);
    }
    currentPhase = await loadCurrentPhase();
    meetupIndex = await loadObject(encointerMeetupIndexKey);

    var loc = await loadObject(encointerMeetupLocationKey);
    if (loc != null) {
      meetupLocation = Location.fromJson(loc);
    }

    var reg = await loadObject(encointerMeetupRegistryKey);
    if (reg != null) {
      meetupRegistry = List<String>.from(reg);
    }

    meetupTime = await loadObject(encointerMeetupTimeKey);
  }

  Future<void> cacheObject(String key, value) {
    return rootStore.localStorage.setObject(_getCacheKey(key), value);
  }

  Future<Object> loadObject(String key) {
    return rootStore.localStorage.getObject(_getCacheKey(key));
  }

  String _getCacheKey(String key) {
    return '${rootStore.settings.endpoint.info}_$key';
  }

  Future<CeremonyPhase> loadCurrentPhase() async {
    Object obj = await rootStore.localStorage.getObject(_getCacheKey(encointerCurrentPhaseKey));
    return getEnumFromString(CeremonyPhase.values, obj);
  }
}
