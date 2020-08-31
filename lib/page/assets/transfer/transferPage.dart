import 'dart:convert';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:polka_wallet/common/components/AddressInputField.dart';
import 'package:polka_wallet/common/components/currencyWithIcon.dart';
import 'package:polka_wallet/common/components/outlinedButtonSmall.dart';
import 'package:polka_wallet/common/components/roundedButton.dart';
import 'package:polka_wallet/common/consts/settings.dart';
import 'package:polka_wallet/page/account/scanPage.dart';
import 'package:polka_wallet/page/account/txConfirmPage.dart';
import 'package:polka_wallet/page/assets/asset/assetPage.dart';
import 'package:polka_wallet/page/assets/transfer/currencySelectPage.dart';
import 'package:polka_wallet/page/assets/transfer/transferCrossChainPage.dart';
import 'package:polka_wallet/page/profile/contacts/contactListPage.dart';
import 'package:polka_wallet/service/substrateApi/api.dart';
import 'package:polka_wallet/store/account/types/accountData.dart';
import 'package:polka_wallet/store/app.dart';
import 'package:polka_wallet/utils/UI.dart';
import 'package:polka_wallet/utils/format.dart';
import 'package:polka_wallet/utils/i18n/index.dart';

class TransferPageParams {
  TransferPageParams({
    this.symbol,
    this.address,
    this.redirect,
  });
  final String address;
  final String redirect;
  final String symbol;
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

  bool _crossChain = false;

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

  Future<void> _selectCurrency() async {
    List<String> symbolOptions =
        List<String>.from(store.settings.networkConst['currencyIds']);

    var currency = await Navigator.of(context)
        .pushNamed(CurrencySelectPage.route, arguments: symbolOptions);

    if (currency != null) {
      if (_crossChain &&
          (_tokenSymbol == acala_stable_coin_view ||
              _tokenSymbol == acala_stable_coin) &&
          _tokenSymbol != currency) {
        setState(() {
          _accountTo = null;
        });
      }
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
      bool isAcala = store.settings.endpoint.info == networkEndpointAcala.info;
      bool isLaminar =
          store.settings.endpoint.info == networkEndpointLaminar.info;
      if (isAcala || isLaminar) {
        args['txInfo'] = {
          "module": 'currencies',
          "call": 'transfer',
        };
        args['params'] = [
          // params.to
          address,
          // params.currencyId
          symbol.toUpperCase(),
          // params.amount
          Fmt.tokenInt(_amountCtrl.text.trim(), decimals).toString(),
        ];
      }
      args['onFinish'] = (BuildContext txPageContext, Map res) {
        final TransferPageParams routeArgs =
            ModalRoute.of(context).settings.arguments;
        if (isAcala) {
          store.acala.setTransferTxs([res]);
        }
        if (isLaminar) {
          store.laminar.setTransferTxs([res]);
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

  void _onCrossChain() {
    final bool isAcala =
        store.settings.endpoint.info == network_name_acala_mandala;
    showCupertinoModalPopup(
      context: context,
      builder: (_) => CupertinoActionSheet(
        actions: [
          CupertinoActionSheetAction(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(right: 8),
                  child: CircleAvatar(
                    child: Image.asset(
                      isAcala
                          ? 'assets/images/public/laminar-turbulence.png'
                          : 'assets/images/public/acala-mandala.png',
                    ),
                    radius: 16,
                  ),
                ),
                Text(
                  isAcala
                      ? network_name_laminar_turbulence.toUpperCase()
                      : network_name_acala_mandala.toUpperCase(),
                )
              ],
            ),
            onPressed: () {
              final TransferPageParams args =
                  ModalRoute.of(context).settings.arguments;
              Navigator.of(context)
                  .popAndPushNamed(TransferCrossChainPage.route,
                      arguments: TransferPageParams(
                        symbol: _tokenSymbol,
                        redirect: args?.redirect,
                      ));
            },
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          child: Text(I18n.of(context).home['cancel']),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
    );
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
        final int decimals = store.settings.networkState.tokenDecimals;
        final String baseTokenSymbol = store.settings.networkState.tokenSymbol;
        final String baseTokenSymbolView = Fmt.tokenView(baseTokenSymbol);
        String symbol = _tokenSymbol ?? baseTokenSymbol;
        final bool isBaseToken = _tokenSymbol == baseTokenSymbol;
        List symbolOptions = store.settings.networkConst['currencyIds'];

        BigInt available = isBaseToken
            ? store.assets.balances[symbol.toUpperCase()].transferable
            : Fmt.balanceInt(store.assets.tokenBalances[symbol.toUpperCase()]);

        final Map pubKeyAddressMap =
            store.account.pubKeyAddressMap[store.settings.endpoint.ss58];

        final bool isAcala =
            store.settings.endpoint.info == networkEndpointAcala.info;
        final bool isLaminar =
            store.settings.endpoint.info == networkEndpointLaminar.info;
        final bool canCrossChain = (_tokenSymbol == acala_stable_coin ||
                _tokenSymbol == acala_stable_coin_view) &&
            (isAcala || isLaminar);
        final bool isCrossChain = (_tokenSymbol == acala_stable_coin ||
                _tokenSymbol == acala_stable_coin_view) &&
            _crossChain;

        return Scaffold(
          appBar: AppBar(
            title: Text(dic['transfer']),
            centerTitle: true,
            actions: <Widget>[
              IconButton(
                icon: Image.asset('assets/images/assets/Menu_scan.png'),
                onPressed: isCrossChain ? null : _onScan,
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
                            canCrossChain
                                ? Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: <Widget>[
                                      Container(
                                        margin: EdgeInsets.only(bottom: 16),
                                        child: OutlinedButtonSmall(
                                          content: dic['cross.chain'],
                                          active: true,
                                          onPressed: _onCrossChain,
                                        ),
                                      )
                                    ],
                                  )
                                : Container(),
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
                              decoration: InputDecoration(
                                hintText: dic['amount'],
                                labelText:
                                    '${dic['amount']} (${dic['balance']}: ${Fmt.priceFloorBigInt(
                                  available,
                                  decimals,
                                  lengthMax: 6,
                                )})',
                              ),
                              inputFormatters: [
                                UI.decimalInputFormatter(decimals)
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
                                        0.001) {
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
                                        CurrencyWithIcon(
                                            _tokenSymbol ?? baseTokenSymbol),
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
                            Divider(),
                            Padding(
                              padding: EdgeInsets.only(top: 16),
                              child: Text(
                                  'existentialDeposit: ${store.settings.existentialDeposit} $baseTokenSymbolView',
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
                                  'transactionByteFee: ${store.settings.transactionByteFee} $baseTokenSymbolView',
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
