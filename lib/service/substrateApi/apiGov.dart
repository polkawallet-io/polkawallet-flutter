import 'package:polka_wallet/store/app.dart';
import 'package:polka_wallet/service/substrateApi/api.dart';
import 'package:polka_wallet/store/gov/types/treasuryOverviewData.dart';

class ApiGovernance {
  ApiGovernance(this.apiRoot);

  final Api apiRoot;
  final store = globalAppStore;

  Future<Map> fetchCouncilInfo() async {
    Map info = await apiRoot.evalJavascript('api.derive.elections.info()');
    if (info != null) {
      List all = [];
      all.addAll(info['members'].map((i) => i[0]));
      all.addAll(info['runnersUp'].map((i) => i[0]));
      all.addAll(info['candidates']);
      store.gov.setCouncilInfo(info);
      apiRoot.account.fetchAddressIndex(all);
      apiRoot.account.getAddressIcons(all);
    }
    return info;
  }

  Future<Map> fetchCouncilVotes() async {
    Map votes = await apiRoot.evalJavascript('gov.fetchCouncilVotes()');
    if (votes != null) {
      store.gov.setCouncilVotes(votes);
    }
    return votes;
  }

  Future<Map> fetchUserCouncilVote() async {
    Map votes = await apiRoot.evalJavascript(
        'api.derive.council.votesOf("${store.account.currentAddress}")');
    if (votes != null) {
      store.gov.setUserCouncilVotes(votes);
    }
    return votes;
  }

  Future<Map> fetchReferendums() async {
    Map data = await apiRoot.evalJavascript(
        'gov.fetchReferendums("${store.account.currentAddress}")');
    if (data != null) {
      List list = data['referendums'];
      list.asMap().forEach((k, v) {
        v['detail'] = data['details'][k];
      });
      store.gov.setReferendums(List<Map<String, dynamic>>.from(list));
    }
    return data;
  }

  Future<List> getReferendumVoteConvictions() async {
    List res =
        await apiRoot.evalJavascript('gov.getReferendumVoteConvictions()');
    if (res != null) {
      store.gov.setReferendumVoteConvictions(res);
    }
    return res;
  }

  Future<List> fetchProposals() async {
    List data = await apiRoot.evalJavascript('gov.fetchProposals()');
    if (data != null) {
      store.gov.setProposals(data);
      List<String> addresses = [];
      store.gov.proposals.forEach((e) {
        addresses.add(e.proposer);
        addresses.addAll(e.seconds);
      });
      await apiRoot.account.getAddressIcons(addresses);
      await apiRoot.account.fetchAddressIndex(addresses);
      return data;
    }
    return [];
  }

  Future<Map> fetchTreasuryOverview() async {
    Map data = await apiRoot.evalJavascript(
      'gov.getTreasuryOverview()',
      allowRepeat: true,
    );
    store.gov.setTreasuryOverview(data);
    List<String> addresses = [];
    List<SpendProposalData> allProposals =
        store.gov.treasuryOverview.proposals.toList();
    allProposals.addAll(store.gov.treasuryOverview.approvals);
    allProposals.forEach((e) {
      addresses.add(e.proposal.proposer);
      addresses.add(e.proposal.beneficiary);
    });
    await apiRoot.account.getAddressIcons(addresses);
    await apiRoot.account.fetchAddressIndex(addresses);
    return data;
  }

  Future<List> fetchTreasuryTips() async {
    List data = await apiRoot.evalJavascript('gov.getTreasuryTips()');
    store.gov.setTreasuryTips(data);
    List<String> addresses = [];
    store.gov.treasuryTips.toList().forEach((e) {
      addresses.add(e.who);
      if (e.finder != null) {
        addresses.add(e.finder);
      }
    });
    await apiRoot.account.getAddressIcons(addresses);
    await apiRoot.account.fetchAddressIndex(addresses);
    return data;
  }

  Future<List> fetchCouncilMotions() async {
    List data = await apiRoot.evalJavascript('gov.getCouncilMotions()');
    store.gov.setCouncilMotions(data);
    return data;
  }

  Future<void> updateBestNumber() async {
    final int bestNumber =
        await apiRoot.evalJavascript('api.derive.chain.bestNumber()');
    store.gov.setBestNumber(bestNumber);
  }
}
