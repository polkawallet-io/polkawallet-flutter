import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:polka_wallet/common/components/BorderedTitle.dart';
import 'package:polka_wallet/common/components/JumpToBrowserLink.dart';
import 'package:polka_wallet/common/components/addressIcon.dart';
import 'package:polka_wallet/common/components/infoItem.dart';
import 'package:polka_wallet/common/components/roundedButton.dart';
import 'package:polka_wallet/common/components/roundedCard.dart';
import 'package:polka_wallet/common/consts/settings.dart';
import 'package:polka_wallet/page/account/txConfirmPage.dart';
import 'package:polka_wallet/service/substrateApi/api.dart';
import 'package:polka_wallet/service/substrateApi/types/genExternalLinksParams.dart';
import 'package:polka_wallet/store/account/types/accountData.dart';
import 'package:polka_wallet/store/app.dart';
import 'package:polka_wallet/store/gov/types/treasuryOverviewData.dart';
import 'package:polka_wallet/utils/format.dart';
import 'package:polka_wallet/utils/i18n/index.dart';

class SpendProposalPage extends StatefulWidget {
  SpendProposalPage(this.store);

  static const String route = '/gov/treasury/proposal';

  final AppStore store;

  @override
  _SpendProposalPageState createState() => _SpendProposalPageState();
}

class _SpendProposalPageState extends State<SpendProposalPage> {
  List _links;
  String _proposalName;

  Future<List> _getExternalLinks(int id) async {
    if (_links != null) return _links;

    final List res = await webApi.getExternalLinks(
      GenExternalLinksParams.fromJson(
          {'data': id.toString(), 'type': 'treasury'}),
    );
    if (res != null) {
      setState(() {
        _links = res;
      });
    }
    return res;
  }

  Future<String> _getProposalName(String callIndex) async {
    if (_proposalName != null) return _proposalName;

    final String res =
        await webApi.evalJavascript('gov.getCouncilProposalName("$callIndex")');
    if (res != null) {
      setState(() {
        _proposalName = res;
      });
    }
    return res;
  }

  Future<void> _showActions({bool isVote = false}) async {
    final dic = I18n.of(context).gov;
    final SpendProposalData proposal =
        ModalRoute.of(context).settings.arguments;
    CouncilProposalData proposalData = CouncilProposalData();
    if (isVote) {
      proposalData = proposal.council[0].proposal;
    }
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) => CupertinoActionSheet(
        title: Text(isVote ? dic['treasury.vote'] : dic['treasury.send']),
        message: isVote
            ? Text('${proposalData.section}.${proposalData.method}()')
            : null,
        actions: <Widget>[
          CupertinoActionSheetAction(
            child: Text(isVote ? dic['yes.text'] : dic['treasury.approve']),
            onPressed: () {
              Navigator.of(context).pop();
              if (isVote) {
                _onVote(true);
              } else {
                _onSendToCouncil(true);
              }
            },
          ),
          CupertinoActionSheetAction(
            child: Text(isVote ? dic['no.text'] : dic['treasury.reject']),
            onPressed: () {
              Navigator.of(context).pop();
              if (isVote) {
                _onVote(false);
              } else {
                _onSendToCouncil(false);
              }
            },
          )
        ],
        cancelButton: CupertinoActionSheetAction(
          child: Text(I18n.of(context).home['cancel']),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
    );
  }

  Future<void> _onSendToCouncil(bool approve) async {
    var dic = I18n.of(context).gov;
    final SpendProposalData proposal =
        ModalRoute.of(context).settings.arguments;
    final String txName =
        'treasury.${approve ? 'approveProposal' : 'rejectProposal'}';
    var args = {
      "title": approve ? dic['treasury.approve'] : dic['treasury.reject'],
      "txInfo": {"module": 'council', "call": 'propose', "txName": txName},
      "detail": jsonEncode({"proposal": txName, "proposal_id": proposal.id}),
      "params": [proposal.id],
      'onFinish': (BuildContext txPageContext, Map res) {
        Navigator.popUntil(txPageContext, ModalRoute.withName('/'));
      }
    };
    Navigator.of(context).pushNamed(TxConfirmPage.route, arguments: args);
  }

  Future<void> _onVote(bool approve) async {
    var dic = I18n.of(context).gov;
    final SpendProposalData proposal =
        ModalRoute.of(context).settings.arguments;
    final CouncilMotionData councilProposal = proposal.council[0];
    var args = {
      "title": dic['treasury.vote'],
      "txInfo": {
        "module": 'council',
        "call": 'vote',
      },
      "detail": jsonEncode({
        "councilHash": councilProposal.hash,
        "councilId": councilProposal.votes.index,
        "voteValue": approve,
      }),
      "params": [
        councilProposal.hash,
        councilProposal.votes.index,
        approve,
      ],
      'onFinish': (BuildContext txPageContext, Map res) {
        Navigator.popUntil(txPageContext, ModalRoute.withName('/'));
      }
    };
    Navigator.of(context).pushNamed(TxConfirmPage.route, arguments: args);
  }

  @override
  Widget build(BuildContext context) {
    final Map dic = I18n.of(context).gov;
    final String symbol = widget.store.settings.networkState.tokenSymbol ?? '';
    final int decimals = widget.store.settings.networkState.tokenDecimals ??
        kusama_token_decimals;
    final String tokenView = Fmt.tokenView(
      symbol,
      decimalsDot: decimals,
      network: widget.store.settings.endpoint.info,
    );
    final SpendProposalData proposal =
        ModalRoute.of(context).settings.arguments;
    final AccountData proposer = AccountData();
    final AccountData beneficiary = AccountData();
    proposer.address = proposal.proposal.proposer;
    beneficiary.address = proposal.proposal.beneficiary;
    final Map accInfoProposer =
        widget.store.account.accountIndexMap[proposer.address];
    final Map accInfoBeneficiary =
        widget.store.account.accountIndexMap[beneficiary.address];
    bool isCouncil = false;
    widget.store.gov.council.members.forEach((e) {
      if (widget.store.account.currentAddress == e[0]) {
        isCouncil = true;
      }
    });
    final bool isApproval = proposal.isApproval ?? false;
    final bool hasProposals = proposal.council.length > 0;
    bool isVoted = false;
    if (hasProposals) {
      final List votesAll = proposal.council[0].votes.ayes.toList();
      votesAll.addAll(proposal.council[0].votes.nays);
      votesAll.forEach((e) {
        if (e == widget.store.account.currentAddress) {
          isVoted = true;
        }
      });
    }
    return Scaffold(
      appBar: AppBar(
        title: Text('${dic['treasury.proposal']} #${proposal.id}'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: ListView(
          children: <Widget>[
            RoundedCard(
              margin: EdgeInsets.all(16),
              padding: EdgeInsets.fromLTRB(0, 24, 0, 8),
              child: Column(
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.only(bottom: 16),
                    child: Row(
                      children: <Widget>[
                        InfoItem(
                          title: dic['treasury.value'],
                          content: '${Fmt.balance(
                            proposal.proposal.value.toString(),
                            decimals: decimals,
                          )} $tokenView',
                          crossAxisAlignment: CrossAxisAlignment.center,
                        ),
                        InfoItem(
                          title: dic['treasury.bond'],
                          content: '${Fmt.balance(
                            proposal.proposal.bond.toString(),
                            decimals: decimals,
                          )} $tokenView',
                          crossAxisAlignment: CrossAxisAlignment.center,
                        ),
                      ],
                    ),
                  ),
                  ListTile(
                    leading: AddressIcon(proposal.proposal.proposer),
                    title: Fmt.accountDisplayName(
                        proposal.proposal.proposer, accInfoProposer),
                    subtitle: Text(dic['treasury.proposer']),
                  ),
                  ListTile(
                    leading: AddressIcon(proposal.proposal.beneficiary),
                    title: Fmt.accountDisplayName(
                        proposal.proposal.beneficiary, accInfoBeneficiary),
                    subtitle: Text(dic['treasury.beneficiary']),
                  ),
                  FutureBuilder(
                    future: _getExternalLinks(proposal.id),
                    builder: (_, AsyncSnapshot<List> snapshot) {
                      if (snapshot.hasData) {
                        return ExternalLinks(snapshot.data);
                      }
                      return Container();
                    },
                  ),
                  isApproval
                      ? Container()
                      : Padding(
                          padding: EdgeInsets.only(left: 16, right: 16),
                          child: Divider(),
                        ),
                  isApproval
                      ? Container()
                      : Padding(
                          padding: EdgeInsets.fromLTRB(16, 8, 16, 8),
                          child: !hasProposals
                              ? RoundedButton(
                                  text: dic['treasury.send'],
                                  onPressed:
                                      isCouncil ? () => _showActions() : null,
                                )
                              : RoundedButton(
                                  text: !isVoted
                                      ? dic['treasury.vote']
                                      : dic['voted'],
                                  onPressed: isCouncil && !isVoted
                                      ? () => _showActions(isVote: true)
                                      : null,
                                ),
                        ),
                ],
              ),
            ),
            !hasProposals
                ? Container()
                : ProposalVotingList(
                    store: widget.store,
                    council: proposal.council[0],
                  )
          ],
        ),
      ),
    );
  }
}

class ExternalLinks extends StatelessWidget {
  ExternalLinks(this.links);

  final List links;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Padding(
          padding: EdgeInsets.only(top: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              JumpToBrowserLink(
                links[0]['link'],
                text: links[0]['name'],
              ),
              JumpToBrowserLink(
                links[1]['link'],
                text: links[1]['name'],
              )
            ],
          ),
        ),
        Padding(
          padding: EdgeInsets.all(8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              JumpToBrowserLink(
                links[2]['link'],
                text: links[2]['name'],
              ),
              JumpToBrowserLink(
                links[3]['link'],
                text: links[3]['name'],
              )
            ],
          ),
        )
      ],
    );
  }
}

class ProposalVotingList extends StatelessWidget {
  ProposalVotingList({this.store, this.council});

  final AppStore store;
  final CouncilMotionData council;

  @override
  Widget build(BuildContext context) {
    final Map dic = I18n.of(context).gov;
    final int voteCount = council.votes.ayes.length + council.votes.nays.length;
    return Container(
      padding: EdgeInsets.only(bottom: 24),
      margin: EdgeInsets.only(top: 8),
      color: Theme.of(context).cardColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: EdgeInsets.all(16),
            child: BorderedTitle(
                title: '${dic['vote.voter']}'
                    '($voteCount/${council.votes.threshold})'),
          ),
          Column(
            children: council.votes.ayes.map((e) {
              final Map accInfo = store.account.accountIndexMap[e];
              return ListTile(
                leading: AddressIcon(e),
                title: Fmt.accountDisplayName(e, accInfo),
                trailing: Text(
                  dic['yes'],
                  style: Theme.of(context).textTheme.headline4,
                ),
              );
            }).toList(),
          ),
          Column(
            children: council.votes.nays.map((e) {
              final Map accInfo = store.account.accountIndexMap[e];
              return ListTile(
                leading: AddressIcon(e),
                title: Fmt.accountDisplayName(e, accInfo),
                trailing: Text(
                  dic['no'],
                  style: Theme.of(context).textTheme.headline4,
                ),
              );
            }).toList(),
          )
        ],
      ),
    );
  }
}
