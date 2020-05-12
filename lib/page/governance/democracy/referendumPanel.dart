import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:polka_wallet/common/components/roundedButton.dart';
import 'package:polka_wallet/common/components/roundedCard.dart';
import 'package:polka_wallet/page/governance/democracy/referendumVotePage.dart';
import 'package:polka_wallet/store/gov/types/referendumInfoData.dart';
import 'package:polka_wallet/utils/format.dart';
import 'package:polka_wallet/utils/i18n/index.dart';

// TODO: adjust vote amount times display
class ReferendumPanel extends StatelessWidget {
  ReferendumPanel({
    this.symbol,
    this.data,
    this.bestNumber,
    this.voted,
  });

  final String symbol;
  final ReferendumInfo data;
  final int bestNumber;
  final int voted;

  @override
  Widget build(BuildContext context) {
    var dic = I18n.of(context).gov;
    List<Widget> list = <Widget>[
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: <Widget>[
        Text(
          data.image['proposal'] != null
              ? '${data.image['proposal']['section']}.${data.image['proposal']['method']}'
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
      list.add(
          ReferendumArgsList(data.detail['params'], data.image['proposal']));
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
          Text(Fmt.address(data.imageHash))
        ],
      ),
    ));
    list.add(Divider(height: 32));

    double widthFull = MediaQuery.of(context).size.width - 72;
//      int votedTotal = int.parse(votes['votedTotal'].toString());
    BigInt votedAye = BigInt.parse(data.votedAye);
    BigInt votedNay = BigInt.parse(data.votedNay);
    BigInt votedTotalCalc = votedAye + votedNay;
    double yes = votedAye / votedTotalCalc;
    double widthYes =
        votedTotalCalc > BigInt.zero ? yes * widthFull : widthFull / 2;
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
                border:
                    Border(bottom: BorderSide(width: 6, color: Colors.orange))),
          ),
        ),
        Container(
          padding: EdgeInsets.only(bottom: 4),
          margin: EdgeInsets.only(bottom: 4),
          width: widthYes > widthMin ? widthYes : widthMin,
          decoration: BoxDecoration(
              border: Border(bottom: BorderSide(width: 6, color: Colors.pink))),
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

    list.add(Container(
      margin: EdgeInsets.only(top: 16),
      child: Row(
        children: <Widget>[
          Expanded(
            child: RoundedButton(
              color: Colors.orange,
              text: '${voted < 0 ? dic['voted'] : ''} ${dic['no']}',
              onPressed: voted >= 0
                  ? () => Navigator.of(context).pushNamed(
                      ReferendumVotePage.route,
                      arguments: {'referenda': data, 'voteYes': false})
                  : null,
            ),
          ),
          Container(width: 8),
          Expanded(
            child: RoundedButton(
              text: '${voted > 0 ? dic['voted'] : ''} ${dic['yes']}',
              onPressed: voted <= 0
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
                      style: Theme.of(context).textTheme.display4,
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
