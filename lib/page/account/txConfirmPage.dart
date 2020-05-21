import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:polka_wallet/common/components/addressFormItem.dart';
import 'package:polka_wallet/common/components/passwordInputDialog.dart';
import 'package:polka_wallet/service/substrateApi/api.dart';
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

  Future<String> _getTxFee() async {
    if (_fee['partialFee'] != null) {
      return _fee['partialFee'].toString();
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

  Future<void> _showPasswordDialog(BuildContext context) async {
    showCupertinoDialog(
      context: context,
      builder: (_) {
        return PasswordInputDialog(
          title: Text(I18n.of(context).home['unlock']),
          onOk: (password) => _onSubmit(context, password),
        );
      },
    );
  }

  Future<void> _onSubmit(BuildContext context, String password) async {
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
    final String symbol = store.settings.networkState.tokenSymbol;
    final int decimals = store.settings.networkState.tokenDecimals;

    final Map<String, dynamic> args = ModalRoute.of(context).settings.arguments;

    return Scaffold(
      appBar: AppBar(
        title: Text(args['title']),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Builder(builder: (BuildContext context) {
          return Observer(
            builder: (_) => Column(
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
                      Padding(
                        padding: EdgeInsets.only(left: 16, right: 16),
                        child: AddressFormItem(
                          dic["submit.from"],
                          store.account.currentAccount,
                        ),
                      ),
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
                      Padding(
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
//                      Padding(
//                        padding: EdgeInsets.fromLTRB(16, 0, 16, 16),
//                        child: TextFormField(
//                          decoration: InputDecoration(
//                            icon: Icon(Icons.lock),
//                            hintText: dic['unlock'],
//                            labelText: dic['unlock'],
//                            suffixIcon: IconButton(
//                              iconSize: 18,
//                              icon: Icon(
//                                CupertinoIcons.clear_thick_circled,
//                                color: Theme.of(context).unselectedWidgetColor,
//                              ),
//                              onPressed: () {
//                                WidgetsBinding.instance.addPostFrameCallback(
//                                    (_) => _passCtrl.clear());
//                              },
//                            ),
//                          ),
//                          obscureText: true,
//                          controller: _passCtrl,
//                        ),
//                      ),
                    ],
                  ),
                ),
                store.account.currentAccount.observation ?? false
                    ? Row(
                        children: <Widget>[
                          Expanded(
                            child: Container(
                              color: Colors.orange,
                              child: FlatButton(
                                padding: EdgeInsets.all(16),
                                child: Text(
                                    I18n.of(context).account['observe.tx'],
                                    style: TextStyle(color: Colors.white)),
                              ),
                            ),
                          ),
                        ],
                      )
                    : Row(
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
                                  dic['submit'],
                                  style: TextStyle(color: Colors.white),
                                ),
                                onPressed: _fee['partialFee'] == null ||
                                        store.assets.submitting
                                    ? null
                                    : () => _showPasswordDialog(context),
                              ),
                            ),
                          ),
                        ],
                      )
              ],
            ),
          );
        }),
      ),
    );
  }
}
