import 'package:mobx/mobx.dart';
import 'package:polka_wallet/store/app.dart';
import 'package:polka_wallet/store/staking/types/ownStashInfo.dart';
import 'package:polka_wallet/store/staking/types/txData.dart';
import 'package:polka_wallet/store/staking/types/validatorData.dart';
import 'package:polka_wallet/utils/format.dart';

part 'staking.g.dart';

class StakingStore extends _StakingStore with _$StakingStore {
  StakingStore(AppStore store) : super(store);
}

abstract class _StakingStore with Store {
  _StakingStore(this.rootStore);

  final AppStore rootStore;

  final String localStorageOverviewKey = 'staking_overview';
  final String localStorageValidatorsKey = 'validators';

  final String cacheOwnStashKey = 'staking_own_stash';
  final String cacheStakingTxsKey = 'staking_txs';
  final String cacheStakingRewardTxsKey = 'staking_reward_txs';
  final String cacheTimeKey = 'staking_cache_time';

  String _getCacheKey(String key) {
    return '${rootStore.settings.endpoint.info}_$key';
  }

  @observable
  int cacheTxsTimestamp = 0;

  @observable
  ObservableMap<String, dynamic> overview = ObservableMap<String, dynamic>();

  @observable
  BigInt staked = BigInt.zero;

  @observable
  int nominatorCount = 0;

  @observable
  List<ValidatorData> validatorsInfo = List<ValidatorData>();

  @observable
  Map<String, dynamic> rewards;

  @observable
  OwnStashInfoData ownStashInfo;

  @observable
  bool txsLoading = false;

  @observable
  int txsCount = 0;

  @observable
  ObservableList<TxData> txs = ObservableList<TxData>();

  @observable
  ObservableList<TxRewardData> txsRewards = ObservableList<TxRewardData>();

  @observable
  ObservableMap<String, dynamic> rewardsChartDataCache =
      ObservableMap<String, dynamic>();

  @observable
  ObservableMap<String, dynamic> stakesChartDataCache =
      ObservableMap<String, dynamic>();

  @observable
  Map phalaAirdropWhiteList = {};

  @observable
  Map recommendedValidators = {};

  @computed
  List<ValidatorData> get nextUpsInfo {
    if (overview['waiting'] != null) {
      List<ValidatorData> list = List.of(overview['waiting']).map((i) {
        ValidatorData validator = ValidatorData();
        validator.accountId = i;
        return validator;
      }).toList();
      return list;
    }
    return [];
  }

  @computed
  List<ValidatorData> get validatorsAll {
    List<ValidatorData> res = validatorsInfo.toList();
    res.addAll(nextUpsInfo);
    return res;
  }

  @computed
  List<ValidatorData> get activeNominatingList {
    return List.of(validatorsInfo.where((i) {
      String address = rootStore.account.currentAddress;
      return i.nominators
              .indexWhere((nominator) => nominator['who'] == address) >=
          0;
    }));
  }

  @computed
  List<ValidatorData> get nominatingList {
    if (ownStashInfo == null ||
        ownStashInfo.nominating == null ||
        ownStashInfo.nominating.length == 0) {
      return [];
    }
    return List.of(validatorsInfo
        .where((i) => ownStashInfo.nominating.indexOf(i.accountId) >= 0));
  }

  @computed
  Map<String, List> get nominationsAll {
    if (overview['nominators'] == null) {
      return {};
    }
    return Map<String, List>.from(overview['nominators']);
  }

  @computed
  BigInt get accountUnlockingTotal {
    BigInt res = BigInt.zero;
    if (ownStashInfo == null || ownStashInfo.stakingLedger == null) {
      return res;
    }

    List.of(ownStashInfo.stakingLedger['unlocking']).forEach((i) {
      res += BigInt.parse(i['value'].toString());
    });
    return res;
  }

  @computed
  BigInt get accountRewardTotal {
    if (rewards == null) {
      return null;
    }
    if (rewards['available'] == null) {
      return BigInt.zero;
    }
    return Fmt.balanceInt(rewards['available'].toString());
  }

  @computed
  List<String> get recommendedValidatorList {
    if (recommendedValidators[rootStore.settings.endpoint.info] == null) {
      return [];
    }
    return List<String>.from(
        recommendedValidators[rootStore.settings.endpoint.info]);
  }

  @action
  void setValidatorsInfo(Map<String, dynamic> data, {bool shouldCache = true}) {
    BigInt totalStaked = BigInt.zero;
    var nominators = {};
    List<ValidatorData> ls = List<ValidatorData>();

    data['info'].forEach((i) {
      i['points'] = overview['eraPoints'] != null
          ? overview['eraPoints']['individual'][i['accountId']]
          : 0;
      ValidatorData data = ValidatorData.fromJson(i);
      totalStaked += data.total;
      data.nominators.forEach((n) {
        nominators[n['who']] = true;
      });
      ls.add(data);
    });
    ls.sort((a, b) => a.total > b.total ? -1 : 1);
    validatorsInfo = ls;
    staked = totalStaked;
    nominatorCount = nominators.keys.length;

    // cache data
    if (shouldCache) {
      rootStore.localStorage
          .setObject(_getCacheKey(localStorageValidatorsKey), data);
    }
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
      validatorsInfo = list;
    }

    if (shouldCache) {
      rootStore.localStorage
          .setObject(_getCacheKey(localStorageOverviewKey), data);
    }
  }

  @action
  void setRewards(String pubKey, Map<String, dynamic> data) {
    if (rootStore.account.currentAccount.pubKey != pubKey) return;

    rewards = data;
  }

  @action
  void setOwnStashInfo(String pubKey, Map<String, dynamic> data,
      {bool shouldCache = true}) {
    if (rootStore.account.currentAccount.pubKey != pubKey) return;

    ownStashInfo = OwnStashInfoData.fromJson(data);

    if (shouldCache) {
      rootStore.localStorage.setAccountCache(
        rootStore.account.currentAccount.pubKey,
        _getCacheKey(cacheOwnStashKey),
        data,
      );
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
    if (res == null || res['extrinsics'] == null) return;
    txsCount = res['count'];

    List<TxData> ls =
        List.of(res['extrinsics']).map((i) => TxData.fromJson(i)).toList();

    txs.addAll(ls);

    if (shouldCache) {
      String pubKey = rootStore.account.currentAccount.pubKey;
      rootStore.localStorage
          .setAccountCache(pubKey, _getCacheKey(cacheStakingTxsKey), res);

      cacheTxsTimestamp = DateTime.now().millisecondsSinceEpoch;
      rootStore.localStorage.setAccountCache(
          pubKey, _getCacheKey(cacheTimeKey), cacheTxsTimestamp);
    }
  }

  @action
  Future<void> addTxsRewards(Map res, {bool shouldCache = false}) async {
    if (res['list'] == null) return;
    List<TxRewardData> ls =
        List.of(res['list']).map((i) => TxRewardData.fromJson(i)).toList();

    txsRewards = ObservableList.of(ls);

    if (shouldCache) {
      String pubKey = rootStore.account.currentAccount.pubKey;
      rootStore.localStorage
          .setAccountCache(pubKey, _getCacheKey(cacheStakingRewardTxsKey), res);
    }
  }

  @action
  void clearState() {
    txs.clear();
    overview = ObservableMap<String, dynamic>();
    ownStashInfo = null;
    rewards = null;
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
    String pubKey = rootStore.account.currentAccountPubKey;
    if (pubKey == null || pubKey.isEmpty) {
      return;
    }

    List cache = await Future.wait([
      rootStore.localStorage
          .getAccountCache(pubKey, _getCacheKey(cacheOwnStashKey)),
      rootStore.localStorage
          .getAccountCache(pubKey, _getCacheKey(cacheStakingTxsKey)),
      rootStore.localStorage
          .getAccountCache(pubKey, _getCacheKey(cacheStakingRewardTxsKey)),
      rootStore.localStorage
          .getAccountCache(pubKey, _getCacheKey(cacheTimeKey)),
    ]);
    if (cache[0] != null) {
      ownStashInfo = OwnStashInfoData.fromJson(cache[0]);
    } else {
      ownStashInfo = null;
    }
    if (cache[1] != null) {
      addTxs(cache[1]);
    } else {
      txs.clear();
    }
    if (cache[2] != null) {
      addTxsRewards(cache[2]);
    } else {
      txsRewards.clear();
    }
    if (cache[3] != null) {
      cacheTxsTimestamp = cache[3];
    }
  }

  @action
  Future<void> loadCache() async {
    List cacheOverview = await Future.wait([
      rootStore.localStorage.getObject(_getCacheKey(localStorageOverviewKey)),
      rootStore.localStorage.getObject(_getCacheKey(localStorageValidatorsKey)),
    ]);
    if (cacheOverview[0] != null) {
      setOverview(cacheOverview[0], shouldCache: false);
    }
    if (cacheOverview[1] != null) {
      setValidatorsInfo(cacheOverview[1], shouldCache: false);
    }

    loadAccountCache();
  }

  @action
  Future<void> setPhalaAirdropWhiteList(List ls) async {
    Map res = {};
    ls.forEach((i) {
      res[i['stash']] = true;
      res[i['controller']] = true;
    });
    phalaAirdropWhiteList = res;
  }

  @action
  Future<void> setRecommendedValidatorList(Map data) async {
    recommendedValidators = data;
  }
}
