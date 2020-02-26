import 'dart:math';

import 'package:intl/intl.dart';
import 'package:mobx/mobx.dart';
import 'package:polka_wallet/store/account.dart';

part 'staking.g.dart';

class StakingStore extends _StakingStore with _$StakingStore {
  StakingStore(AccountStore store) : super(store);
}

abstract class _StakingStore with Store {
  _StakingStore(this.account);

  final AccountStore account;

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
  ObservableList<Map<String, dynamic>> txs =
      ObservableList<Map<String, dynamic>>();

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
      String address = account.currentAccount.address;
      return i.nominators
              .indexWhere((nominator) => nominator['who'] == address) >=
          0;
    }));
  }

  @action
  void setValidatorsInfo() {
    int totalStaked = 0;
    var nominators = {};
    List<ValidatorData> ls = List<ValidatorData>();

    overview['elected']['info'].forEach((i) {
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
  void setOverview(Map<String, dynamic> data) {
    data.keys.forEach((key) => overview[key] = data[key]);
    if (data.keys.toList().indexOf('elected') >= 0) {
      setValidatorsInfo();
    }
  }

  @action
  void setLedger(Map<String, dynamic> data) {
    data.keys.forEach((key) => ledger[key] = data[key]);
  }

  @action
  Future<void> clearTxs() async {
    txs.clear();
  }

  @action
  Future<void> addTxs(List<Map<String, dynamic>> ls) async {
    txs.addAll(ls);
  }

  @action
  void clearSate() {
    txs.clear();
//    overview = ObservableMap<String, dynamic>();
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
}

class ValidatorData extends _ValidatorData with _$ValidatorData {
  static ValidatorData fromJson(Map<String, dynamic> json) {
    ValidatorData data = ValidatorData();
    data.accountId = json['accountId'];
    data.total = int.parse(json['exposure']['total']);
    var own = json['exposure']['own'];
    if (own.runtimeType == String) {
      data.bondOwn = int.parse(own);
    } else {
      data.bondOwn = own;
    }
    data.bondOther = data.total - data.bondOwn;
    data.points = json['points'];
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
