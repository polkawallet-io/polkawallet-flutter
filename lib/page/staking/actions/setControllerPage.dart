import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:polka_wallet/common/components/addressFormItem.dart';
import 'package:polka_wallet/common/components/roundedButton.dart';
import 'package:polka_wallet/page/account/txConfirmPage.dart';
import 'package:polka_wallet/page/staking/actions/accountSelectPage.dart';
import 'package:polka_wallet/store/account/types/accountData.dart';
import 'package:polka_wallet/store/app.dart';
import 'package:polka_wallet/utils/UI.dart';
import 'package:polka_wallet/utils/format.dart';
import 'package:polka_wallet/utils/i18n/index.dart';

class SetControllerPage extends StatefulWidget {
  SetControllerPage(this.store);
  static final String route = '/staking/controller';
  final AppStore store;
  @override
  _SetControllerPageState createState() => _SetControllerPageState(store);
}

class _SetControllerPageState extends State<SetControllerPage> {
  _SetControllerPageState(this.store);
  final AppStore store;

  AccountData _controller;

  void _onSubmit(BuildContext context) {
    var currentController = ModalRoute.of(context).settings.arguments;
    if (currentController != null &&
        _controller.pubKey == (currentController as AccountData).pubKey) {
      showCupertinoDialog(
        context: context,
        builder: (BuildContext context) {
          return CupertinoAlertDialog(
            title: Container(),
            content: Text(I18n.of(context).staking['controller.warn']),
            actions: <Widget>[
              CupertinoButton(
                child: Text(I18n.of(context).home['ok']),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          );
        },
      );
      return;
    }

    String address = Fmt.addressOfAccount(_controller, store);
    Map<String, dynamic> args = {
      "title": I18n.of(context).staking['action.control'],
      "txInfo": {
        "module": 'staking',
        "call": 'setController',
      },
      "detail": jsonEncode({"controllerId": address}),
      "params": [address],
      'onFinish': (BuildContext txPageContext, Map res) {
        Navigator.popUntil(txPageContext, ModalRoute.withName('/'));
        globalBondingRefreshKey.currentState.show();
      }
    };
    Navigator.of(context).pushNamed(TxConfirmPage.route, arguments: args);
  }

  Future<void> _changeControllerId(BuildContext context) async {
    var acc = await Navigator.of(context).pushNamed(AccountSelectPage.route);
    if (acc != null) {
      setState(() {
        _controller = acc;
      });
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_controller == null) {
      var acc = ModalRoute.of(context).settings.arguments;
      setState(() {
        _controller = acc;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final Map<String, String> dic = I18n.of(context).staking;

    return Scaffold(
      appBar: AppBar(
        title: Text(dic['action.control']),
        centerTitle: true,
      ),
      body: Builder(builder: (BuildContext context) {
        return SafeArea(
          child: Column(
            children: <Widget>[
              Expanded(
                child: ListView(
                  padding: EdgeInsets.all(16),
                  children: <Widget>[
                    AddressFormItem(
                      store.account.currentAccount,
                      label: dic['stash'],
                    ),
                    AddressFormItem(
                      _controller ?? store.account.currentAccount,
                      label: dic['controller'],
                      onTap: () => _changeControllerId(context),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.all(16),
                child: RoundedButton(
                  text: I18n.of(context).home['submit.tx'],
                  onPressed: () => _onSubmit(context),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}
