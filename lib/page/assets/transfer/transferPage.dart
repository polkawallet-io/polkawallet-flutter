import 'dart:convert';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:polka_wallet/common/components/currencyWithIcon.dart';
import 'package:polka_wallet/common/components/roundedButton.dart';
import 'package:polka_wallet/common/consts/settings.dart';
import 'package:polka_wallet/common/regInputFormatter.dart';
import 'package:polka_wallet/page/account/scanPage.dart';
import 'package:polka_wallet/page/account/txConfirmPage.dart';
import 'package:polka_wallet/page/assets/asset/assetPage.dart';
import 'package:polka_wallet/page/assets/transfer/currencySelectPage.dart';
import 'package:polka_wallet/page/profile/contacts/contactListPage.dart';
import 'package:polka_wallet/store/account/types/accountData.dart';
import 'package:polka_wallet/store/app.dart';
import 'package:polka_wallet/utils/UI.dart';
import 'package:polka_wallet/utils/format.dart';
import 'package:polka_wallet/utils/i18n/index.dart';

class TransferPageParams {
  TransferPageParams(
      {this.symbol,
      this.address,
      this.redirect,
      this.isEncointerCommunityCurrency = false});
  final String address;
  final String redirect;
  final String symbol;
  final bool isEncointerCommunityCurrency;
}

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

  String _tokenSymbol;
  bool _isEncointerCommunityCurrency;

  Future<void> _selectCurrency() async {
    List<String> symbolOptions =
        List<String>.from(store.settings.networkConst['currencyIds']);

    var currency = await Navigator.of(context)
        .pushNamed(CurrencySelectPage.route, arguments: symbolOptions);

    if (currency != null) {
      setState(() {
        _tokenSymbol = currency;
      });
    }
  }

  void _handleSubmit() {
    if (_formKey.currentState.validate()) {
      String symbol = _tokenSymbol ?? store.settings.networkState.tokenSymbol;
      int decimals = store.settings.networkState.tokenDecimals;
      var args = {
        "title": I18n.of(context).assets['transfer'] + ' $symbol',
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
          Fmt.tokenInt(_amountCtrl.text.trim(), decimals: decimals).toString(),
        ],
      };
      // Todo: why was it here depending on the endpoint? Do we not want to facilitate ERT transfers?
      if (_isEncointerCommunityCurrency) {
        args['txInfo'] = {
          "module": 'encointerBalances',
          "call": 'transfer',
        };
        args['params'] = [
          // params.to
          _addressCtrl.text.trim(),
          // params.currencyId
          symbol,
          // params.amount
          _amountCtrl.text.trim(),
        ];
      }
      args['onFinish'] = (BuildContext txPageContext, Map res) {
        final TransferPageParams routeArgs =
            ModalRoute.of(context).settings.arguments;
        if (store.settings.endpointIsEncointer) {
          store.encointer.setTransferTxs([res]);
        }
        Navigator.popUntil(
            txPageContext, ModalRoute.withName(routeArgs.redirect));
        // user may route to transfer page from asset page
        // or from home page with QRCode Scanner
        if (routeArgs.redirect == AssetPage.route) {
          globalAssetRefreshKey.currentState.show();
        }
        if (routeArgs.redirect == '/') {
          globalBalanceRefreshKey.currentState.show();
        }
      };
      Navigator.of(context).pushNamed(TxConfirmPage.route, arguments: args);
    }
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final TransferPageParams args = ModalRoute.of(context).settings.arguments;
      if (args.address != null) {
        setState(() {
          _addressCtrl.text = args.address;
        });
      }
      if (args.symbol != null) {
        setState(() {
          _tokenSymbol = args.symbol;
        });
      }
    });
  }

  @override
  void dispose() {
    _addressCtrl.dispose();
    _amountCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Observer(
      builder: (_) {
        final Map<String, String> dic = I18n.of(context).assets;
        String baseTokenSymbol = store.settings.networkState.tokenSymbol;
        String symbol = _tokenSymbol ?? baseTokenSymbol;
        final bool isBaseToken = _tokenSymbol == baseTokenSymbol;
        List symbolOptions = store.settings.networkConst['currencyIds'];

        TransferPageParams params = ModalRoute.of(context).settings.arguments;
        _isEncointerCommunityCurrency = params.isEncointerCommunityCurrency;
        _tokenSymbol = params.symbol;

        int decimals = _isEncointerCommunityCurrency
            ? encointerTokenDecimals
            : store.settings.networkState.tokenDecimals;

        BigInt available; // BigInt
        available = _getAvailableEncointerOrBaseToken(isBaseToken, symbol);
        print(available);

        return Scaffold(
          appBar: AppBar(
            title: Text(dic['transfer']),
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
                                suffix: GestureDetector(
                                  child: Image.asset(
                                      'assets/images/profile/address.png'),
                                  onTap: () async {
                                    var to = await Navigator.of(context)
                                        .pushNamed(ContactListPage.route);
                                    if (to != null) {
                                      setState(() {
                                        _addressCtrl.text =
                                            (to as AccountData).address;
                                      });
                                    }
                                  },
                                ),
                              ),
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
                                    '${dic['amount']} (${dic['balance']}: ${Fmt.token(available, decimals: decimals)})',
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
                                if (balanceToLow(v, available, decimals)) {
                                  return dic['amount.low'];
                                }
                                return null;
                              },
                            ),
                            GestureDetector(
                              child: Container(
                                color: Theme.of(context).canvasColor,
                                margin: EdgeInsets.only(top: 16, bottom: 16),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Text(
                                          dic['currency'],
                                          style: TextStyle(
                                              color: Theme.of(context)
                                                  .unselectedWidgetColor),
                                        ),
                                        !_isEncointerCommunityCurrency
                                            ? CurrencyWithIcon(
                                                _tokenSymbol ?? baseTokenSymbol)
                                            : Text(Fmt.currencyIdentifier(
                                                _tokenSymbol,
                                                pad: 8)),
                                      ],
                                    ),
                                    Icon(
                                      Icons.arrow_forward_ios,
                                      size: 18,
                                    )
                                  ],
                                ),
                              ),
                              onTap: symbolOptions != null
                                  ? () => _selectCurrency()
                                  : null,
                            ),
                            Padding(
                              padding: EdgeInsets.only(top: 16),
                              child: Text(
                                  'existentialDeposit: ${store.settings.existentialDeposit} $baseTokenSymbol',
                                  style: TextStyle(
                                      fontSize: 16, color: Colors.black54)),
                            ),
//                            Padding(
//                              padding: EdgeInsets.only(top: 16),
//                              child: Text(
//                                  'TransferFee: ${store.settings.transactionBaseFee} $baseTokenSymbol',
//                                  style: TextStyle(
//                                      fontSize: 16, color: Colors.black54)),
//                            ),
                            Padding(
                              padding: EdgeInsets.only(top: 16),
                              child: Text(
                                  'transactionByteFee: ${store.settings.transactionByteFee} $baseTokenSymbol',
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

  bool balanceToLow(String v, BigInt available, int decimals) {
    if (_isEncointerCommunityCurrency) {
      return double.parse(v.trim()) >= available.toDouble() - 0.001;
    } else {
      return double.parse(v.trim()) >=
          available / BigInt.from(pow(10, decimals)) - 0.001;
    }
  }

  BigInt _getAvailableEncointerOrBaseToken(bool isBaseToken, String symbol) {
    if (_isEncointerCommunityCurrency) {
      return Fmt.tokenInt(
          store.encointer.balanceEntries[_tokenSymbol].principal.toString(),
          decimals: encointerTokenDecimals);
    } else {
      return isBaseToken
          ? store.assets.balances[symbol.toUpperCase()].transferable
          : Fmt.balanceInt(store.assets.tokenBalances[symbol.toUpperCase()]);
    }
  }
}
