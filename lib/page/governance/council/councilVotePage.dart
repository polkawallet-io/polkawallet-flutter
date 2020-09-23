import 'dart:convert';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:polka_wallet/common/components/addressIcon.dart';
import 'package:polka_wallet/common/components/roundedButton.dart';
import 'package:polka_wallet/page/account/txConfirmPage.dart';
import 'package:polka_wallet/page/governance/council/candidateListPage.dart';
import 'package:polka_wallet/page/governance/council/councilPage.dart';
import 'package:polka_wallet/store/app.dart';
import 'package:polka_wallet/utils/UI.dart';
import 'package:polka_wallet/utils/format.dart';
import 'package:polka_wallet/utils/i18n/index.dart';

class CouncilVotePage extends StatefulWidget {
  CouncilVotePage(this.store);
  static final String route = '/gov/vote';
  final AppStore store;
  @override
  _CouncilVote createState() => _CouncilVote(store);
}

class _CouncilVote extends State<CouncilVotePage> {
  _CouncilVote(this.store);
  final AppStore store;

  final _formKey = GlobalKey<FormState>();

  final TextEditingController _amountCtrl = new TextEditingController();

  List<List> _selected = List<List>();

  Future<void> _handleCandidateSelect() async {
    var res = await Navigator.of(context)
        .pushNamed(CandidateListPage.route, arguments: _selected);
    if (res != null) {
      setState(() {
        _selected = List<List>.of(res);
      });
    }
  }

  void _onSubmit() {
    if (_formKey.currentState.validate()) {
      var govDic = I18n.of(context).gov;
      int decimals = store.settings.networkState.tokenDecimals;
      String amt = _amountCtrl.text.trim();
      List selected = _selected.map((i) => i[0]).toList();
      var args = {
        "title": govDic['vote.candidate'],
        "txInfo": {
          "module": 'electionsPhragmen',
          "call": 'vote',
        },
        "detail": jsonEncode({
          "votes": selected,
          "voteValue": amt,
        }),
        "params": [
          // "votes"
          selected,
          // "voteValue"
          Fmt.tokenInt(amt, decimals).toString(),
        ],
        'onFinish': (BuildContext txPageContext, Map res) {
          Navigator.popUntil(
              txPageContext, ModalRoute.withName(CouncilPage.route));
          globalCouncilRefreshKey.currentState.show();
        }
      };
      Navigator.of(context).pushNamed(TxConfirmPage.route, arguments: args);
    }
  }

  @override
  Widget build(BuildContext context) {
    var govDic = I18n.of(context).gov;
    return Scaffold(
      appBar: AppBar(
        title: Text(govDic['vote.candidate']),
        centerTitle: true,
      ),
      body: Observer(
        builder: (_) {
          final Map<String, String> dic = I18n.of(context).assets;
          int decimals = store.settings.networkState.tokenDecimals;
          String symbol = store.settings.networkState.tokenSymbol;

          BigInt balance = store.assets.balances[symbol].freeBalance;

          return SafeArea(
            child: Column(
              children: <Widget>[
                Expanded(
                  child: Form(
                    key: _formKey,
                    child: ListView(
                      children: <Widget>[
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
                                  balance / BigInt.from(pow(10, decimals)) -
                                      0.001) {
                                return dic['amount.low'];
                              }
                              return null;
                            },
                          ),
                        ),
                        ListTile(
                          title: Text(govDic['candidate']),
                          trailing: Icon(Icons.arrow_forward_ios, size: 18),
                          onTap: () {
                            _handleCandidateSelect();
                          },
                        ),
                        Column(
                          children: _selected.map((i) {
                            var accInfo = store.account.addressIndexMap[i[0]];
                            return Container(
                              margin: EdgeInsets.fromLTRB(16, 0, 16, 8),
                              child: Row(
                                children: <Widget>[
                                  Container(
                                    width: 32,
                                    margin: EdgeInsets.only(right: 8),
                                    child: AddressIcon(
                                      i[0],
                                      size: 32,
                                      tapToCopy: false,
                                    ),
                                  ),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Fmt.accountDisplayName(i[0], accInfo),
                                        Text(
                                          Fmt.address(i[0]),
                                          style:
                                              TextStyle(color: Colors.black54),
                                        ),
                                      ],
                                    ),
                                  )
                                ],
                              ),
                            );
                          }).toList(),
                        )
                      ],
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.all(16),
                  child: RoundedButton(
                    text: I18n.of(context).home['submit.tx'],
                    onPressed: _selected.length == 0 ? null : _onSubmit,
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
