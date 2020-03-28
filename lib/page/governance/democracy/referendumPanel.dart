import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:polka_wallet/common/components/roundedButton.dart';
import 'package:polka_wallet/common/components/roundedCard.dart';
import 'package:polka_wallet/page/governance/democracy/referendumVotePage.dart';
import 'package:polka_wallet/store/governance.dart';
import 'package:polka_wallet/utils/format.dart';
import 'package:polka_wallet/utils/i18n/index.dart';

class ReferendumPanel extends StatelessWidget {
  ReferendumPanel({
    this.symbol,
    this.data,
    this.bestNumber,
    this.votes,
    this.voted,
  });

  final String symbol;
  final ReferendumInfo data;
  final int bestNumber;
  final Map votes;
  final int voted;

  @override
  Widget build(BuildContext context) {
    var dic = I18n.of(context).gov;
    List<Widget> list = <Widget>[
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: <Widget>[
        Text(
          data.proposal != null
              ? '${data.proposal['section']}.${data.proposal['method']}'
              : '-',
          style: Theme.of(context).textTheme.display4,
        ),
        Text(
          '#${data.index}',
          style: Theme.of(context).textTheme.display4,
        ),
      ]),
      Divider(),
      Row(
        children: <Widget>[
          Container(
            padding: EdgeInsets.only(right: 8),
            child: Image.asset('assets/images/gov/time.png'),
          ),
          Text(
            '${data.status['end'] + data.status['delay'] - bestNumber} blocks ${dic['end']}',
            style: TextStyle(color: Colors.lightGreen),
          )
        ],
      ),
      Container(
        padding: EdgeInsets.only(top: 16),
        child: Text(data.detail['content'].toString().trim()),
      )
    ];
    if (data.detail['params'] != null && data.detail['params'].length > 0) {
      List<Widget> args = [];
      data.detail['params'].asMap().forEach((k, v) {
        args.add(Container(
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
                      data.proposal['args'][k].toString(),
                      style: Theme.of(context).textTheme.display4,
                    )
                  ],
                ),
              )
            ],
          ),
        ));
      });
      list.add(Container(
        margin: EdgeInsets.only(top: 8, bottom: 8),
        decoration: BoxDecoration(
            border: Border(
                left: BorderSide(
                    color: Theme.of(context).dividerColor, width: 3))),
        child: Column(
          children: args,
        ),
      ));
    }
    list.add(Container(
      padding: EdgeInsets.only(top: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            '${dic['proposal']} hash',
            style: TextStyle(color: Colors.black54),
          ),
          Text(Fmt.address(data.hash))
        ],
      ),
    ));
    list.add(Divider(height: 32));

    if (votes != null) {
      double widthFull = MediaQuery.of(context).size.width - 72;
      int votedTotal = int.parse(votes['votedTotal'].toString());
      int votedAye = int.parse(votes['votedAye'].toString());
      int votedNay = int.parse(votes['votedNay'].toString());
      double yes = int.parse(votes['votedAye'].toString()) / votedTotal;
      double widthYes = votedTotal > 0 ? yes * widthFull : widthFull / 2;
      double widthMin = 6;
      list.add(Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[Text(dic['no']), Text(dic['yes'])],
      ));
      list.add(Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Expanded(
            child: Container(
              padding: EdgeInsets.only(bottom: 4),
              margin: EdgeInsets.only(bottom: 4),
              decoration: BoxDecoration(
                  border: Border(
                      bottom: BorderSide(width: 6, color: Colors.orange))),
            ),
          ),
          Container(
            padding: EdgeInsets.only(bottom: 4),
            margin: EdgeInsets.only(bottom: 4),
            width: widthYes > widthMin ? widthYes : widthMin,
            decoration: BoxDecoration(
                border:
                    Border(bottom: BorderSide(width: 6, color: Colors.purple))),
          )
        ],
      ));
      list.add(Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text('${Fmt.token(votedNay)} $symbol'),
          Text('${Fmt.token(votedAye)} $symbol')
        ],
      ));
    }

    bool votedYes = (voted ?? 0) > 6;
    list.add(Container(
      margin: EdgeInsets.only(top: 16),
      child: Row(
        children: <Widget>[
          Expanded(
            child: RoundedButton(
              color: Colors.orange,
              text:
                  '${voted != null && !votedYes ? dic['voted'] : ''} ${dic['no']}',
              onPressed: voted == null || votedYes
                  ? () => Navigator.of(context).pushNamed(
                      ReferendumVotePage.route,
                      arguments: {'referenda': data, 'voteYes': false})
                  : null,
            ),
          ),
          Container(width: 8),
          Expanded(
            child: RoundedButton(
              text:
                  '${voted != null && votedYes ? dic['voted'] : ''} ${dic['yes']}',
              onPressed: voted == null || !votedYes
                  ? () => Navigator.of(context).pushNamed(
                      ReferendumVotePage.route,
                      arguments: {'referenda': data, 'voteYes': true})
                  : null,
            ),
          )
        ],
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
