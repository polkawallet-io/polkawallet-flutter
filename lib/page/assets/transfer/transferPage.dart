import 'dart:convert';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:polka_wallet/common/components/roundedButton.dart';
import 'package:polka_wallet/common/regInputFormatter.dart';
import 'package:polka_wallet/page/account/scanPage.dart';
import 'package:polka_wallet/page/account/txConfirmPage.dart';
import 'package:polka_wallet/page/assets/asset/assetPage.dart';
import 'package:polka_wallet/page/profile/contacts/contactListPage.dart';
import 'package:polka_wallet/store/account.dart';
import 'package:polka_wallet/store/app.dart';
import 'package:polka_wallet/utils/UI.dart';
import 'package:polka_wallet/utils/format.dart';
import 'package:polka_wallet/utils/i18n/index.dart';

class TransferPage extends StatefulWidget {
  const TransferPage(this.store);

  static final String route = '/assets/transfer';
  final AppStore store;

  @override
  _TransferPageState createState() => _TransferPageState(store);
}

class _TransferPageState extends State<TransferPage> {
  _TransferPageState(this.store);

  final AppStore store;

  final _formKey = GlobalKey<FormState>();

  final TextEditingController _addressCtrl = new TextEditingController();
  final TextEditingController _amountCtrl = new TextEditingController();

  void _handleSubmit() {
    if (_formKey.currentState.validate()) {
      int decimals = store.settings.networkState.tokenDecimals;
      var args = {
        "title": I18n.of(context).assets['transfer'],
        "txInfo": {
          "module": 'balances',
          "call": 'transfer',
        },
        "detail": jsonEncode({
          "destination": _addressCtrl.text.trim(),
          "amount": _amountCtrl.text.trim(),
        }),
        "params": [
          // params.to
          _addressCtrl.text.trim(),
          // params.amount
          (double.parse(_amountCtrl.text.trim()) * pow(10, decimals)).toInt(),
        ],
        'onFinish': (BuildContext txPageContext) {
          final Map routeArgs = ModalRoute.of(context).settings.arguments;
          Navigator.popUntil(
              txPageContext, ModalRoute.withName(routeArgs['redirect']));
          // user may route to transfer page from asset page
          // or from home page with QRCode Scanner
          if (routeArgs['redirect'] == AssetPage.route) {
            globalAssetRefreshKey.currentState.show();
          }
          if (routeArgs['redirect'] == '/') {
            globalBalanceRefreshKey.currentState.show();
          }
        }
      };
      Navigator.of(context).pushNamed(TxConfirmPage.route, arguments: args);
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final Map args = ModalRoute.of(context).settings.arguments;
    if (args['address'] != null) {
      setState(() {
        _addressCtrl.text = args['address'];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Observer(
      builder: (_) {
        final Map<String, String> dic = I18n.of(context).assets;
        String symbol = store.settings.networkState.tokenSymbol;
        int decimals = store.settings.networkState.tokenDecimals;

        BigInt balance = Fmt.balanceInt(store.assets.balances[symbol]);
        BigInt available = balance;
        bool hasStakingData = store.staking.ledger['stakingLedger'] != null;
        if (hasStakingData) {
          String stashId = store.staking.ledger['stakingLedger']['stash'];
          bool isStash = store.staking.ledger['accountId'] == stashId;
          if (isStash) {
            BigInt bonded = BigInt.parse(
                store.staking.ledger['stakingLedger']['active'].toString());
            BigInt unlocking = store.staking.accountUnlockingTotal;
            available = balance - bonded - unlocking;
          }
        }

        return Scaffold(
          appBar: AppBar(
            title: Text('${dic['transfer']} $symbol'),
            centerTitle: true,
            actions: <Widget>[
              IconButton(
                icon: Image.asset('assets/images/assets/Menu_scan.png'),
                onPressed: () async {
                  var to =
                      await Navigator.of(context).pushNamed(ScanPage.route);
                  setState(() {
                    _addressCtrl.text = to;
                  });
                },
              )
            ],
          ),
          body: SafeArea(
            child: Builder(
              builder: (BuildContext context) {
                return Column(
                  children: <Widget>[
                    Expanded(
                      child: Form(
                        key: _formKey,
                        child: ListView(
                          padding: EdgeInsets.fromLTRB(16, 0, 16, 16),
                          children: <Widget>[
                            TextFormField(
                              decoration: InputDecoration(
                                  hintText: dic['address'],
                                  labelText: dic['address'],
                                  suffix: IconButton(
                                    icon: Image.asset(
                                        'assets/images/profile/address.png'),
                                    onPressed: () async {
                                      var to = await Navigator.of(context)
                                          .pushNamed(ContactListPage.route);
                                      if (to != null) {
                                        setState(() {
                                          _addressCtrl.text =
                                              (to as AccountData).address;
                                        });
                                      }
                                    },
                                  )),
                              controller: _addressCtrl,
                              validator: (v) {
                                return Fmt.isAddress(v.trim())
                                    ? null
                                    : dic['address.error'];
                              },
                            ),
                            TextFormField(
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
                              keyboardType: TextInputType.numberWithOptions(
                                  decimal: true),
                              validator: (v) {
                                if (v.isEmpty) {
                                  return dic['amount.error'];
                                }
                                if (double.parse(v.trim()) >=
                                    available / BigInt.from(pow(10, decimals)) -
                                        0.02) {
                                  return dic['amount.low'];
                                }
                                return null;
                              },
                            ),
                            Padding(
                              padding: EdgeInsets.only(top: 16),
                              child: Text(
                                  'existentialDeposit: ${store.settings.existentialDeposit} $symbol',
                                  style: TextStyle(
                                      fontSize: 16, color: Colors.black54)),
                            ),
                            Padding(
                              padding: EdgeInsets.only(top: 16),
                              child: Text(
                                  'TransferFee: ${store.settings.transactionBaseFee} $symbol',
                                  style: TextStyle(
                                      fontSize: 16, color: Colors.black54)),
                            ),
                            Padding(
                              padding: EdgeInsets.only(top: 16),
                              child: Text(
                                  'transactionByteFee: ${store.settings.transactionByteFee} $symbol',
                                  style: TextStyle(
                                      fontSize: 16, color: Colors.black54)),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.all(16),
                      child: RoundedButton(
                        text: I18n.of(context).assets['make'],
                        onPressed: _handleSubmit,
                      ),
                    )
                  ],
                );
              },
            ),
          ),
        );
      },
    );
  }
}
