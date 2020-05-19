import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:polka_wallet/common/components/infoItem.dart';
import 'package:polka_wallet/common/components/outlinedButtonSmall.dart';
import 'package:polka_wallet/page/account/txConfirmPage.dart';
import 'package:polka_wallet/page/governance/council/candidateDetailPage.dart';
import 'package:polka_wallet/page/governance/council/councilVotePage.dart';
import 'package:polka_wallet/service/substrateApi/api.dart';
import 'package:polka_wallet/common/components/BorderedTitle.dart';
import 'package:polka_wallet/common/components/addressIcon.dart';
import 'package:polka_wallet/common/components/roundedButton.dart';
import 'package:polka_wallet/common/components/roundedCard.dart';
import 'package:polka_wallet/store/app.dart';
import 'package:polka_wallet/utils/UI.dart';
import 'package:polka_wallet/utils/format.dart';
import 'package:polka_wallet/utils/i18n/index.dart';

class Council extends StatefulWidget {
  Council(this.store);
  final AppStore store;

  @override
  State<StatefulWidget> createState() => _CouncilState(store);
}

class _CouncilState extends State<Council> {
  _CouncilState(this.store);

  final AppStore store;

  bool _votesExpanded = false;

  Future<void> _fetchCouncilInfo() async {
    if (store.settings.loading) {
      return;
    }
    webApi.gov.fetchCouncilVotes();
    webApi.gov.fetchUserCouncilVote();
    await webApi.gov.fetchCouncilInfo();
  }

  Future<void> _submitCancelVotes() async {
    var govDic = I18n.of(context).gov;
    var args = {
      "title": govDic['vote.remove'],
      "txInfo": {
        "module": 'electionsPhragmen',
        "call": 'removeVoter',
      },
      "detail": '{}',
      "params": [],
      'onFinish': (BuildContext txPageContext, Map res) {
        Navigator.popUntil(txPageContext, ModalRoute.withName('/'));
        globalCouncilRefreshKey.currentState.show();
      }
    };
    Navigator.of(context).pushNamed(TxConfirmPage.route, arguments: args);
  }

  Future<void> _onCancelVotes() async {
    showCupertinoDialog(
      context: context,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: Container(),
          content: Text(I18n.of(context).gov['vote.remove.confirm']),
          actions: [
            CupertinoButton(
              child: Text(I18n.of(context).home['cancel']),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            CupertinoButton(
              child: Text(I18n.of(context).home['ok']),
              onPressed: () {
                Navigator.of(context).pop();
                _submitCancelVotes();
              },
            )
          ],
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      globalCouncilRefreshKey.currentState.show();
    });
  }

  Widget _buildTopCard() {
    final int decimals = store.settings.networkState.tokenDecimals;
    final String symbol = store.settings.networkState.tokenSymbol;
    final Map dic = I18n.of(context).gov;

    Map userVotes = store.gov.userCouncilVotes;
    BigInt voteAmount = BigInt.zero;
    double listHeight = 48;
    if (userVotes != null) {
      voteAmount = BigInt.parse(userVotes['stake'].toString());
      int listCount = List.of(userVotes['votes']).length;
      if (listCount > 0) {
        listHeight = double.parse((listCount * 52).toString());
      }
    }
    return RoundedCard(
      margin: EdgeInsets.fromLTRB(16, 12, 16, 24),
      padding: EdgeInsets.all(24),
      child: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              InfoItem(
                crossAxisAlignment: CrossAxisAlignment.center,
                title: dic['seats'],
                content:
                    '${store.gov.council.members.length}/${store.gov.council.desiredSeats}',
              ),
              InfoItem(
                crossAxisAlignment: CrossAxisAlignment.center,
                title: dic['up'],
                content: store.gov.council.runnersUp.length.toString(),
              ),
              InfoItem(
                crossAxisAlignment: CrossAxisAlignment.center,
                title: dic['candidate'],
                content: store.gov.council.candidates.length.toString(),
              )
            ],
          ),
          Divider(height: 24),
          Column(
            children: <Widget>[
              Row(
                children: [
                  IconButton(
                    icon: Icon(
                      _votesExpanded
                          ? Icons.keyboard_arrow_up
                          : Icons.keyboard_arrow_down,
                      size: 28,
                      color: Theme.of(context).unselectedWidgetColor,
                    ),
                    onPressed: () {
                      setState(() {
                        _votesExpanded = !_votesExpanded;
                      });
                    },
                  ),
                  InfoItem(
                    content:
                        '${Fmt.token(voteAmount, decimals: decimals)} $symbol',
                    title: dic['vote.my'],
                  ),
                  OutlinedButtonSmall(
                    content: dic['vote.remove'],
                    active: false,
                    onPressed: listHeight > 48
                        ? () {
                            _onCancelVotes();
                          }
                        : null,
                  ),
                ],
              ),
              AnimatedContainer(
                height: _votesExpanded ? listHeight : 0,
                duration: Duration(seconds: 1),
                curve: Curves.fastOutSlowIn,
                child: AnimatedOpacity(
                  opacity: _votesExpanded ? 1.0 : 0.0,
                  duration: Duration(seconds: 1),
                  curve: Curves.fastLinearToSlowEaseIn,
                  child: listHeight > 48
                      ? ListView(
                          children: List.of(userVotes['votes']).map((i) {
                            Map accInfo = store.account.accountIndexMap[i];
                            return CandidateItem(
                              iconSize: 32,
                              accInfo: accInfo,
                              balance: [i],
                              tokenDecimals: store.settings.networkState.tokenDecimals,
                              tokenSymbol:
                                  store.settings.networkState.tokenSymbol,
                              noTap: true,
                            );
                          }).toList(),
                        )
                      : Padding(
                          padding: EdgeInsets.only(top: 16),
                          child: Text(
                            I18n.of(context).home['data.empty'],
                            style: TextStyle(color: Colors.black54),
                          ),
                        ),
                ),
              )
            ],
          ),
          Divider(height: 24),
          RoundedButton(
            text: dic['vote'],
            onPressed: () =>
                Navigator.of(context).pushNamed(CouncilVotePage.route),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final Map dic = I18n.of(context).gov;
    return Observer(builder: (_) {
      return RefreshIndicator(
        key: globalCouncilRefreshKey,
        onRefresh: _fetchCouncilInfo,
        child: store.gov.council == null
            ? Container()
            : ListView(
                children: <Widget>[
                  _buildTopCard(),
                  Container(
                    padding: EdgeInsets.only(top: 16, left: 16, bottom: 8),
                    color: Theme.of(context).cardColor,
                    child: BorderedTitle(
                      title: dic['member'],
                    ),
                  ),
                  Container(
                    color: Theme.of(context).cardColor,
                    child: Column(
                      children: store.gov.council.members.map((i) {
                        Map accInfo = store.account.accountIndexMap[i[0]];
                        return CandidateItem(
                          accInfo: accInfo,
                          balance: i,
                          tokenDecimals: store.settings.networkState.tokenDecimals,
                          tokenSymbol: store.settings.networkState.tokenSymbol,
                        );
                      }).toList(),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.only(top: 16, left: 16, bottom: 8),
                    color: Theme.of(context).cardColor,
                    child: BorderedTitle(
                      title: dic['up'],
                    ),
                  ),
                  Container(
                    color: Theme.of(context).cardColor,
                    child: Column(
                      children: store.gov.council.runnersUp.map((i) {
                        Map accInfo = store.account.accountIndexMap[i[0]];
                        return CandidateItem(
                          accInfo: accInfo,
                          balance: i,
                          tokenDecimals: store.settings.networkState.tokenDecimals,
                          tokenSymbol: store.settings.networkState.tokenSymbol,
                        );
                      }).toList(),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.only(top: 16, left: 16, bottom: 8),
                    color: Theme.of(context).cardColor,
                    child: BorderedTitle(
                      title: dic['candidate'],
                    ),
                  ),
                  Container(
                    color: Theme.of(context).cardColor,
                    child: store.gov.council.candidates.length > 0
                        ? Column(
                            children: store.gov.council.candidates.map((i) {
                              Map accInfo = store.account.accountIndexMap[i];
                              return CandidateItem(
                                accInfo: accInfo,
                                balance: [i],
                                tokenDecimals: store.settings.networkState.tokenDecimals,
                                tokenSymbol:
                                    store.settings.networkState.tokenSymbol,
                              );
                            }).toList(),
                          )
                        : Padding(
                            padding: EdgeInsets.all(16),
                            child: Text(dic['candidate.empty']),
                          ),
                  ),
                ],
              ),
      );
    });
  }
}

class CandidateItem extends StatelessWidget {
  CandidateItem({
    this.accInfo,
    this.balance,
    this.tokenDecimals,
    this.tokenSymbol,
    this.switchValue,
    this.onSwitch,
    this.iconSize,
    this.noTap = false,
  });
  final Map accInfo;
  // balance == [<candidate_address>, <0x_candidate_backing_amount>]
  final List balance;
  final int tokenDecimals;
  final String tokenSymbol;
  final bool switchValue;
  final Function(bool) onSwitch;
  final double iconSize;
  final bool noTap;
  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: AddressIcon(balance[0], size: iconSize),
      title: Row(
        children: <Widget>[
          accInfo != null && accInfo['identity']['judgements'].length > 0
              ? Container(
                  width: 14,
                  margin: EdgeInsets.only(right: 4),
                  child: Image.asset('assets/images/assets/success.png'),
                )
              : Container(),
          Text(accInfo != null && accInfo['identity']['display'] != null
              ? accInfo['identity']['display'].toString().toUpperCase()
              : Fmt.address(balance[0], pad: 6))
        ],
      ),
      subtitle: balance.length == 1
          ? null
          : Text(
              '${I18n.of(context).gov['backing']}: ${Fmt.token(BigInt.parse(balance[1].toString()), decimals:  tokenDecimals)} $tokenSymbol'),
      onTap: noTap
          ? null
          : () => Navigator.of(context).pushNamed(CandidateDetailPage.route,
              arguments: balance.length == 1 ? [balance[0], '0x0'] : balance),
      trailing: onSwitch == null
          ? Container(width: 8)
          : CupertinoSwitch(
              value: switchValue,
              onChanged: onSwitch,
            ),
    );
  }
}
