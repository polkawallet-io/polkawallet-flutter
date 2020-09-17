import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:polka_wallet/common/components/TapTooltip.dart';
import 'package:polka_wallet/common/components/addressFormItem.dart';
import 'package:polka_wallet/common/components/passwordInputDialog.dart';
import 'package:polka_wallet/common/consts/settings.dart';
import 'package:polka_wallet/page/account/uos/qrSenderPage.dart';
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
  double _tip = 0;
  BigInt _tipValue = BigInt.zero;
  AccountData _proxyAccount;

  Future<String> _getTxFee({bool reload = false}) async {
    if (_fee['partialFee'] != null && !reload) {
      return _fee['partialFee'].toString();
    }
    if (store.account.currentAccount.observation ?? false) {
      webApi.account.queryRecoverable(store.account.currentAddress);
    }

    final Map args = ModalRoute.of(context).settings.arguments;
    Map txInfo = args['txInfo'];
    txInfo['pubKey'] = store.account.currentAccount.pubKey;
    txInfo['address'] = store.account.currentAddress;
    if (_proxyAccount != null) {
      txInfo['proxy'] = _proxyAccount.pubKey;
    }
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
    _getTxFee(reload: true);
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
    if (_proxyAccount != null && !(await _validateProxy())) {
      String address = Fmt.addressOfAccount(_proxyAccount, store);
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

  Future<void> _onSubmit(
    BuildContext context, {
    String password,
    bool viaQr = false,
  }) async {
    final Map<String, String> dic = I18n.of(context).home;
    final Map args = ModalRoute.of(context).settings.arguments;

    store.assets.setSubmitting(true);
    store.account.setTxStatus('queued');
    Scaffold.of(context).showSnackBar(SnackBar(
      backgroundColor: Theme.of(context).cardColor,
      content: ListTile(
        leading: CupertinoActivityIndicator(),
        title: Text(
          dic['tx.${store.account.txStatus}'] ?? dic['tx.wait'],
          style: TextStyle(color: Colors.black54),
        ),
      ),
      duration: Duration(minutes: 5),
    ));

    Map txInfo = args['txInfo'];
    txInfo['pubKey'] = store.account.currentAccount.pubKey;
    txInfo['address'] = store.account.currentAddress;
    txInfo['password'] = password;
    txInfo['tip'] = _tipValue.toString();
    if (_proxyAccount != null) {
      txInfo['proxy'] = _proxyAccount.pubKey;
      txInfo['ss58'] = store.settings.endpoint.ss58.toString();
    }
    print(txInfo);
    print(args['params']);

    final Map res = viaQr
        ? await _sendTxViaQr(context, args)
        : await _sendTx(context, args);
    if (res['hash'] == null) {
      _onTxError(context, res['error']);
    } else {
      _onTxFinish(context, res);
    }
  }

  Future<Map> _sendTx(BuildContext context, Map args) async {
    return await webApi.account.sendTx(
      args['txInfo'],
      args['params'],
      args['title'],
      I18n.of(context).home['notify.submitted'],
      rawParam: args['rawParam'],
    );
  }

  Future<Map> _sendTxViaQr(BuildContext context, Map args) async {
    final Map dic = I18n.of(context).account;
    print('show qr');
    final signed = await Navigator.of(context)
        .pushNamed(QrSenderPage.route, arguments: args);
    if (signed == null) {
      store.assets.setSubmitting(false);
      return {'error': dic['uos.canceled']};
    }
    return await webApi.account.addSignatureAndSend(
      signed.toString(),
      args['txInfo'],
      args['title'],
      I18n.of(context).home['notify.submitted'],
    );
  }

  void _onTipChanged(double tip) {
    final decimals = store.settings.networkState.tokenDecimals;

    /// tip division from 0 to 19:
    /// 0-10 for 0-0.1
    /// 10-19 for 0.1-1
    BigInt value = Fmt.tokenInt('0.01', decimals) * BigInt.from(tip.toInt());
    if (tip > 10) {
      value = Fmt.tokenInt('0.1', decimals) * BigInt.from((tip - 9).toInt());
    }
    setState(() {
      _tip = tip;
      _tipValue = value;
    });
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      webApi.gov.updateBestNumber();
    });
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
    final Map<String, String> dicAsset = I18n.of(context).assets;
    final String symbol = store.settings.networkState.tokenSymbol ?? '';
    final int decimals =
        store.settings.networkState.tokenDecimals ?? kusama_token_decimals;
    final String tokenView = Fmt.tokenView(symbol);

    final Map<String, dynamic> args = ModalRoute.of(context).settings.arguments;

    final bool isKusama =
        store.settings.endpoint.info == networkEndpointKusama.info;
    final bool isAcala =
        store.settings.endpoint.info == networkEndpointAcala.info;

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

          final bool isPolkadot =
              store.settings.endpoint.info == network_name_polkadot;
          bool isTxPaused = isPolkadot;
          if (isTxPaused &&
              store.gov.bestNumber > 0 &&
              (store.gov.bestNumber < dot_re_denominate_block - 1200 ||
                  store.gov.bestNumber > dot_re_denominate_block + 1200)) {
            isTxPaused = false;
          }
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
                              store.account.currentAccount,
                              label: dic["submit.from"],
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
                                _proxyAccount,
                                label:
                                    I18n.of(context).profile["recovery.proxy"],
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
                                        decimals,
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
                                              '$fee $tokenView',
                                            ),
                                            isAcala
                                                ? Text(
                                                    I18n.of(context)
                                                        .acala['tx.fee.or'],
                                                    style: TextStyle(
                                                      fontSize: 13,
                                                    ),
                                                  )
                                                : Container(),
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
                    Padding(
                      padding: EdgeInsets.fromLTRB(16, 8, 16, 0),
                      child: Row(
                        children: <Widget>[
                          Container(
                            width: 64,
                            child: Text(dicAsset['tip']),
                          ),
                          Text('${Fmt.token(_tipValue, decimals)} $tokenView'),
                          TapTooltip(
                            message: dicAsset['tip.tip'],
                            child: Icon(
                              Icons.info,
                              color: Theme.of(context).unselectedWidgetColor,
                              size: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(left: 16, right: 16),
                      child: Row(
                        children: <Widget>[
                          Text('0'),
                          Expanded(
                            child: Slider(
                              min: 0,
                              max: 19,
                              divisions: 19,
                              value: _tip,
                              onChanged: _onTipChanged,
                            ),
                          ),
                          Text('1')
                        ],
                      ),
                    )
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
                      color: store.assets.submitting || isTxPaused
                          ? Theme.of(context).disabledColor
                          : Theme.of(context).primaryColor,
                      child: FlatButton(
                        padding: EdgeInsets.all(16),
                        child: Text(
                          isUnsigned
                              ? dic['submit.no.sign']
                              : (isObservation && _proxyAccount == null) ||
                                      isProxyObservation
                                  ? dic['submit.qr']
                                  // dicAcc['observe.invalid']
                                  : dic['submit'],
                          style: TextStyle(color: Colors.white),
                        ),
                        onPressed: isTxPaused
                            ? null
                            : isUnsigned
                                ? () => _onSubmit(context)
                                : (isObservation && _proxyAccount == null) ||
                                        isProxyObservation
                                    ? () => _onSubmit(context, viaQr: true)
                                    : store.assets.submitting
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
