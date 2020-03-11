import 'dart:convert';

import 'package:polka_wallet/store/app.dart';
import 'package:polka_wallet/service/polkascan.dart';
import 'package:polka_wallet/service/substrateApi/api.dart';
import 'package:polka_wallet/utils/format.dart';

class ApiStaking {
  ApiStaking(this.apiRoot);

  final Api apiRoot;
  final store = globalAppStore;

  Future<void> fetchAccountStaking(String address) async {
    if (address != null) {
      var res = await apiRoot
          .evalJavascript('api.derive.staking.account("$address")');
      store.staking.setLedger(res);
      if (res['nominators'] != null) {
        apiRoot.account.getAddressIcons(List.of(res['nominators']));
      }
    }
  }

  Future<Map> fetchStakingOverview() async {
    var overview =
        await apiRoot.evalJavascript('api.derive.staking.overview()');
    store.staking.setOverview(overview);

    // fetch all validators details
    fetchElectedInfo();
    List validatorAddressList = List.of(overview['validators']);
    apiRoot.account.fetchAccountsIndex(validatorAddressList);
    apiRoot.account.getAddressIcons(validatorAddressList);
    return overview;
  }

  Future<List> updateStaking(int page) async {
    String data =
        await PolkaScanApi.fetchStaking(store.account.currentAddress, page);
    var ls = jsonDecode(data)['data'];
    var detailReqs = List<Future<dynamic>>();
    ls.forEach((i) => detailReqs
        .add(PolkaScanApi.fetchTx(i['attributes']['extrinsic_hash'])));
    var details = await Future.wait(detailReqs);
    var index = 0;
    ls.forEach((i) {
      i['detail'] = jsonDecode(details[index])['data']['attributes'];
      index++;
    });
    if (page == 1) {
      store.staking.clearTxs();
    }
    await store.staking.addTxs(List<Map<String, dynamic>>.from(ls));

    Map<int, bool> blocksNeedUpdate = Map<int, bool>();
    ls.forEach((i) {
      int block = i['attributes']['block_id'];
      if (store.assets.blockMap[block] == null) {
        blocksNeedUpdate[block] = true;
      }
    });
    String blocks = blocksNeedUpdate.keys.join(',');
    var blockData =
        await apiRoot.evalJavascript('account.getBlockTime([$blocks])');

    store.assets.setBlockMap(blockData);
    return ls;
  }

  Future<void> fetchElectedInfo() async {
    var res = await apiRoot.evalJavascript('api.derive.staking.electedInfo()');
    store.staking.setValidatorsInfo(res);
  }

  Future<Map> queryValidatorRewards(String accountId) async {
    int timestamp = DateTime.now().second;
    Map cached = store.staking.rewardsChartDataCache[accountId];
    if (cached != null && cached['timestamp'] > timestamp - 1800) {
      queryValidatorStakes(accountId);
      return cached;
    }
    print('fetching rewards chart data');
    Map data = await apiRoot
        .evalJavascript('staking.loadValidatorRewardsData(api, "$accountId")');
    if (data != null && List.of(data['rewardsLabels']).length > 0) {
      // fetch validator stakes data while rewards data query finished
      queryValidatorStakes(accountId);
      // format rewards data & set cache
      Map chartData = Fmt.formatRewardsChartData(data);
      chartData['timestamp'] = timestamp;
      store.staking.setRewardsChartData(accountId, chartData);
    }
    return data;
  }

  Future<Map> queryValidatorStakes(String accountId) async {
    int timestamp = DateTime.now().second;
    Map cached = store.staking.stakesChartDataCache[accountId];
    if (cached != null && cached['timestamp'] > timestamp - 1800) {
      return cached;
    }
    print('fetching stakes chart data');
    Map data = await apiRoot
        .evalJavascript('staking.loadValidatorStakeData(api, "$accountId")');
    if (data != null && List.of(data['stakeLabels']).length > 0) {
      data['timestamp'] = timestamp;
      store.staking.setStakesChartData(accountId, data);
    }
    return data;
  }
}
