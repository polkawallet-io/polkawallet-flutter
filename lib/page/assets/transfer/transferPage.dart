import 'dart:convert';
import 'dart:math';

import 'package:encointer_wallet/common/components/AddressInputField.dart';
import 'package:encointer_wallet/common/components/encointerTextFormField.dart';
import 'package:encointer_wallet/common/components/gradientElements.dart';
import 'package:encointer_wallet/common/theme.dart';
import 'package:encointer_wallet/config/consts.dart';
import 'package:encointer_wallet/page-encointer/common/communityChooserPanel.dart';
import 'package:encointer_wallet/page/account/txConfirmPage.dart';
import 'package:encointer_wallet/service/qrScanService.dart';
import 'package:encointer_wallet/service/substrateApi/api.dart';
import 'package:encointer_wallet/store/account/types/accountData.dart';
import 'package:encointer_wallet/store/app.dart';
import 'package:encointer_wallet/utils/UI.dart';
import 'package:encointer_wallet/utils/format.dart';
import 'package:encointer_wallet/utils/translations/index.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:iconsax/iconsax.dart';
import 'package:encointer_wallet/utils/translations/translations.dart';

class TransferPageParams {
  TransferPageParams(
      {this.symbol, this.qrScanData, this.redirect, this.isEncointerCommunityCurrency = false, this.communitySymbol});

  final QrScanData qrScanData;
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

  @override
  Widget build(BuildContext context) {
    return Observer(
      builder: (_) {
        final Translations dic = I18n.of(context).translationsForLocale();
        final String baseTokenSymbol = store.settings.networkState.tokenSymbol;
        String symbol = _tokenSymbol ?? baseTokenSymbol;
        final bool isBaseToken = _tokenSymbol == baseTokenSymbol;

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

        return Form(
          key: _formKey,
          child: Scaffold(
            appBar: AppBar(
              title: Text(dic.assets.transfer),
              leading: Container(),
              actions: [
                IconButton(
                  key: Key('close-transfer-page'),
                  icon: Icon(Icons.close),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                )
              ],
            ),
            body: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Column(
                children: [
                  Expanded(
                    child: ListView(
                      children: [
                        CommunityWithCommunityChooser(store),
                        store.encointer.communityBalance != null
                            ? AccountBalanceWithMoreDigits(store: store, available: available, decimals: decimals)
                            : CupertinoActivityIndicator(),
                        Text(
                          "${I18n.of(context).translationsForLocale().assets.yourBalanceFor} ${Fmt.accountName(context, store.account.currentAccount)}",
                          style: Theme.of(context).textTheme.headline4.copyWith(color: encointerGrey),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 48),
                        EncointerTextFormField(
                          labelText: dic.assets.amountToBeTransferred,
                          textStyle: Theme.of(context).textTheme.headline1.copyWith(color: encointerBlack),
                          inputFormatters: [UI.decimalInputFormatter(decimals: decimals)],
                          controller: _amountCtrl,
                          textFormFieldKey: Key('transfer-amount-input'),
                          validator: (String value) {
                            if (value.isEmpty) {
                              return dic.assets.amountError;
                            }
                            if (balanceTooLow(value, available, decimals)) {
                              return dic.assets.amountLow;
                            }
                            return null;
                          },
                          suffixIcon: Text(
                            "ⵐ",
                            style: TextStyle(
                              color: encointerGrey,
                              fontSize: 44,
                            ),
                          ),
                        ),
                        SizedBox(height: 24),
                        Row(
                          children: [
                            Expanded(
                              child: AddressInputField(
                                widget.store,
                                label: dic.assets.address,
                                initialValue: _accountTo,
                                onChanged: (AccountData acc) {
                                  setState(() {
                                    _accountTo = acc;
                                  });
                                },
                                hideIdenticon: true,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 48),
                  Center(
                    child: Text(
                      "Fee: TODO compute Fee",
                      style: Theme.of(context).textTheme.headline4.copyWith(color: encointerGrey),
                    ),
                  ),
                  SizedBox(height: 8),
                  Container(
                    key: Key('make-transfer'),
                    child: PrimaryButton(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Iconsax.send_sqaure_2),
                          SizedBox(width: 12),
                          Text(dic.assets.amountToBeTransferred),
                        ],
                      ),
                      onPressed: _handleSubmit,
                    ),
                  ),
                  SizedBox(height: 8),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _handleSubmit() {
    if (_formKey.currentState.validate()) {
      String symbol = _tokenSymbol ?? store.settings.networkState.tokenSymbol;
      int decimals = store.settings.networkState.tokenDecimals;
      final String tokenView = Fmt.tokenView(symbol);
      final address = Fmt.addressOfAccount(_accountTo, store);
      var args = {
        "title": I18n.of(context).translationsForLocale().assets.transfer + ' $tokenView',
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
      if (args.qrScanData != null) {
        _amountCtrl.text = '${args.qrScanData.amount}';

        final AccountData acc = AccountData();
        acc.address = args.qrScanData.account;
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

  bool balanceTooLow(String v, BigInt available, int decimals) {
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

class AccountBalanceWithMoreDigits extends StatelessWidget {
  const AccountBalanceWithMoreDigits({
    Key key,
    @required this.store,
    @required this.available,
    @required this.decimals,
  }) : super(key: key);

  final AppStore store;
  final BigInt available;
  final int decimals;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: RichText(
        // need text base line aligment
        text: TextSpan(
          text: '${Fmt.priceFloorBigInt(
            available,
            decimals,
            lengthMax: 6,
          )} ',
          style: Theme.of(context).textTheme.headline2.copyWith(color: encointerBlack),
          children: const <TextSpan>[
            TextSpan(
              text: 'ⵐ',
              style: TextStyle(color: encointerGrey),
            ),
          ],
        ),
      ),
    );
  }
}
