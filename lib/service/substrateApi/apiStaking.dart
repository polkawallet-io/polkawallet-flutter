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
    if (address != null && address.isNotEmpty) {
      var res = await apiRoot
          .evalJavascript('api.derive.staking.account("$address")');
      store.staking.setLedger(address, res, reset: true);

      List addressesNeedIcons = res['nominators'] ?? List();

      if (res['stakingLedger'] == null) {
        // get stash account info for a controller address
        var stakingLedger = await Future.wait([
          apiRoot.evalJavascript('api.query.staking.ledger("$address")'),
          apiRoot.evalJavascript('api.query.staking.payee("$address")')
        ]);
        if (stakingLedger[0] != null) {
          stakingLedger[0]['payee'] = stakingLedger[1];
          store.staking.setLedger(address, {'stakingLedger': stakingLedger[0]});

          // get stash's pubKey
          apiRoot.account.decodeAddress([stakingLedger[0]['stash']]);
          // get stash's icon
          addressesNeedIcons.add(stakingLedger[0]['stash']);
        }
      } else {
        // get controller address info for a stash account

        // get controller's pubKey
        apiRoot.account.decodeAddress([res['controllerId']]);
        // get controller's icon
        addressesNeedIcons.add(res['controllerId']);
      }

      // get nominators' icons
      if (addressesNeedIcons.length > 0) {
        await apiRoot.account.getAddressIcons(addressesNeedIcons);
      }
    }
  }

  // this query takes extremely long time
  Future<void> fetchAccountRewards(String address) async {
    if (store.staking.ledger['stakingLedger'] != null) {
      int bonded = store.staking.ledger['stakingLedger']['active'];
      List unlocking = store.staking.ledger['stakingLedger']['unlocking'];
      if (address != null && (bonded > 0 || unlocking.length > 0)) {
        print('fetching staking rewards...');
        List res = await apiRoot
            .evalJavascript('staking.loadAccountRewardsData("$address")');
        store.staking.setLedger(address, {'rewards': res});
        return;
      }
    }
    store.staking.setLedger(address, {'rewards': []});
  }

  Future<Map> fetchStakingOverview() async {
    var overview =
        await apiRoot.evalJavascript('api.derive.staking.overview()');
    store.staking.setOverview(overview);

    fetchElectedInfo();

    List validatorAddressList = List.of(overview['validators']);
    await apiRoot.account.fetchAccountsIndex(validatorAddressList);
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
    await store.staking
        .addTxs(List<Map<String, dynamic>>.from(ls), shouldCache: page == 1);

    await apiRoot.updateBlocks(ls);
    return ls;
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
