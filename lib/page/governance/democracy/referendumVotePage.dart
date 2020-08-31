import 'dart:convert';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:polka_wallet/common/components/roundedButton.dart';
import 'package:polka_wallet/page/account/txConfirmPage.dart';
import 'package:polka_wallet/page/governance/democracy/democracyPage.dart';
import 'package:polka_wallet/store/app.dart';
import 'package:polka_wallet/store/gov/types/referendumInfoData.dart';
import 'package:polka_wallet/utils/UI.dart';
import 'package:polka_wallet/utils/format.dart';
import 'package:polka_wallet/utils/i18n/index.dart';

class ReferendumVotePage extends StatefulWidget {
  ReferendumVotePage(this.store);
  static final String route = '/gov/referenda';
  final AppStore store;
  @override
  _ReferendumVoteState createState() => _ReferendumVoteState(store);
}

class _ReferendumVoteState extends State<ReferendumVotePage> {
  _ReferendumVoteState(this.store);
  final AppStore store;

  final _formKey = GlobalKey<FormState>();

  final TextEditingController _amountCtrl = new TextEditingController();

  final List<int> _voteConvictionOptions = [0, 1, 2, 3, 4, 5, 6];

  int _voteConviction = 0;

  void _onSubmit(int id, bool voteYes) {
    if (_formKey.currentState.validate()) {
      var govDic = I18n.of(context).gov;
      int decimals = store.settings.networkState.tokenDecimals;
      String amt = _amountCtrl.text.trim();
      Map vote = {
        'balance': (double.parse(amt) * pow(10, decimals)).toInt(),
        'vote': {'aye': voteYes, 'conviction': _voteConviction},
      };
      var args = {
        "title": govDic['vote.proposal'],
        "txInfo": {
          "module": 'democracy',
          "call": 'vote',
        },
        "detail": jsonEncode({
          "id": id,
          "balance": amt,
          "vote": vote['vote'],
        }),
        "params": [
          // "id"
          id,
          // "options"
          {"Standard": vote},
        ],
        'onFinish': (BuildContext txPageContext, Map res) {
          Navigator.popUntil(
              txPageContext, ModalRoute.withName(DemocracyPage.route));
          globalDemocracyRefreshKey.currentState.show();
        }
      };
      Navigator.of(context).pushNamed(TxConfirmPage.route, arguments: args);
    }
  }

  String _getConvictionLabel(int value) {
    var dicGov = I18n.of(context).gov;
    final Map conviction =
        value > 0 ? store.gov.voteConvictions[value - 1] : {};
    return value == 0
        ? dicGov['locked.no']
        : '${dicGov['locked']} ${conviction['period']} ${dicGov['day']} (${conviction['lock']}x)';
  }

  void _showConvictionSelect() {
    showCupertinoModalPopup(
      context: context,
      builder: (_) => Container(
        height: MediaQuery.of(context).copyWith().size.height / 3,
        child: CupertinoPicker(
          backgroundColor: Colors.white,
          itemExtent: 58,
          scrollController:
              FixedExtentScrollController(initialItem: _voteConviction),
          children: _voteConvictionOptions.map((i) {
            return Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  _getConvictionLabel(i),
                  style: TextStyle(fontSize: 16),
                ));
          }).toList(),
          onSelectedItemChanged: (v) {
            setState(() {
              _voteConviction = v;
            });
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    var govDic = I18n.of(context).gov;
    return Scaffold(
      appBar: AppBar(
        title: Text(govDic['vote.proposal']),
        centerTitle: true,
      ),
      body: Observer(
        builder: (_) {
          final Map<String, String> dic = I18n.of(context).assets;
          final Map<String, String> dicGov = I18n.of(context).gov;
          int decimals = store.settings.networkState.tokenDecimals;
          String symbol = store.settings.networkState.tokenSymbol;

          BigInt balance = store.assets.balances[symbol].freeBalance;

          Map args = ModalRoute.of(context).settings.arguments;
          ReferendumInfo info = args['referenda'];
          bool voteYes = args['voteYes'];
          return SafeArea(
            child: Column(
              children: <Widget>[
                Expanded(
                  child: Form(
                    key: _formKey,
                    child: ListView(
                      children: <Widget>[
                        Padding(
                          padding: EdgeInsets.all(16),
                          child: Text(
                            dicGov[voteYes ? 'yes.text' : 'no.text'],
                            style: Theme.of(context).textTheme.headline4,
                          ),
                        ),
                        Padding(
                          padding:
                              EdgeInsets.only(left: 16, right: 16, bottom: 16),
                          child: TextFormField(
                            decoration: InputDecoration(
                              hintText: dic['amount'],
                              labelText:
                                  '${dic['amount']} (${dic['balance']}: ${Fmt.token(balance, decimals)})',
                            ),
                            inputFormatters: [
                              UI.decimalInputFormatter(decimals)
                            ],
                            controller: _amountCtrl,
                            keyboardType:
                                TextInputType.numberWithOptions(decimal: true),
                            validator: (v) {
                              if (v.isEmpty) {
                                return dic['amount.error'];
                              }
                              if (double.parse(v.trim()) >=
                                  balance / BigInt.from(pow(10, decimals))) {
                                return dic['amount.low'];
                              }
                              return null;
                            },
                          ),
                        ),
                        ListTile(
                          title: Text(dicGov['locked']),
                          subtitle: Text(_getConvictionLabel(_voteConviction)),
                          trailing: Icon(Icons.arrow_forward_ios, size: 18),
                          onTap: _showConvictionSelect,
                        ),
                      ],
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.all(16),
                  child: RoundedButton(
                    text: I18n.of(context).home['submit.tx'],
                    onPressed: () => _onSubmit(info.index, voteYes),
                  ),
                )
              ],
            ),
          );
        },
      ),
    );
  }
}
