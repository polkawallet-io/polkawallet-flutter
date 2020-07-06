import 'package:polka_wallet/common/consts/settings.dart';
import 'package:polka_wallet/service/phalaAirdrop.dart';
import 'package:polka_wallet/store/app.dart';
import 'package:polka_wallet/service/substrateApi/api.dart';
import 'package:polka_wallet/utils/format.dart';

class ApiStaking {
  ApiStaking(this.apiRoot);

  final Api apiRoot;
  final store = globalAppStore;

  Future<void> fetchAccountStaking() async {
    String pubKey = store.account.currentAccountPubKey;
    if (pubKey != null && pubKey.isNotEmpty) {
      String address = store.account.currentAddress;
      Map ledger = await apiRoot
          .evalJavascript('api.derive.staking.account("$address")');

      List addressesNeedIcons =
          ledger['nominators'] != null ? List.of(ledger['nominators']) : List();

      if (ledger['stakingLedger'] == null) {
        // get stash account info for a controller address
        var stakingLedger = await Future.wait([
          apiRoot.evalJavascript('api.query.staking.ledger("$address")'),
          apiRoot.evalJavascript('api.query.staking.payee("$address")'),
        ]);
        if (stakingLedger[0] != null) {
          var nominators = await apiRoot.evalJavascript(
              'api.query.staking.nominators("${stakingLedger[0]['stash']}")');
          if (nominators != null) {
            ledger['nominators'] = nominators['targets'];
            addressesNeedIcons.addAll(List.of(nominators['targets']));
          } else {
            ledger['nominators'] = [];
          }

          stakingLedger[0]['payee'] = stakingLedger[1];
          ledger['stakingLedger'] = stakingLedger[0];

          // get stash's pubKey
          apiRoot.account.decodeAddress([stakingLedger[0]['stash']]);
          // get stash's icon
          addressesNeedIcons.add(stakingLedger[0]['stash']);
        }
      } else {
        // get controller address info for a stash account

        // get controller's pubKey
        apiRoot.account.decodeAddress([ledger['controllerId']]);
        // get controller's icon
        addressesNeedIcons.add(ledger['controllerId']);
      }

      store.staking
          .setLedger(pubKey, Map<String, dynamic>.of(ledger), reset: true);

      // get nominators' icons
      if (addressesNeedIcons.length > 0) {
        await apiRoot.account.getAddressIcons(addressesNeedIcons);
      }
    }
  }

  // this query takes extremely long time
  Future<void> fetchAccountRewards(String pubKey) async {
    if (store.staking.ledger['stakingLedger'] != null) {
      int bonded = store.staking.ledger['stakingLedger']['active'];
      List unlocking = store.staking.ledger['stakingLedger']['unlocking'];
      if (pubKey != null && (bonded > 0 || unlocking.length > 0)) {
        String address = store.account.currentAddress;
        print('fetching staking rewards...');
        Map res = await apiRoot
            .evalJavascript('staking.loadAccountRewardsData("$address")');
        store.staking.setLedger(pubKey, {'rewards': res});
        return;
      }
    }
    store.staking.setLedger(pubKey, {'rewards': {}});
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
    if (store.settings.endpoint.info == networkEndpointKusama.info) {
      fetchPhalaAirdropList();
    }

    List validatorAddressList = List.of(overview['validators']);
    validatorAddressList.addAll(overview['waiting']);
    await apiRoot.account.fetchAccountsIndex(validatorAddressList);
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

  Future<List> fetchPhalaAirdropList() async {
    final today = DateTime.now();
    // airdrop till 20200816
    if (today.month > 6 && today.day > 15) {
      return [];
    }
    List res = await PhalaAirdropApi.fetchWhiteList();
    store.staking.setPhalaAirdropWhiteList(res);
    return res;
  }
}
