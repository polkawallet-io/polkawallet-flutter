import 'dart:math';

import 'package:intl/intl.dart';
import 'package:mobx/mobx.dart';
import 'package:polka_wallet/store/account.dart';
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
  bool done = false;

  @observable
  int staked = 0;

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
  ObservableList<Map> txs = ObservableList<Map>();

  @observable
  ObservableMap<String, dynamic> rewardsChartDataCache =
      ObservableMap<String, dynamic>();

  @observable
  ObservableMap<String, dynamic> stakesChartDataCache =
      ObservableMap<String, dynamic>();

  @computed
  ObservableList<String> get nextUps {
    if (overview['intentions'] == null) {
      return ObservableList<String>();
    }
    List<String> ls = List<String>.from(overview['intentions'].where((i) {
      bool ok = overview['validators'].indexOf(i) < 0;
      return ok;
    }));
    return ObservableList.of(ls);
  }

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
  int get accountUnlockingTotal {
    int res = 0;
    if (ledger['stakingLedger'] == null) {
      return res;
    }

    List.of(ledger['stakingLedger']['unlocking']).forEach((i) {
      res += i['value'];
    });
    return res;
  }

  @computed
  int get accountRewardTotal {
    if (ledger['rewards'] == null) {
      return null;
    }
    int res = 0;
    List.of(ledger['rewards']).forEach((i) {
      res += i['total'];
    });
    return res;
  }

  @action
  void setValidatorsInfo(Map<String, dynamic> data, {bool shouldCache = true}) {
    int totalStaked = 0;
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
    String address,
    Map<String, dynamic> data, {
    bool shouldCache = true,
    bool reset = false,
  }) {
    if (account.currentAddress != address) return;

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
  Future<void> addTxs(List<Map> ls, {bool shouldCache = false}) async {
    txs.addAll(ls);

    if (shouldCache) {
      LocalStorage.setAccountCache(
          account.currentAccount.pubKey, cacheStakingTxsKey, ls);

      cacheTxsTimestamp = DateTime.now().millisecondsSinceEpoch;
      LocalStorage.setAccountCache(
          account.currentAccount.pubKey, cacheTimeKey, cacheTxsTimestamp);
    }
  }

  @action
  void clearSate() {
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
    }
    if (cache[1] != null) {
      addTxs(List<Map>.from(cache[1]));
    }
    if (cache[2] != null) {
      cacheTxsTimestamp = cache[2];
    }
  }
}

class ValidatorData extends _ValidatorData with _$ValidatorData {
  static ValidatorData fromJson(Map<String, dynamic> json) {
    ValidatorData data = ValidatorData();
    data.accountId = json['accountId'];
    data.total = int.parse(json['exposure']['total'].toString());
    var own = json['exposure']['own'];
    if (own.runtimeType == String) {
      data.bondOwn = int.parse(own);
    } else {
      data.bondOwn = own;
    }
    data.bondOther = data.total - data.bondOwn;
    data.points = json['points'] ?? 0;
    data.commission = NumberFormat('0.00%')
        .format(json['validatorPrefs']['commission'] / pow(10, 9));
    data.nominators =
        List<Map<String, dynamic>>.from(json['exposure']['others']);
    return data;
  }
}

abstract class _ValidatorData with Store {
  @observable
  String accountId = '';

  @observable
  int total = 0;

  @observable
  int bondOwn = 0;

  @observable
  int bondOther = 0;

  @observable
  int points = 0;

  @observable
  String commission = '';

  @observable
  List<Map<String, dynamic>> nominators = List<Map<String, dynamic>>();
}
