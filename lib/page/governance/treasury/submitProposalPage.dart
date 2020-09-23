import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:polka_wallet/common/components/addressFormItem.dart';
import 'package:polka_wallet/common/components/roundedButton.dart';
import 'package:polka_wallet/page/account/txConfirmPage.dart';
import 'package:polka_wallet/page/governance/treasury/treasuryPage.dart';
import 'package:polka_wallet/page/profile/contacts/contactListPage.dart';
import 'package:polka_wallet/store/account/types/accountData.dart';
import 'package:polka_wallet/store/app.dart';
import 'package:polka_wallet/utils/UI.dart';
import 'package:polka_wallet/utils/format.dart';
import 'package:polka_wallet/utils/i18n/index.dart';

class SubmitProposalPage extends StatefulWidget {
  SubmitProposalPage(this.store);

  static const String route = '/gov/treasury/proposal/add';

  final AppStore store;

  @override
  _SubmitProposalPageState createState() => _SubmitProposalPageState();
}

class _SubmitProposalPageState extends State<SubmitProposalPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _amountCtrl = new TextEditingController();

  AccountData _beneficiary;

  Future<void> _onSubmit() async {
    if (_formKey.currentState.validate()) {
      var dic = I18n.of(context).gov;
      int decimals = widget.store.settings.networkState.tokenDecimals;
      String amt = _amountCtrl.text.trim();
      String address = Fmt.addressOfAccount(_beneficiary, widget.store);
      var args = {
        "title": dic['treasury.submit'],
        "txInfo": {
          "module": 'treasury',
          "call": 'proposeSpend',
        },
        "detail": jsonEncode({
          "value": amt,
          "beneficiary": address,
        }),
        "params": [
          // "value"
          Fmt.tokenInt(amt, decimals).toString(),
          // "beneficiary"
          address,
        ],
        'onFinish': (BuildContext txPageContext, Map res) {
          Navigator.popUntil(
              txPageContext, ModalRoute.withName(TreasuryPage.route));

          globalProposalsRefreshKey.currentState.show();
        }
      };
      Navigator.of(context).pushNamed(TxConfirmPage.route, arguments: args);
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        _beneficiary = widget.store.account.currentAccount;
      });
    });
  }

  @override
  void dispose() {
    _amountCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Map dic = I18n.of(context).gov;
    final Map dicAsset = I18n.of(context).assets;
    final int decimals = widget.store.settings.networkState.tokenDecimals;
    final String symbol = widget.store.settings.networkState.tokenSymbol;
    final BigInt bondPercentage = Fmt.balanceInt(widget
            .store.settings.networkConst['treasury']['proposalBond']
            .toString()) *
        BigInt.from(100) ~/
        BigInt.from(1000000);
    final BigInt minBond = Fmt.balanceInt(widget
        .store.settings.networkConst['treasury']['proposalBondMinimum']
        .toString());
    return Scaffold(
      appBar: AppBar(title: Text(dic['treasury.submit']), centerTitle: true),
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Expanded(
              child: _beneficiary == null
                  ? Container()
                  : ListView(
                      padding: EdgeInsets.all(16),
                      children: <Widget>[
                        AddressFormItem(
                          _beneficiary,
                          label: dic['treasury.beneficiary'],
                          onTap: () async {
                            final acc = await Navigator.of(context)
                                .pushNamed(ContactListPage.route);
                            if (acc != null) {
                              setState(() {
                                _beneficiary = acc;
                              });
                            }
                          },
                        ),
                        Form(
                          key: _formKey,
                          child: Column(
                            children: [
                              TextFormField(
                                decoration: InputDecoration(
                                  hintText: dicAsset['amount'],
                                  labelText: '${dicAsset['amount']} ($symbol)',
                                ),
                                inputFormatters: [
                                  UI.decimalInputFormatter(decimals)
                                ],
                                controller: _amountCtrl,
                                keyboardType: TextInputType.numberWithOptions(
                                    decimal: true),
                                validator: (v) {
                                  if (v.isEmpty) {
                                    return dicAsset['amount.error'];
                                  }
                                  return null;
                                },
                              ),
                              TextFormField(
                                decoration: InputDecoration(
                                  labelText:
                                      '${dic['treasury.bond']} ($symbol)',
                                ),
                                initialValue: '$bondPercentage%',
                                readOnly: true,
                                style: TextStyle(
                                    color: Theme.of(context).disabledColor),
                                validator: (v) {
                                  final BigInt bond = Fmt.tokenInt(
                                          _amountCtrl.text.trim(), decimals) *
                                      bondPercentage ~/
                                      BigInt.from(100);
                                  if (widget.store.assets.balances[symbol]
                                          .transferable <=
                                      bond) {
                                    return dicAsset['amount.low'];
                                  }
                                  return null;
                                },
                              ),
                              TextFormField(
                                decoration: InputDecoration(
                                  labelText:
                                      '${dic['treasury.bond.min']} ($symbol)',
                                ),
                                initialValue: Fmt.priceCeilBigInt(
                                  minBond,
                                  decimals,
                                  lengthFixed: 3,
                                ),
                                readOnly: true,
                                style: TextStyle(
                                    color: Theme.of(context).disabledColor),
                                validator: (v) {
                                  if (widget.store.assets.balances[symbol]
                                          .transferable <=
                                      minBond) {
                                    return dicAsset['amount.low'];
                                  }
                                  return null;
                                },
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
            ),
            Padding(
              padding: EdgeInsets.all(16),
              child: RoundedButton(
                text: dic['treasury.submit'],
                onPressed: _onSubmit,
              ),
            )
          ],
        ),
      ),
    );
  }
}
