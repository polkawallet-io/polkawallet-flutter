import 'dart:convert';
import 'dart:math';

import 'package:encointer_wallet/common/components/AddressInputField.dart';
import 'package:encointer_wallet/common/components/currencyWithIcon.dart';
import 'package:encointer_wallet/common/components/roundedButton.dart';
import 'package:encointer_wallet/config/consts.dart';
import 'package:encointer_wallet/page/account/scanPage.dart';
import 'package:encointer_wallet/page/account/txConfirmPage.dart';
import 'package:encointer_wallet/page/assets/asset/assetPage.dart';
import 'package:encointer_wallet/page/assets/transfer/currencySelectPage.dart';
import 'package:encointer_wallet/service/substrateApi/api.dart';
import 'package:encointer_wallet/store/account/types/accountData.dart';
import 'package:encointer_wallet/store/app.dart';
import 'package:encointer_wallet/utils/UI.dart';
import 'package:encointer_wallet/utils/format.dart';
import 'package:encointer_wallet/utils/i18n/index.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mobx/flutter_mobx.dart';

class TransferPageParams {
  TransferPageParams(
      {this.symbol, this.address, this.redirect, this.isEncointerCommunityCurrency = false, this.communitySymbol});
  final String address;
  final String redirect;
  final String symbol;
  final bool isEncointerCommunityCurrency;
  final String communitySymbol;
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

  final TextEditingController _amountCtrl = new TextEditingController();

  AccountData _accountTo;
  String _tokenSymbol;
  bool _isEncointerCommunityCurrency;
  String _communitySymbol;

  Future<void> _onScan() async {
    final to = await Navigator.of(context).pushNamed(ScanPage.route);
    if (to == null) return;
    AccountData acc = AccountData();
    acc.address = (to as QRCodeAddressResult).address;
    acc.name = (to as QRCodeAddressResult).name;
    setState(() {
      _accountTo = acc;
    });
  }

  Future<void> _selectCommunity() async {
    List<String> symbolOptions = List<String>.from(store.settings.networkConst['currencyIds']);

    var currency = await Navigator.of(context).pushNamed(CommunitySelectPage.route, arguments: symbolOptions);

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
      final String tokenView = Fmt.tokenView(symbol);
      final address = Fmt.addressOfAccount(_accountTo, store);
      var args = {
        "title": I18n.of(context).assets['transfer'] + ' $tokenView',
        "txInfo": {
          "module": 'balances',
          "call": 'transfer',
        },
        "detail": jsonEncode({
          "destination": address,
          "currency": tokenView,
          "amount": _amountCtrl.text.trim(),
        }),
        "params": [
          // params.to
          address,
          // params.amount
          Fmt.tokenInt(_amountCtrl.text.trim(), decimals).toString(),
        ],
      };
      // Todo: why was it here depending on the endpoint? Do we not want to facilitate ERT transfers?
      if (_isEncointerCommunityCurrency) {
        args['txInfo'] = {
          "module": 'encointerBalances',
          "call": 'transfer',
          "cid": symbol,
        };
        args["detail"] = jsonEncode({
          "destination": address,
          "currency": _communitySymbol,
          "amount": _amountCtrl.text.trim(),
        });
        args['params'] = [
          // params.to
          address,
          // params.currencyId
          symbol,
          // params.amount
          _amountCtrl.text.trim(),
        ];
      }
      args['onFinish'] = (BuildContext txPageContext, Map res) {
        final TransferPageParams routeArgs = ModalRoute.of(context).settings.arguments;
        if (store.settings.endpointIsEncointer) {
          store.encointer.setTransferTxs([res]);
        }
        Navigator.popUntil(txPageContext, ModalRoute.withName(routeArgs.redirect));
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
        final AccountData acc = AccountData();
        acc.address = args.address;
        setState(() {
          _accountTo = acc;
        });
      } else {
        if (widget.store.account.optionalAccounts.length > 0) {
          setState(() {
            _accountTo = widget.store.account.optionalAccounts[0];
          });
        } else if (widget.store.settings.contactList.length > 0) {
          setState(() {
            _accountTo = widget.store.settings.contactList[0];
          });
        }
      }
      setState(() {
        _tokenSymbol = args.symbol ?? store.settings.networkState.tokenSymbol;
      });

      webApi.assets.fetchBalance();
      webApi.encointer.getEncointerBalance();
    });
  }

  @override
  void dispose() {
    _amountCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Observer(
      builder: (_) {
        final Map<String, String> dic = I18n.of(context).assets;
        final String baseTokenSymbol = store.settings.networkState.tokenSymbol;
        final String baseTokenSymbolView = Fmt.tokenView(baseTokenSymbol);
        String symbol = _tokenSymbol ?? baseTokenSymbol;
        final bool isBaseToken = _tokenSymbol == baseTokenSymbol;
        List symbolOptions = store.settings.networkConst['currencyIds'];

        TransferPageParams params = ModalRoute.of(context).settings.arguments;
        _isEncointerCommunityCurrency = params.isEncointerCommunityCurrency;
        if (_isEncointerCommunityCurrency) {
          _communitySymbol = params.communitySymbol;
        }
        _tokenSymbol = params.symbol;

        int decimals = _isEncointerCommunityCurrency
            ? encointer_currencies_decimals
            : store.settings.networkState.tokenDecimals ?? ert_decimals;

        BigInt available; // BigInt
        available = _getAvailableEncointerOrBaseToken(isBaseToken, symbol);
        print('Available: $available');

        return Scaffold(
          appBar: AppBar(
            title: Text(dic['transfer']),
            centerTitle: true,
            actions: <Widget>[
              IconButton(
                icon: Image.asset('assets/images/assets/Menu_scan.png'),
                onPressed: _onScan,
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
                          padding: EdgeInsets.all(16),
                          children: <Widget>[
                            AddressInputField(
                              widget.store,
                              label: dic['address'],
                              initialValue: _accountTo,
                              onChanged: (AccountData acc) {
                                setState(() {
                                  _accountTo = acc;
                                });
                              },
                            ),
                            TextFormField(
                              key: Key('transfer-amount-input'),
                              decoration: InputDecoration(
                                hintText: dic['amount'],
                                labelText: '${dic['amount']} (${dic['balance']}: ${Fmt.priceFloorBigInt(
                                  available,
                                  decimals,
                                  lengthMax: 6,
                                )})',
                              ),
                              inputFormatters: [UI.decimalInputFormatter(decimals)],
                              controller: _amountCtrl,
                              keyboardType: TextInputType.numberWithOptions(decimal: true),
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
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Text(
                                          dic['currency'],
                                          style: TextStyle(color: Theme.of(context).unselectedWidgetColor),
                                        ),
                                        !_isEncointerCommunityCurrency
                                            ? CurrencyWithIcon(_tokenSymbol ?? baseTokenSymbol)
                                            : Text(_communitySymbol),
                                      ],
                                    ),
                                    // Icon(
                                    //   Icons.arrow_forward_ios,
                                    //   size: 18,
                                    // )
                                  ],
                                ),
                              ),
                              onTap: symbolOptions != null ? () => _selectCommunity() : null,
                            ),
                            Divider(),
                            Padding(
                              padding: EdgeInsets.only(top: 16),
                              child: Text(
                                  'existentialDeposit: ${store.settings.existentialDeposit} $baseTokenSymbolView',
                                  style: TextStyle(fontSize: 16, color: Colors.black54)),
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
                                  'transactionByteFee: ${store.settings.transactionByteFee} $baseTokenSymbolView',
                                  style: TextStyle(fontSize: 16, color: Colors.black54)),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Container(
                      key: Key('make-transfer'),
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
      return double.parse(v.trim()) >= available.toDouble() - 0.0001;
    } else {
      return double.parse(v.trim()) >= available / BigInt.from(pow(10, decimals)) - 0.0001;
    }
  }

  BigInt _getAvailableEncointerOrBaseToken(bool isBaseToken, String symbol) {
    if (_isEncointerCommunityCurrency) {
      return Fmt.tokenInt(store.encointer.communityBalance.toString(), encointer_currencies_decimals);
    } else {
      return isBaseToken
          ? store.assets.balances[symbol.toUpperCase()].transferable
          : Fmt.balanceInt(store.assets.tokenBalances[symbol.toUpperCase()]);
    }
  }
}
