import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:polka_wallet/common/components/TapTooltip.dart';
import 'package:polka_wallet/common/components/infoItem.dart';
import 'package:polka_wallet/common/components/outlinedButtonSmall.dart';
import 'package:polka_wallet/common/components/roundedCard.dart';
import 'package:polka_wallet/page/governance/council/motionDetailPage.dart';
import 'package:polka_wallet/page/governance/democracy/referendumVotePage.dart';
import 'package:polka_wallet/store/gov/types/referendumInfoData.dart';
import 'package:polka_wallet/utils/format.dart';
import 'package:polka_wallet/utils/i18n/index.dart';

class ReferendumPanel extends StatelessWidget {
  ReferendumPanel({
    this.symbol,
    this.decimals,
    this.data,
    this.bestNumber,
    this.onCancelVote,
    this.blockDuration,
    this.links,
  });

  final String symbol;
  final int decimals;
  final ReferendumInfo data;
  final int bestNumber;
  final Function(int) onCancelVote;
  final int blockDuration;
  final Widget links;

  @override
  Widget build(BuildContext context) {
    int endLeft = data.status['end'] - bestNumber;
    int activateLeft = endLeft + data.status['delay'];
    var dic = I18n.of(context).gov;
    List<Widget> list = <Widget>[
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: <Widget>[
        Text(
          data.image != null && data.image['proposal'] != null
              ? '${data.image['proposal']['section']}.${data.image['proposal']['method']}'
              : '-',
          style: Theme.of(context).textTheme.headline4,
        ),
        Text(
          '#${data.index}',
          style: Theme.of(context).textTheme.headline4,
        ),
      ]),
      Divider(),
      Row(
        children: <Widget>[
          Container(
            width: 20,
            child: Image.asset('assets/images/gov/time.png'),
          ),
          Expanded(
            child: Text(
                '${dic['remain']} ${Fmt.blockToTime(endLeft, blockDuration)}',
                style: TextStyle(color: Colors.lightGreen)),
          ),
          Text(
            '${data.status['end'] - bestNumber} blocks',
            style: TextStyle(color: Colors.lightGreen),
          )
        ],
      ),
      Row(
        children: <Widget>[
          Container(width: 20),
          Expanded(
            child: Text(
                '${dic['activate']} ${Fmt.blockToTime(activateLeft, blockDuration)}',
                style: TextStyle(color: Colors.pink)),
          ),
          Text(
            '#${data.status['end'] + data.status['delay']}',
            style: TextStyle(color: Colors.pink),
          )
        ],
      ),
      data.detail['content'] != null
          ? Container(
              padding: EdgeInsets.only(top: 16),
              child: Text(data.detail['content'].toString().trim()),
            )
          : Container()
    ];
    if (data.detail['params'] != null && data.detail['params'].length > 0) {
      list.add(
          ReferendumArgsList(data.detail['params'], data.image['proposal']));
    }
    list.addAll([
      Padding(
        padding: EdgeInsets.only(top: 16, bottom: 8),
        child: ProposalArgsItem(
          label: Text('Hash'),
          content: Text(
            Fmt.address(data.imageHash, pad: 10),
            style: Theme.of(context).textTheme.headline4,
          ),
          margin: EdgeInsets.all(0),
        ),
      ),
      links,
    ]);
    list.add(Divider(height: 24));

    double widthFull = MediaQuery.of(context).size.width - 72;
//      int votedTotal = int.parse(votes['votedTotal'].toString());
    BigInt votedAye = BigInt.parse(data.votedAye);
    BigInt votedNay = BigInt.parse(data.votedNay);
    BigInt votedTotalCalc = votedAye + votedNay;
    double yes = votedAye / votedTotalCalc;
    double widthYes =
        votedTotalCalc > BigInt.zero ? yes * widthFull : widthFull / 2;
    double widthMin = 6;
    BigInt voteChange = data.isPassing
        ? Fmt.balanceInt(data.changeNay)
        : Fmt.balanceInt(data.changeAye);
    double yesChange = data.isPassing
        ? 1 - (votedNay + voteChange) / (votedTotalCalc + voteChange)
        : (votedAye + voteChange) / (votedTotalCalc + voteChange);
    double widthPointer =
        votedTotalCalc > BigInt.zero ? yesChange * widthFull : widthFull / 2;

    list.addAll([
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          data.isPassing
              ? Icon(Icons.check_circle, color: Colors.lightGreen, size: 20)
              : Icon(Icons.remove_circle, color: Colors.orange, size: 20),
          Padding(
            padding: EdgeInsets.only(left: 4),
            child: Text(
              dic['passing.${data.isPassing}'],
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[Text(dic['no']), Text(dic['yes'])],
      ),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Expanded(
            child: Container(),
          ),
          Container(
            padding: EdgeInsets.only(bottom: 8),
            width: widthPointer > widthMin ? widthPointer : widthMin,
            decoration: BoxDecoration(
                border: Border(left: BorderSide(width: 4, color: Colors.grey))),
          )
        ],
      ),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Expanded(
            child: Container(
              padding: EdgeInsets.only(bottom: 2),
              margin: EdgeInsets.only(bottom: 4),
              decoration: BoxDecoration(
                  border: Border(
                      bottom: BorderSide(width: 6, color: Colors.orange))),
            ),
          ),
          Container(
            padding: EdgeInsets.only(bottom: 2),
            margin: EdgeInsets.only(bottom: 4),
            width: widthYes > widthMin ? widthYes : widthMin,
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  width: 6,
                  color: Theme.of(context).primaryColor,
                ),
              ),
            ),
          )
        ],
      ),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text('${Fmt.token(votedNay, decimals)} $symbol'),
          Text('${Fmt.token(votedAye, decimals)} $symbol')
        ],
      ),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              TapTooltip(
                child: Icon(
                  data.isPassing ? Icons.arrow_drop_up : Icons.arrow_drop_down,
                  color: Theme.of(context).unselectedWidgetColor,
                ),
                message: data.isPassing
                    ? dic['vote.change.up']
                    : dic['vote.change.down'],
              ),
              Text(
                '${Fmt.balance(data.changeNay, decimals)} $symbol',
                style: TextStyle(
                    color: Theme.of(context).unselectedWidgetColor,
                    fontSize: 13),
              )
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              TapTooltip(
                child: Icon(
                  !data.isPassing ? Icons.arrow_drop_up : Icons.arrow_drop_down,
                  color: Theme.of(context).unselectedWidgetColor,
                ),
                message: !data.isPassing
                    ? dic['vote.change.up']
                    : dic['vote.change.down'],
              ),
              Text(
                '${Fmt.balance(data.changeAye, decimals)} $symbol',
                style: TextStyle(
                    color: Theme.of(context).unselectedWidgetColor,
                    fontSize: 13),
              )
            ],
          )
        ],
      )
    ]);

    if (data.userVoted != null) {
      String amount = Fmt.balance(
        data.userVoted['balance'].toString(),
        decimals,
      );
      String conviction = data.userVoted['vote']['conviction'] == 'None'
          ? '0.1x'
          : (data.userVoted['vote']['conviction'] as String).substring(6);
      String yes = data.userVoted['vote']['vote'] == 'Aye' ? 'yes' : 'no';
      list.add(
        Padding(
          padding: EdgeInsets.only(top: 12),
          child: Row(
            children: [
              InfoItem(
                title: '${dic['vote.my']} - $conviction ${dic[yes]}',
                content: '$amount $symbol',
              ),
              OutlinedButtonSmall(
                content: dic['vote.remove'],
                active: false,
                onPressed: () => onCancelVote(data.index),
              ),
            ],
          ),
        ),
      );

      list.add(Divider());
    }
    list.add(Container(
      margin: EdgeInsets.only(top: 16),
      child: ProposalVoteButtonsRow(
        isCouncil: true,
        isVotedNo: false,
        isVotedYes: false,
        onVote: (res) {
          Navigator.of(context).pushNamed(ReferendumVotePage.route,
              arguments: {'referenda': data, 'voteYes': res});
        },
      ),
    ));

    return RoundedCard(
      margin: EdgeInsets.all(16),
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: list,
      ),
    );
  }
}

class ReferendumArgsList extends StatefulWidget {
  ReferendumArgsList(this.args, this.proposal);

  final List args;
  final Map proposal;

  @override
  _ReferendumArgsList createState() => _ReferendumArgsList(args, proposal);
}

class _ReferendumArgsList extends State<ReferendumArgsList> {
  _ReferendumArgsList(this.args, this.proposal);

  final List args;
  final Map proposal;

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
      args.asMap().forEach((k, v) {
        items.add(Container(
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
                  children: <Widget>[
                    Text('${v['name']}: ${v['type']['type']}'),
                    Text(
                      proposal['args'][k].toString(),
                      style: Theme.of(context).textTheme.headline4,
                    )
                  ],
                ),
              )
            ],
          ),
        ));
      });
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
