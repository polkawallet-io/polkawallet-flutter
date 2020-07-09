import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:polka_wallet/common/components/roundedButton.dart';
import 'package:polka_wallet/common/components/roundedCard.dart';
import 'package:polka_wallet/page/account/txConfirmPage.dart';
import 'package:polka_wallet/page/governance/treasury/spendProposalPage.dart';
import 'package:polka_wallet/service/substrateApi/api.dart';
import 'package:polka_wallet/store/app.dart';
import 'package:polka_wallet/store/gov/types/treasuryOverviewData.dart';
import 'package:polka_wallet/utils/format.dart';
import 'package:polka_wallet/utils/i18n/index.dart';

class MotionDetailPage extends StatefulWidget {
  MotionDetailPage(this.store);

  static const String route = '/gov/council/motion';

  final AppStore store;

  @override
  _MotionDetailPageState createState() => _MotionDetailPageState();
}

class _MotionDetailPageState extends State<MotionDetailPage> {
  final List<String> methodExternal = [
    'externalPropose',
    'externalProposeDefault',
    'externalProposeMajority'
  ];
  final List<String> methodTreasury = ['approveProposal', 'rejectProposal'];

  Map _treasuryProposal;

  Future<Map> _fetchTreasuryProposal(String id) async {
    if (_treasuryProposal != null) return _treasuryProposal;

    final Map data =
        await webApi.evalJavascript('api.query.treasury.proposals($id)');
    if (data != null) {
      setState(() {
        _treasuryProposal = data;
      });
    }
    return _treasuryProposal;
  }

  void _onVote() async {
    final dic = I18n.of(context).gov;
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) => CupertinoActionSheet(
        title: Text(dic['treasury.vote']),
        actions: <Widget>[
          CupertinoActionSheetAction(
            child: Text(dic['yes.text']),
            onPressed: () {
              Navigator.of(context).pop();
              _doVote(true);
            },
          ),
          CupertinoActionSheetAction(
            child: Text(dic['no.text']),
            onPressed: () {
              Navigator.of(context).pop();
              _doVote(false);
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

  void _doVote(bool approve) async {
    var dic = I18n.of(context).gov;
    final CouncilMotionData motion = ModalRoute.of(context).settings.arguments;
    var args = {
      "title": dic['treasury.vote'],
      "txInfo": {
        "module": 'council',
        "call": 'vote',
      },
      "detail": jsonEncode({
        "proposalHash": motion.hash,
        "proposalId": motion.votes.index,
        "voteValue": approve,
      }),
      "params": [
        motion.hash,
        motion.votes.index,
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
    final CouncilMotionData motion = ModalRoute.of(context).settings.arguments;
    return Observer(
      builder: (BuildContext context) {
        int blockTime = 6000;
        if (widget.store.settings.networkConst['treasury'] != null) {
          blockTime =
              widget.store.settings.networkConst['babe']['expectedBlockTime'];
        }
        List<List<String>> params = [];
        motion.proposal.meta.args.asMap().forEach((k, v) {
          params.add(
              ['${v.name}: ${v.type}', motion.proposal.args[k].toString()]);
        });
        bool isCouncil = !false;
        widget.store.gov.council.members.forEach((e) {
          if (widget.store.account.currentAddress == e[0]) {
            isCouncil = true;
          }
        });
        bool isVoted = false;
        final List votesAll = motion.votes.ayes.toList();
        votesAll.addAll(motion.votes.nays);
        votesAll.forEach((e) {
          if (e == widget.store.account.currentAddress) {
            isVoted = true;
          }
        });
        bool isTreasury = motion.proposal.section == 'treasury' &&
            methodTreasury.indexOf(motion.proposal.method) > -1;
        bool isExternal = motion.proposal.section == 'democracy' &&
            methodExternal.indexOf(motion.proposal.method) > -1;
        return Scaffold(
          appBar: AppBar(
            title: Text('${dic['council.motion']} #${motion.votes.index}'),
            centerTitle: true,
          ),
          body: SafeArea(
            child: ListView(
              children: <Widget>[
                RoundedCard(
                  padding: EdgeInsets.all(16),
                  margin: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        '${motion.proposal.section}.${motion.proposal.method}',
                        style: Theme.of(context).textTheme.headline4,
                      ),
                      Text(motion.proposal.meta.documentation.trim()),
                      Divider(),
                      Text('params'),
                      ProposalArgsList(params),
                      isTreasury
                          ? FutureBuilder(
                              future: _fetchTreasuryProposal(
                                  motion.proposal.args[0]),
                              builder: (_, AsyncSnapshot<Map> snapshot) {
                                if (snapshot.hasData) {
                                  return ProposalArgsItem(
                                    label: Text('proposal: TreasuryProposal'),
                                    content: Text(jsonEncode(snapshot.data)),
                                  );
                                }
                                return CupertinoActivityIndicator();
                              },
                            )
                          : Container(),
//                      isExternal
//                          ? FutureBuilder(
//                              future: _fetchTreasuryProposal(
//                                  motion.proposal.args[0]),
//                              builder: (_, AsyncSnapshot<Map> snapshot) {
//                                return snapshot.hasData
//                                    ? ProposalArgsItem(
//                                        label: Text('rpop'),
//                                        content: Text('xx'),
//                                      )
//                                    : CupertinoActivityIndicator();
//                              },
//                            )
//                          : Container(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Text('end'),
                          Text(
                            Fmt.blockToTime(
                              motion.votes.end - widget.store.gov.bestNumber,
                              blockTime,
                            ),
                            style: Theme.of(context).textTheme.headline4,
                          ),
                        ],
                      ),
                      Divider(),
                      RoundedButton(
                        icon: Icon(
                          Icons.check,
                          color: Theme.of(context).cardColor,
                        ),
                        text: isVoted ? dic['voted'] : dic['vote'],
                        onPressed: isCouncil && !isVoted ? _onVote : null,
                      ),
                    ],
                  ),
                ),
                ProposalVotingList(store: widget.store, council: motion),
              ],
            ),
          ),
        );
      },
    );
  }
}

class ProposalArgsList extends StatefulWidget {
  ProposalArgsList(this.args);
  final List<List<String>> args;
  @override
  _ProposalArgsListState createState() => _ProposalArgsListState();
}

class _ProposalArgsListState extends State<ProposalArgsList> {
  bool _showDetail = false;

  @override
  Widget build(BuildContext context) {
    List<Widget> items = [
      GestureDetector(
        child: Row(
          children: <Widget>[
            Icon(
              _showDetail
                  ? Icons.keyboard_arrow_down
                  : Icons.keyboard_arrow_right,
            ),
            Text(I18n.of(context).gov['detail'])
          ],
        ),
        onTap: () {
          setState(() {
            _showDetail = !_showDetail;
          });
        },
      )
    ];
    if (_showDetail) {
      items.addAll(widget.args.map((e) {
        return ProposalArgsItem(
          label: Text(e[0]),
          content: Text(
            e[1],
            style: Theme.of(context).textTheme.headline4,
          ),
        );
      }));
    }

    return Container(
      margin: EdgeInsets.only(top: 8, bottom: 8),
      decoration: BoxDecoration(
          border: Border(
              left:
                  BorderSide(color: Theme.of(context).dividerColor, width: 3))),
      child: Column(
        children: items,
      ),
    );
  }
}

class ProposalArgsItem extends StatelessWidget {
  ProposalArgsItem({this.label, this.content});

  final Widget label;
  final Widget content;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.fromLTRB(8, 4, 4, 4),
      padding: EdgeInsets.fromLTRB(8, 4, 8, 4),
      decoration: BoxDecoration(
          border: Border.all(color: Theme.of(context).dividerColor),
          borderRadius: BorderRadius.all(Radius.circular(4))),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[label, content],
            ),
          )
        ],
      ),
    );
  }
}
