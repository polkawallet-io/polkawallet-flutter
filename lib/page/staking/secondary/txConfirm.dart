import 'dart:async';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:polka_wallet/store/app.dart';
import 'package:polka_wallet/utils/i18n/index.dart';

class TxConfirm extends StatefulWidget {
  const TxConfirm(this.store);

  final AppStore store;

  @override
  _TxConfirmState createState() => _TxConfirmState(store);
}

class _TxConfirmState extends State<TxConfirm> {
  _TxConfirmState(this.store);

  final AppStore store;

  final TextEditingController _passCtrl = new TextEditingController();

  Future<void> _onSubmit(BuildContext context) async {
    final ScaffoldState state = Scaffold.of(context);
    final Map<String, String> dic = I18n.of(context).home;

    final Map args = ModalRoute.of(context).settings.arguments;

    void onTxFinish(String blockHash) {
      print('callback triggered, blockHash: $blockHash');
      store.assets.setSubmitting(false);
      if (state.mounted) {
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
          Navigator.popUntil(context, ModalRoute.withName(args['redirect']));
        });
      }
    }

    void onTxError() {
      store.assets.setSubmitting(false);
      if (state.mounted) {
        state.removeCurrentSnackBar();
      }
      showCupertinoDialog(
        context: context,
        builder: (BuildContext context) {
          final Map<String, String> accDic = I18n.of(context).account;
          return CupertinoAlertDialog(
            title: Container(),
            content: Text(
                '${accDic['import.invalid']} ${accDic['create.password']}'),
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

    store.assets.setSubmitting(true);
    state.showSnackBar(SnackBar(
      backgroundColor: Colors.white,
      content: ListTile(
        leading: CupertinoActivityIndicator(),
        title: Text(
          dic['submit.tx'],
          style: TextStyle(color: Colors.black54),
        ),
      ),
      duration: Duration(minutes: 1),
    ));

    Map params = args['params'];
    params['from'] = store.account.currentAccount.address;
    params['password'] = _passCtrl.text;
    print(params);
    var res =
        await store.api.evalJavascript('account.sendTx(${jsonEncode(params)})');

    if (res == null) {
      onTxError();
    } else {
      // TODO: add system notification here
      onTxFinish(res['hash']);
    }
  }

  @override
  void initState() {
    // setSubmitting false for testing
//    store.assets.setSubmitting(false);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final Map<String, String> dic = I18n.of(context).home;

    final Map<String, dynamic> args = ModalRoute.of(context).settings.arguments;

    return Scaffold(
      appBar: AppBar(
        title: Text(args['title']),
        centerTitle: true,
      ),
      body: Builder(builder: (BuildContext context) {
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
                        style: Theme.of(context).textTheme.display4,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(16),
                      child: Text(
                        '${dic["submit.from"]}${store.account.currentAccount.address}',
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
                            '${args['params']['module']}.${args['params']['call']}',
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(16),
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
                      padding: EdgeInsets.fromLTRB(16, 0, 16, 16),
                      child: TextFormField(
                        decoration: InputDecoration(
                          icon: Icon(Icons.lock),
                          hintText: dic['unlock'],
                          labelText: dic['unlock'],
                        ),
                        obscureText: true,
                        controller: _passCtrl,
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
                          _passCtrl.value = TextEditingValue(text: '');
                          Navigator.of(context).pop();
                        },
                      ),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      color: store.assets.submitting
                          ? Colors.black12
                          : Colors.pink,
                      child: FlatButton(
                        padding: EdgeInsets.all(16),
                        child: Text(
                          dic['submit'],
                          style: TextStyle(color: Colors.white),
                        ),
                        onPressed: store.assets.submitting
                            ? null
                            : () => _onSubmit(context),
                      ),
                    ),
                  ),
                ],
              )
            ],
          ),
        );
      }),
    );
  }
}
