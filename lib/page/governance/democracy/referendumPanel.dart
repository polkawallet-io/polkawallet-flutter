import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:polka_wallet/common/components/roundedButton.dart';
import 'package:polka_wallet/common/components/roundedCard.dart';
import 'package:polka_wallet/store/governance.dart';
import 'package:polka_wallet/utils/format.dart';

class ReferendumPanel extends StatelessWidget {
  ReferendumPanel(
      {this.symbol, this.data, this.bestNumber, this.votes, this.onVote});

  final String symbol;
  final ReferendumInfo data;
  final int bestNumber;
  final ReferendumVotes votes;
  final Function(int, bool) onVote;

  @override
  Widget build(BuildContext context) {
    List<Widget> list = <Widget>[
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: <Widget>[
        Text(
          '${data.proposal['section']}.${data.proposal['method']}',
          style: Theme.of(context).textTheme.display4,
        ),
        Text('#${data.index}'),
      ]),
      Divider(),
      Row(
        children: <Widget>[
          Container(
            child: Image.asset('assets/images/gov/time.png'),
          ),
          Text('${data.info['end'] - bestNumber} blocks end')
        ],
      ),
      Container(
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[Text('prop hash'), Text(Fmt.address(data.hash))],
      ),
    ));
    list.add(Divider());

    if (votes.votedTotal > 0) {
      double widthFull = MediaQuery.of(context).size.width - 72;
      double yes = votes.votedAye / votes.votedTotal;
      double widthYes = yes * widthFull;
      double widthMin = 6;
      list.add(Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[Text('nay'), Text('aye')],
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
                    Border(bottom: BorderSide(width: 6, color: Colors.pink))),
          )
        ],
      ));
      list.add(Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text('${Fmt.token(votes.votedNay)} $symbol'),
          Text('${Fmt.token(votes.votedAye)} $symbol')
        ],
      ));
    }

    list.add(Container(
      margin: EdgeInsets.only(top: 16),
      child: Row(
        children: <Widget>[
          Expanded(
            child: RoundedButton(
              color: Colors.orange,
              text: 'n',
              onPressed: () => onVote(data.index, false),
            ),
          ),
          Container(width: 8),
          Expanded(
            child: RoundedButton(
              text: 'y',
              onPressed: () => onVote(data.index, true),
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
