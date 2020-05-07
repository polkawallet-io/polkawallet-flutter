import 'dart:math';

import 'package:intl/intl.dart';
import 'package:mobx/mobx.dart';
import 'package:polka_wallet/store/account.dart';
import 'package:polka_wallet/store/staking/types/txData.dart';
import 'package:polka_wallet/store/staking/types/validatorData.dart';
import 'package:polka_wallet/utils/localStorage.dart';

part 'staking.g.dart';

class StakingStore extends _StakingStore with _$StakingStore {
  StakingStore(AccountStore store) : super(store);
}

abstract class _StakingStore with Store {
  _StakingStore(this.account);

  final AccountStore account;

  final String localStorageOverviewKey = 'staking_overview';
  final String localStorageValidatorsKey = 'validators';

  final String cacheAccountStakingKey = 'account_staking';
  final String cacheStakingTxsKey = 'staking_txs';
  final String cacheTimeKey = 'staking_cache_time';
  @observable
  int cacheTxsTimestamp = 0;

  @observable
  ObservableMap<String, dynamic> overview = ObservableMap<String, dynamic>();

  @observable
  BigInt staked = BigInt.zero;

  @observable
  int nominatorCount = 0;

  @observable
  ObservableList<ValidatorData> validatorsInfo =
      ObservableList<ValidatorData>();

  @observable
  ObservableList<ValidatorData> nextUpsInfo = ObservableList<ValidatorData>();

  @observable
  ObservableMap<String, dynamic> ledger = ObservableMap<String, dynamic>();

  @observable
  bool txsLoading = false;

  @observable
  int txsCount = 0;

  @observable
  ObservableList<TxData> txs = ObservableList<TxData>();

  @observable
  ObservableMap<String, dynamic> rewardsChartDataCache =
      ObservableMap<String, dynamic>();

  @observable
  ObservableMap<String, dynamic> stakesChartDataCache =
      ObservableMap<String, dynamic>();

  @computed
  ObservableList<ValidatorData> get nominatingList {
    return ObservableList.of(validatorsInfo.where((i) {
      String address = account.currentAddress;
      return i.nominators
              .indexWhere((nominator) => nominator['who'] == address) >=
          0;
    }));
  }

  @computed
  BigInt get accountUnlockingTotal {
    BigInt res = BigInt.zero;
    if (ledger['stakingLedger'] == null) {
      return res;
    }

    List.of(ledger['stakingLedger']['unlocking']).forEach((i) {
      res += BigInt.parse(i['value'].toString());
    });
    return res;
  }

  @computed
  BigInt get accountRewardTotal {
    if (ledger['rewards'] == null) {
      return null;
    }
    BigInt res = BigInt.zero;
    List.of(ledger['rewards']).forEach((i) {
      res += BigInt.parse(i['total'].toString());
    });
    return res;
  }

  @action
  void setValidatorsInfo(Map<String, dynamic> data, {bool shouldCache = true}) {
    BigInt totalStaked = BigInt.zero;
    var nominators = {};
    List<ValidatorData> ls = List<ValidatorData>();

    data['info'].forEach((i) {
      i['points'] = overview['eraPoints']['individual'][i['accountId']];
      ValidatorData data = ValidatorData.fromJson(i);
      totalStaked += data.total;
      data.nominators.forEach((n) {
        nominators[n['who']] = true;
      });
      ls.add(data);
    });
    ls.sort((a, b) => a.total > b.total ? -1 : 1);
    validatorsInfo = ObservableList.of(ls);
    staked = totalStaked;
    nominatorCount = nominators.keys.length;

    // cache data
    if (shouldCache) {
      LocalStorage.setKV(localStorageValidatorsKey, data);
    }
  }

  @action
  void setNextUpsInfo(list) {
    List<ValidatorData> ls = List<ValidatorData>();
    list.forEach((i) {
      ValidatorData data = ValidatorData.fromJson(i);
      ls.add(data);
    });
    ls.sort((a, b) => a.total > b.total ? -1 : 1);
    nextUpsInfo = ObservableList.of(ls);
  }

  @action
  void setOverview(Map<String, dynamic> data, {bool shouldCache = true}) {
    data.keys.forEach((key) => overview[key] = data[key]);

    // show validator's address before we got elected detail info
    if (validatorsInfo.length == 0 && data['validators'] != null) {
      List<ValidatorData> list = List.of(data['validators']).map((i) {
        ValidatorData validator = ValidatorData();
        validator.accountId = i;
        return validator;
      }).toList();
      validatorsInfo = ObservableList.of(list);
    }

    if (shouldCache) {
      LocalStorage.setKV(localStorageOverviewKey, data);
    }
  }

  @action
  void setLedger(
    String pubKey,
    Map<String, dynamic> data, {
    bool shouldCache = true,
    bool reset = false,
  }) {
    if (account.currentAccount.pubKey != pubKey) return;

    if (reset) {
      ledger = ObservableMap.of(data);
    } else {
      data.keys.forEach((key) => ledger[key] = data[key]);
    }

    if (shouldCache) {
      Map cache = {};
      ledger.keys.forEach((key) {
        cache[key] = ledger[key];
      });
      LocalStorage.setAccountCache(
          account.currentAccount.pubKey, cacheAccountStakingKey, cache);
    }
  }

  @action
  Future<void> clearTxs() async {
    txs.clear();
  }

  @action
  Future<void> setTxsLoading(bool loading) async {
    txsLoading = loading;
  }

  @action
  Future<void> addTxs(Map res, {bool shouldCache = false}) async {
    txsCount = res['count'];

    if (res['extrinsics'] == null) return;
    List<TxData> ls =
        List.of(res['extrinsics']).map((i) => TxData.fromJson(i)).toList();
    print(ls.length);

    txs.addAll(ls);

    if (shouldCache) {
      LocalStorage.setAccountCache(
          account.currentAccount.pubKey, cacheStakingTxsKey, res);

      cacheTxsTimestamp = DateTime.now().millisecondsSinceEpoch;
      LocalStorage.setAccountCache(
          account.currentAccount.pubKey, cacheTimeKey, cacheTxsTimestamp);
    }
  }

  @action
  void clearState() {
    txs.clear();
    ledger = ObservableMap<String, dynamic>();
  }

  @action
  void setRewardsChartData(String validatorId, Map data) {
    rewardsChartDataCache[validatorId] = data;
  }

  @action
  void setStakesChartData(String validatorId, Map data) {
    stakesChartDataCache[validatorId] = data;
  }

  @action
  Future<void> loadAccountCache() async {
    // return if currentAccount not exist
    String pubKey = account.currentAccount.pubKey;
    if (pubKey == null) {
      return;
    }

    List cache = await Future.wait([
      LocalStorage.getAccountCache(pubKey, cacheAccountStakingKey),
      LocalStorage.getAccountCache(pubKey, cacheStakingTxsKey),
      LocalStorage.getAccountCache(pubKey, cacheTimeKey),
    ]);
    if (cache[0] != null) {
      setLedger(account.currentAddress, cache[0], shouldCache: false);
    } else {
      ledger = ObservableMap<String, dynamic>();
    }
    if (cache[1] != null) {
      addTxs(cache[1]);
    } else {
      txs.clear();
    }
    if (cache[2] != null) {
      cacheTxsTimestamp = cache[2];
    }
  }

  @action
  Future<void> loadCache() async {
    List cacheOverview = await Future.wait([
      LocalStorage.getKV(localStorageOverviewKey),
      LocalStorage.getKV(localStorageValidatorsKey),
    ]);
    if (cacheOverview[0] != null) {
      setOverview(cacheOverview[0], shouldCache: false);
    }
    if (cacheOverview[1] != null) {
      setValidatorsInfo(cacheOverview[1], shouldCache: false);
    }

    loadAccountCache();
  }
}
