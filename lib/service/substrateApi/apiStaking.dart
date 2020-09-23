import 'package:polka_wallet/store/app.dart';
import 'package:polka_wallet/service/substrateApi/api.dart';
import 'package:polka_wallet/utils/format.dart';

class ApiStaking {
  ApiStaking(this.apiRoot);

  final Api apiRoot;
  final store = globalAppStore;

  Future<void> fetchAccountStaking() async {
    final String pubKey = store.account.currentAccountPubKey;
    if (pubKey != null && pubKey.isNotEmpty) {
      queryOwnStashInfo(pubKey);
    }
  }

  // this query takes extremely long time
  Future<void> fetchAccountRewards(String pubKey) async {
    if (store.staking.ownStashInfo != null &&
        store.staking.ownStashInfo.stakingLedger != null) {
      int bonded = store.staking.ownStashInfo.stakingLedger['active'];
      List unlocking = store.staking.ownStashInfo.stakingLedger['unlocking'];
      if (pubKey != null && (bonded > 0 || unlocking.length > 0)) {
        String address = store.account.currentAddress;
        print('fetching staking rewards...');
        Map res = await apiRoot
            .evalJavascript('staking.loadAccountRewardsData("$address")');
        store.staking.setRewards(pubKey, res);
        return;
      }
    }
    store.staking.setRewards(pubKey, {});
  }

  Future<Map> fetchStakingOverview() async {
    List res = await Future.wait([
      apiRoot.evalJavascript('staking.fetchStakingOverview()'),
      apiRoot.evalJavascript('api.derive.staking.currentPoints()'),
    ]);
    if (res[0] == null || res[1] == null) return null;
    Map overview = res[0];
    overview['eraPoints'] = res[1];
    store.staking.setOverview(overview);

    fetchElectedInfo();
    // phala airdrop for kusama
//    if (store.settings.endpoint.info == networkEndpointKusama.info) {
//      fetchPhalaAirdropList();
//    }

    List validatorAddressList = List.of(overview['validators']);
    validatorAddressList.addAll(overview['waiting']);
    await apiRoot.account.fetchAddressIndex(validatorAddressList);
    apiRoot.account.getAddressIcons(validatorAddressList);
    return overview;
  }

  Future<Map> updateStaking(int page) async {
    store.staking.setTxsLoading(true);

    Map res = await apiRoot.subScanApi.fetchTxsAsync(
      apiRoot.subScanApi.moduleStaking,
      page: page,
      sender: store.account.currentAddress,
      network: store.settings.networkName.toLowerCase(),
    );

    if (page == 0) {
      store.staking.clearTxs();
    }
    await store.staking.addTxs(res, shouldCache: page == 0);

    store.staking.setTxsLoading(false);

    return res;
  }

  Future<Map> updateStakingRewards() async {
    final address =
        store.staking.ownStashInfo?.stashId ?? store.account.currentAddress;
    final res = await apiRoot.subScanApi.fetchRewardTxsAsync(
      page: 0,
      sender: address,
      network: store.settings.networkName.toLowerCase(),
    );

    await store.staking.addTxsRewards(res, shouldCache: true);
    return res;
  }

  // this query takes a long time
  Future<void> fetchElectedInfo() async {
    // fetch all validators details
    var res = await apiRoot.evalJavascript('api.derive.staking.electedInfo()');
    store.staking.setValidatorsInfo(res);
  }

  Future<Map> queryValidatorRewards(String accountId) async {
    int timestamp = DateTime.now().second;
    Map cached = store.staking.rewardsChartDataCache[accountId];
    if (cached != null && cached['timestamp'] > timestamp - 1800) {
      return cached;
    }
    print('fetching rewards chart data');
    Map data = await apiRoot
        .evalJavascript('staking.loadValidatorRewardsData(api, "$accountId")');
    if (data != null) {
      // format rewards data & set cache
      Map chartData = Fmt.formatRewardsChartData(data);
      chartData['timestamp'] = timestamp;
      store.staking.setRewardsChartData(accountId, chartData);
    }
    return data;
  }

  Future<Map> queryOwnStashInfo(String pubKey) async {
    final accountId = store.account.currentAddress;
    Map data =
        await apiRoot.evalJavascript('staking.getOwnStashInfo("$accountId")');
    store.staking.setOwnStashInfo(pubKey, data);

    final List<String> addressesNeedIcons =
        store.staking.ownStashInfo?.nominating != null
            ? store.staking.ownStashInfo.nominating.toList()
            : [];
    final List<String> addressesNeedDecode = [];
    if (store.staking.ownStashInfo?.stashId != null) {
      addressesNeedIcons.add(store.staking.ownStashInfo.stashId);
      addressesNeedDecode.add(store.staking.ownStashInfo.stashId);
    }
    if (store.staking.ownStashInfo?.controllerId != null) {
      addressesNeedIcons.add(store.staking.ownStashInfo.controllerId);
      addressesNeedDecode.add(store.staking.ownStashInfo.controllerId);
    }

    await apiRoot.account.getAddressIcons(addressesNeedIcons);

    // get stash&controller's pubKey
    apiRoot.account.decodeAddress(addressesNeedIcons);

    return data;
  }
}
