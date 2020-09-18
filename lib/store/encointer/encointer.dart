import 'package:mobx/mobx.dart';
import 'package:polka_wallet/common/consts/settings.dart';
import 'package:polka_wallet/store/app.dart';
import 'package:polka_wallet/store/assets/types/transferData.dart';
import 'package:polka_wallet/store/encointer/types/attestationState.dart';
import 'package:polka_wallet/store/encointer/types/encointerBalanceData.dart';
import 'package:polka_wallet/store/encointer/types/encointerTypes.dart';
import 'package:polka_wallet/store/encointer/types/location.dart';
import 'package:polka_wallet/utils/format.dart';

part 'encointer.g.dart';

class EncointerStore extends _EncointerStore with _$EncointerStore {
  EncointerStore(AppStore store) : super(store);
}

abstract class _EncointerStore with Store {
  _EncointerStore(this.rootStore);

  final AppStore rootStore;
  final String cacheTxsTransferKey = 'transfer_txs';
  final String encointerCurrencyKey = 'wallet_encointer_currency';
  final String encointerAttestationsKey = 'wallet_encointer_attestations';

  String _getCacheKey(String key) {
    return '${rootStore.settings.endpoint.info}_$key';
  }

  // Note: In synchronous code, every modification of an @obervable is tracked by mobx and
  // fires a reaction. However, modifications in asynchronous code must be wrapped in
  // a @action block to fire a reaction.

  @observable
  CeremonyPhase currentPhase = CeremonyPhase.REGISTERING;

  @observable
  var currentCeremonyIndex = 0;

  @observable
  var nextMeetupTime = 0;

  @observable
  var meetupIndex = 0;

  @observable
  var myMeetupRegistryIndex = 0;

  @observable
  var nextMeetupLocation = Location(BigInt.from(0x0), BigInt.from(0x0));

  @observable
  var participantIndex = 0;

  @observable
  var participantCount = 0;

  @observable
  var timeStamp = 0;

  @observable
  Map<String, BalanceEntry> balanceEntries = new Map();

  @observable
  List<dynamic> currencyIdentifiers = [];

  @observable
  var chosenCid = "";

  @observable
  Map<int, AttestationState> attestations = Map<int, AttestationState>();

  @observable
  ObservableList<TransferData> txsTransfer = ObservableList<TransferData>();

  @action
  void setCurrentPhase(CeremonyPhase phase) {
    currentPhase = phase;
  }

  @action
  void setCurrentCeremonyIndex(index) {
    currentCeremonyIndex = index;
  }

  @action
  void setNextMeetupLocation(Location location) {
    nextMeetupLocation = location;
  }

  @action
  void setNextMeetupTime(int time) {
    nextMeetupTime = time;
  }

  @action
  void setMeetupIndex(int index) {
    meetupIndex = index;
  }

  @action
  void setMyMeetupRegistryIndex(int index) {
    myMeetupRegistryIndex = index;
  }

  @action
  void setCurrencyIdentifiers(cids) {
    currencyIdentifiers = cids;
  }

  @action
  void setChosenCid(cid) {
    chosenCid = cid;
    rootStore.localStorage.setObject(_getCacheKey(encointerCurrencyKey), cid);
  }

  @action
  void addAttestation(idx, att) {
    attestations[idx].setAttestation(att);
    rootStore.localStorage
        .setObject(_getCacheKey(encointerAttestationsKey), attestations);
  }

  @action
  void purgeAttestations() {
    attestations.clear();
    rootStore.localStorage
        .setObject(_getCacheKey(encointerAttestationsKey), attestations);
  }

  @action
  void addBalanceEntry(cid, balanceEntry) {
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
  Future<void> setTransferTxs(List list,
      {bool reset = false, needCache = true}) async {
    List transfers = list.map((i) {
      return {
        "block_timestamp": i['time'],
        "hash": i['hash'],
        "success": true,
        "from": rootStore.account.currentAddress,
        "to": i['params'][0],
        "token": i['params'][1],
        "amount": Fmt.balance(i['params'][2], decimals: encointerTokenDecimals),
      };
    }).toList();
    if (reset) {
      txsTransfer = ObservableList.of(transfers
          .map((i) => TransferData.fromJson(Map<String, dynamic>.from(i))));
    } else {
      txsTransfer.addAll(transfers
          .map((i) => TransferData.fromJson(Map<String, dynamic>.from(i))));
    }

    if (needCache && txsTransfer.length > 0) {
      _cacheTxs(transfers, cacheTxsTransferKey);
    }
  }

  @action
  Future<void> _cacheTxs(List list, String cacheKey) async {
    String pubKey = rootStore.account.currentAccount.pubKey;
    List cached =
        await rootStore.localStorage.getAccountCache(pubKey, cacheKey);
    if (cached != null) {
      cached.addAll(list);
    } else {
      cached = list;
    }
    rootStore.localStorage.setAccountCache(pubKey, cacheKey, cached);
  }

  @action
  Future<void> loadCache() async {
    var data = await rootStore.localStorage
        .getObject(_getCacheKey(encointerCurrencyKey));
    if (data != null) {
      print("found cached choice of cid. will recover it: " + data.toString());
      setChosenCid(data);
    }

    data = await rootStore.localStorage
        .getObject(_getCacheKey(encointerAttestationsKey));
    if (data != null) {
      print("found cached attestations. will recover them");
      attestations = Map.castFrom<String, dynamic, int, AttestationState>(data);
    }
  }
}
