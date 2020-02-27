import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:polka_wallet/common/regInputFormatter.dart';
import 'package:polka_wallet/store/app.dart';
import 'package:polka_wallet/utils/format.dart';
import 'package:polka_wallet/utils/i18n/index.dart';

class CouncilVote extends StatefulWidget {
  CouncilVote(this.store);
  final AppStore store;
  @override
  _CouncilVote createState() => _CouncilVote(store);
}

class _CouncilVote extends State<CouncilVote> {
  _CouncilVote(this.store);
  final AppStore store;

  final _formKey = GlobalKey<FormState>();

  final TextEditingController _amountCtrl = new TextEditingController();

  List<String> _selected = List<String>();

  Future<void> _handleCandidateSelect() async {
    List<String> res =
        await Navigator.pushNamed(context, '/council/candidates');
    if (res != null && res.length > 0) {
      _selected.addAll(res);
    }
  }

  Widget _buildSelectedList() {
    return Column(
      children: List<Widget>.from(_selected.map((address) => Text(address))),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('vote candi..'),
        centerTitle: true,
      ),
      body: Observer(
        builder: (_) {
          final Map<String, String> dic = I18n.of(context).assets;
          int decimals = store.settings.networkState.tokenDecimals;

          int balance = Fmt.balanceInt(store.assets.balance);
          int available = balance;
          bool hasStakingData = store.staking.ledger['stakingLedger'] != null;
          if (hasStakingData) {
            int bonded = store.staking.ledger['stakingLedger']['active'];
            int unlocking = 0;
            List unlockingList =
                store.staking.ledger['stakingLedger']['unlocking'];
            unlockingList.forEach((i) => unlocking += i['value']);
            available = balance - bonded - unlocking;
          }

          return ListView(
            children: <Widget>[
              Form(
                key: _formKey,
                child: Column(
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.all(16),
                      child: TextFormField(
                        decoration: InputDecoration(labelText: dic['address']),
                        initialValue: store.account.currentAccount.address,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(16),
                      child: TextFormField(
                        decoration: InputDecoration(
                          hintText: dic['amount'],
                          labelText:
                              '${dic['amount']} (${dic['balance']}: ${Fmt.token(available)})',
                        ),
                        inputFormatters: [
                          RegExInputFormatter.withRegex(
                              '^[0-9]{0,6}(\\.[0-9]{0,$decimals})?\$')
                        ],
                        controller: _amountCtrl,
                        keyboardType:
                            TextInputType.numberWithOptions(decimal: true),
                        validator: (v) {
                          if (v.isEmpty) {
                            return dic['amount.error'];
                          }
                          if (double.parse(v.trim()) >=
                              available / pow(10, decimals) - 0.02) {
                            return dic['amount.low'];
                          }
                          return null;
                        },
                      ),
                    ),
                    ListTile(
                      title: Text(I18n.of(context).gov['candidate']),
                      trailing: Icon(Icons.arrow_forward_ios),
                      onTap: () {
                        print('select candidate');
                        _handleCandidateSelect();
                      },
                    ),
                    _buildSelectedList()
                  ],
                ),
              )
            ],
          );
        },
      ),
    );
  }
}
