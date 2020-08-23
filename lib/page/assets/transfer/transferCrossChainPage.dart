import 'dart:convert';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:polka_wallet/common/components/addressFormItem.dart';
import 'package:polka_wallet/common/components/currencyWithIcon.dart';
import 'package:polka_wallet/common/components/roundedButton.dart';
import 'package:polka_wallet/common/consts/settings.dart';
import 'package:polka_wallet/page/account/txConfirmPage.dart';
import 'package:polka_wallet/page/assets/asset/assetPage.dart';
import 'package:polka_wallet/page/assets/transfer/transferPage.dart';
import 'package:polka_wallet/service/substrateApi/api.dart';
import 'package:polka_wallet/store/app.dart';
import 'package:polka_wallet/utils/UI.dart';
import 'package:polka_wallet/utils/format.dart';
import 'package:polka_wallet/utils/i18n/index.dart';

class TransferCrossChainPage extends StatefulWidget {
  const TransferCrossChainPage(this.store);

  static final String route = '/assets/transfer/cross';
  final AppStore store;

  @override
  _TransferCrossChainPageState createState() => _TransferCrossChainPageState();
}

class _TransferCrossChainPageState extends State<TransferCrossChainPage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _amountCtrl = new TextEditingController();

  String _tokenSymbol;

  void _handleSubmit() {
    if (_formKey.currentState.validate()) {
      String symbol =
          _tokenSymbol ?? widget.store.settings.networkState.tokenSymbol;
      int decimals = widget.store.settings.networkState.tokenDecimals;

      final bool isAcala =
          widget.store.settings.endpoint.info == networkEndpointAcala.info;
      bool isLaminar =
          widget.store.settings.endpoint.info == networkEndpointLaminar.info;
      var args = {
        "title": I18n.of(context).assets['transfer'] + ' $symbol',
        "txInfo": {
          "module": 'currencies',
          "call": 'transfer',
        },
        "detail": jsonEncode({
          "destination": widget.store.account.currentAddress,
          "currency": symbol,
          "amount": _amountCtrl.text.trim(),
        }),
        "params": [
          // params.to
          isAcala
              ? cross_chain_transfer_address_laminar
              : cross_chain_transfer_address_acala,
          // params.currencyId
          symbol.toUpperCase(),
          // params.amount
          Fmt.tokenInt(_amountCtrl.text.trim(), decimals).toString(),
        ],
      };

      args['onFinish'] = (BuildContext txPageContext, Map res) {
        final TransferPageParams routeArgs =
            ModalRoute.of(context).settings.arguments;
        if (isAcala) {
          widget.store.acala.setTransferTxs([res]);
        }
        if (isLaminar) {
          widget.store.laminar.setTransferTxs([res]);
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
      setState(() {
        _tokenSymbol =
            args.symbol ?? widget.store.settings.networkState.tokenSymbol;
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
        String baseTokenSymbol = widget.store.settings.networkState.tokenSymbol;
        String symbol = _tokenSymbol ?? baseTokenSymbol;
        final bool isBaseToken = _tokenSymbol == baseTokenSymbol;

        int decimals = widget.store.settings.networkState.tokenDecimals;

        BigInt available = isBaseToken
            ? widget.store.assets.balances[symbol.toUpperCase()].transferable
            : Fmt.balanceInt(
                widget.store.assets.tokenBalances[symbol.toUpperCase()]);

        final bool isAcala =
            widget.store.settings.endpoint.info == networkEndpointAcala.info;

        return Scaffold(
          appBar: AppBar(title: Text(dic['transfer']), centerTitle: true),
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
                            Padding(
                              padding: EdgeInsets.only(top: 16),
                              child: Text(
                                dic['cross.chain'],
                                style: TextStyle(
                                  fontSize: 14,
                                  color:
                                      Theme.of(context).unselectedWidgetColor,
                                ),
                              ),
                            ),
                            Row(
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
                                      ? network_name_laminar_turbulence
                                          .toUpperCase()
                                      : network_name_acala_mandala
                                          .toUpperCase(),
                                )
                              ],
                            ),
                            Padding(
                              padding: EdgeInsets.only(top: 8),
                              child: AddressFormItem(
                                widget.store.account.currentAccount,
                                label: dic['address'],
                              ),
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
                            ),
                            Divider(),
                            Padding(
                              padding: EdgeInsets.only(top: 16),
                              child: Text(
                                  'existentialDeposit: ${widget.store.settings.existentialDeposit} $baseTokenSymbol',
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
                                  'transactionByteFee: ${widget.store.settings.transactionByteFee} $baseTokenSymbol',
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
