import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:polka_wallet/common/components/TapTooltip.dart';
import 'package:polka_wallet/common/components/addressFormItem.dart';
import 'package:polka_wallet/common/components/passwordInputDialog.dart';
import 'package:polka_wallet/common/consts/settings.dart';
import 'package:polka_wallet/page/profile/contacts/contactListPage.dart';
import 'package:polka_wallet/service/substrateApi/api.dart';
import 'package:polka_wallet/store/account/types/accountData.dart';
import 'package:polka_wallet/store/account/types/accountRecoveryInfo.dart';
import 'package:polka_wallet/store/app.dart';
import 'package:polka_wallet/utils/format.dart';
import 'package:polka_wallet/utils/i18n/index.dart';

// TODO: Add biometrics
class TxConfirmPage extends StatefulWidget {
  const TxConfirmPage(this.store);

  static final String route = '/tx/confirm';
  final AppStore store;

  @override
  _TxConfirmPageState createState() => _TxConfirmPageState(store);
}

class _TxConfirmPageState extends State<TxConfirmPage> {
  _TxConfirmPageState(this.store);

  final AppStore store;

  Map _fee = {};
  AccountData _proxyAccount;

  Future<String> _getTxFee() async {
    if (_fee['partialFee'] != null) {
      return _fee['partialFee'].toString();
    }
    if (store.account.currentAccount.observation ?? false) {
      webApi.account.queryRecoverable(store.account.currentAddress);
    }

    final Map args = ModalRoute.of(context).settings.arguments;
    Map txInfo = args['txInfo'];
    txInfo['address'] = store.account.currentAddress;
    Map fee = await webApi.account
        .estimateTxFees(txInfo, args['params'], rawParam: args['rawParam']);
    setState(() {
      _fee = fee;
    });
    return fee['partialFee'].toString();
  }

  Future<void> _onSwitch(bool value) async {
    if (value) {
      final acc = await Navigator.of(context).pushNamed(
        ContactListPage.route,
        arguments: store.account.accountListAll.toList(),
      );
      if (acc != null) {
        setState(() {
          _proxyAccount = acc;
        });
      }
    } else {
      setState(() {
        _proxyAccount = null;
      });
    }
  }

  Future<void> _showTxQrCode(BuildContext context) async {
    final Map args = ModalRoute.of(context).settings.arguments;

    Map txInfo = args['txInfo'];
    txInfo['pubKey'] = store.account.currentAccount.pubKey;
    print(txInfo);
    print(args['params']);
//    Navigator.of(context).pushNamed(routeName, arguments: );
  }

  void _onTxFinish(BuildContext context, Map res) {
    final Map args = ModalRoute.of(context).settings.arguments;
    print('callback triggered, blockHash: ${res['hash']}');
    store.assets.setSubmitting(false);
    if (mounted) {
      final ScaffoldState state = Scaffold.of(context);

      state.removeCurrentSnackBar();
      state.showSnackBar(SnackBar(
        backgroundColor: Colors.white,
        content: ListTile(
          leading: Container(
            width: 24,
            child: Image.asset('assets/images/assets/success.png'),
          ),
          title: Text(
            I18n.of(context).assets['success'],
            style: TextStyle(color: Colors.black54),
          ),
        ),
        duration: Duration(seconds: 2),
      ));

      Timer(Duration(seconds: 2), () {
        if (state.mounted) {
          (args['onFinish'] as Function(BuildContext, Map))(context, res);
        }
      });
    }
  }

  void _onTxError(BuildContext context, String errorMsg) {
    final Map<String, String> dic = I18n.of(context).home;
    store.assets.setSubmitting(false);
    if (mounted) {
      Scaffold.of(context).removeCurrentSnackBar();
    }
    showCupertinoDialog(
      context: context,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: Container(),
          content: Text(errorMsg),
          actions: <Widget>[
            CupertinoButton(
              child: Text(dic['cancel']),
              onPressed: () => Navigator.of(context).pop(),
            ),
            CupertinoButton(
              child: Text(dic['ok']),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
  }

  Future<bool> _validateProxy() async {
    List proxies =
        await webApi.account.queryRecoveryProxies([_proxyAccount.address]);
    print(proxies);
    return proxies[0] == store.account.currentAddress;
  }

  Future<void> _showPasswordDialog(BuildContext context) async {
    bool isProxyAvailable = await _validateProxy();
    if (!isProxyAvailable) {
      String address = store.account
          .pubKeyAddressMap[store.settings.endpoint.ss58][_proxyAccount.pubKey];
      showCupertinoDialog(
        context: context,
        builder: (BuildContext context) {
          return CupertinoAlertDialog(
            title: Text(Fmt.address(address)),
            content: Text(I18n.of(context).account['observe.proxy.invalid']),
            actions: <Widget>[
              CupertinoButton(
                child: Text(
                  I18n.of(context).home['cancel'],
                  style: TextStyle(
                    color: Theme.of(context).unselectedWidgetColor,
                  ),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
      return;
    }
    showCupertinoDialog(
      context: context,
      builder: (_) {
        return PasswordInputDialog(
          title: Text(I18n.of(context).home['unlock']),
          account: _proxyAccount ?? store.account.currentAccount,
          onOk: (password) => _onSubmit(context, password: password),
        );
      },
    );
  }

  Future<void> _onSubmit(BuildContext context, {String password}) async {
    final Map<String, String> dic = I18n.of(context).home;
    final Map args = ModalRoute.of(context).settings.arguments;

    store.assets.setSubmitting(true);
    store.account.setTxStatus('queued');
    Scaffold.of(context).showSnackBar(SnackBar(
      backgroundColor: Theme.of(context).cardColor,
      content: ListTile(
        leading: CupertinoActivityIndicator(),
        title: Text(
          dic['tx.${store.account.txStatus}'] ?? dic['tx.queued'],
          style: TextStyle(color: Colors.black54),
        ),
      ),
      duration: Duration(minutes: 5),
    ));

    Map txInfo = args['txInfo'];
    txInfo['pubKey'] = store.account.currentAccount.pubKey;
    txInfo['password'] = password;
    if (_proxyAccount != null) {
      txInfo['proxy'] = _proxyAccount.pubKey;
    }
    print(txInfo);
    print(args['params']);
    Map res = await webApi.account.sendTx(
        txInfo, args['params'], args['title'], dic['notify.submitted'],
        rawParam: args['rawParam']);
    if (res['hash'] == null) {
      _onTxError(context, res['error']);
    } else {
      _onTxFinish(context, res);
    }
  }

  @override
  void dispose() {
    store.assets.setSubmitting(false);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Map<String, String> dic = I18n.of(context).home;
    final Map<String, String> dicAcc = I18n.of(context).account;
    final String symbol = store.settings.networkState.tokenSymbol;
    final int decimals = store.settings.networkState.tokenDecimals;

    final Map<String, dynamic> args = ModalRoute.of(context).settings.arguments;

    final bool isKusama =
        store.settings.endpoint.info == networkEndpointKusama.info;

    bool isUnsigned = args['txInfo']['isUnsigned'] ?? false;
    return Scaffold(
      appBar: AppBar(
        title: Text(args['title']),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Observer(builder: (BuildContext context) {
          final bool isObservation =
              store.account.currentAccount.observation ?? false;
          final bool isProxyObservation = _proxyAccount != null
              ? _proxyAccount.observation ?? false
              : false;
          final AccountRecoveryInfo recoverable = store.account.recoveryInfo;

          return Column(
            children: <Widget>[
              Expanded(
                child: ListView(
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.all(16),
                      child: Text(
                        dic['submit.tx'],
                        style: Theme.of(context).textTheme.headline4,
                      ),
                    ),
                    isUnsigned
                        ? Container()
                        : Padding(
                            padding: EdgeInsets.only(left: 16, right: 16),
                            child: AddressFormItem(
                              dic["submit.from"],
                              store.account.currentAccount,
                            ),
                          ),
                    isKusama && isObservation && recoverable.address != null
                        ? Padding(
                            padding: EdgeInsets.only(left: 16, right: 16),
                            child: Row(
                              children: [
                                TapTooltip(
                                  message: dicAcc['observe.proxy.brief'],
                                  child: Icon(Icons.info_outline, size: 16),
                                ),
                                Expanded(
                                  child: Padding(
                                    padding: EdgeInsets.only(left: 4),
                                    child: Text(dicAcc['observe.proxy']),
                                  ),
                                ),
                                CupertinoSwitch(
                                  value: _proxyAccount != null,
                                  onChanged: (res) => _onSwitch(res),
                                )
                              ],
                            ),
                          )
                        : Container(),
                    _proxyAccount != null
                        ? GestureDetector(
                            child: Padding(
                              padding: EdgeInsets.only(left: 16, right: 16),
                              child: AddressFormItem(
                                I18n.of(context).profile["recovery.proxy"],
                                _proxyAccount,
                              ),
                            ),
                            onTap: () => _onSwitch(true),
                          )
                        : Container(),
                    Padding(
                      padding: EdgeInsets.all(16),
                      child: Row(
                        children: <Widget>[
                          Container(
                            width: 64,
                            child: Text(
                              dic["submit.call"],
                            ),
                          ),
                          Text(
                            '${args['txInfo']['module']}.${args['txInfo']['call']}',
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(left: 16, right: 16),
                      child: Row(
                        children: <Widget>[
                          Container(
                            width: 64,
                            child: Text(
                              dic["detail"],
                            ),
                          ),
                          Container(
                            width:
                                MediaQuery.of(context).copyWith().size.width -
                                    120,
                            child: Text(
                              args['detail'],
                            ),
                          ),
                        ],
                      ),
                    ),
                    isUnsigned
                        ? Container()
                        : Padding(
                            padding: EdgeInsets.only(left: 16, right: 16),
                            child: Row(
                              children: <Widget>[
                                Container(
                                  margin: EdgeInsets.only(top: 8),
                                  width: 64,
                                  child: Text(
                                    dic["submit.fees"],
                                  ),
                                ),
                                FutureBuilder<String>(
                                  future: _getTxFee(),
                                  builder: (BuildContext context,
                                      AsyncSnapshot<String> snapshot) {
                                    if (snapshot.hasData) {
                                      String fee = Fmt.balance(
                                        _fee['partialFee'].toString(),
                                        decimals: decimals,
                                        length: 6,
                                      );
                                      return Container(
                                        margin: EdgeInsets.only(top: 8),
                                        width: MediaQuery.of(context)
                                                .copyWith()
                                                .size
                                                .width -
                                            120,
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: <Widget>[
                                            Text(
                                              '$fee $symbol',
                                            ),
                                            Text(
                                              '${_fee['weight']} Weight',
                                              style: TextStyle(
                                                fontSize: 13,
                                                color: Theme.of(context)
                                                    .unselectedWidgetColor,
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    } else {
                                      return CupertinoActivityIndicator();
                                    }
                                  },
                                ),
                              ],
                            ),
                          ),
                  ],
                ),
              ),
              Row(
                children: <Widget>[
                  Expanded(
                    child: Container(
                      color: store.assets.submitting
                          ? Colors.black12
                          : Colors.orange,
                      child: FlatButton(
                        padding: EdgeInsets.all(16),
                        child: Text(dic['cancel'],
                            style: TextStyle(color: Colors.white)),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      color: store.assets.submitting
                          ? Colors.black12
                          : Theme.of(context).primaryColor,
                      child: FlatButton(
                        padding: EdgeInsets.all(16),
                        child: Text(
                          isUnsigned
                              ? dic['submit.no.sign']
                              : (isObservation && _proxyAccount == null) ||
                                      isProxyObservation
                                  ? dic['submit.qr']
                                  : dic['submit'],
                          style: TextStyle(color: Colors.white),
                        ),
                        onPressed: isUnsigned
                            ? () => _onSubmit(context)
                            : (isObservation && _proxyAccount == null) ||
                                    isProxyObservation
                                ? () => _showTxQrCode(context)
                                : _fee['partialFee'] == null ||
                                        store.assets.submitting
                                    ? null
                                    : () => _showPasswordDialog(context),
                      ),
                    ),
                  ),
                ],
              )
            ],
          );
        }),
      ),
    );
  }
}
