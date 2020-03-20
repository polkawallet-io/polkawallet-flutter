import 'dart:convert';

import 'package:polka_wallet/store/app.dart';
import 'package:polka_wallet/service/polkascan.dart';
import 'package:polka_wallet/service/substrateApi/api.dart';

class ApiGovernance {
  ApiGovernance(this.apiRoot);

  final Api apiRoot;
  final store = globalAppStore;

  Future<List> updateDemocracyVotes(String address) async {
    String data = await PolkaScanApi.fetchDemocracyVotes(address);
    List ls = jsonDecode(data)['data'];
    var details = await Future.wait(ls
        .map((i) => PolkaScanApi.fetchTx(i['attributes']['extrinsic_hash']))
        .toList());
    ls.asMap().forEach(
        (k, v) => v['detail'] = jsonDecode(details[k])['data']['attributes']);
    store.gov.setUserReferendumVotes(address, ls);
    return ls;
  }

  Future<Map> fetchCouncilInfo() async {
    Map info = await apiRoot.evalJavascript('api.derive.elections.info()');
    if (info != null) {
      List all = [];
      all.addAll(info['members'].map((i) => i[0]));
      all.addAll(info['runnersUp'].map((i) => i[0]));
      all.addAll(info['candidates']);
      store.gov.setCouncilInfo(info);
      apiRoot.account.fetchAccountsIndex(all);
      apiRoot.account.getAddressIcons(all);
    }
    return info;
  }

  Future<Map> fetchReferendums() async {
    Map data = await apiRoot.evalJavascript('gov.fetchReferendums()');
    if (data != null) {
      List list = data['referendums'];
      if (list.length > 0) {
        list.asMap().forEach((k, v) => v['detail'] = data['details'][k]);
        print(list[0]['detail']);
        store.gov.setReferendums(List<Map<String, dynamic>>.from(list));
        fetchReferendumVotes(List<int>.from(list.map((i) => i['index'])));
      }
    }
    return data;
  }

  Future<void> fetchReferendumVotes(List<int> indexes) async {
    String code = indexes.map((i) => 'gov.getReferendumVotes($i)').join(',');
    List res = await apiRoot.evalJavascript('Promise.all([$code])');
    res.asMap().forEach((k, v) {
      store.gov.setReferendumVotes(indexes[k], v as Map);
    });
  }
}
