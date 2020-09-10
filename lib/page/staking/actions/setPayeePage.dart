import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:polka_wallet/common/components/addressFormItem.dart';
import 'package:polka_wallet/common/components/roundedButton.dart';
import 'package:polka_wallet/page/account/txConfirmPage.dart';
import 'package:polka_wallet/store/app.dart';
import 'package:polka_wallet/utils/UI.dart';
import 'package:polka_wallet/utils/i18n/index.dart';

class SetPayeePage extends StatefulWidget {
  SetPayeePage(this.store);
  static final String route = '/staking/payee';
  final AppStore store;
  @override
  _SetPayeePageState createState() => _SetPayeePageState(store);
}

class _SetPayeePageState extends State<SetPayeePage> {
  _SetPayeePageState(this.store);
  final AppStore store;

  final _rewardToOptions = ['Staked', 'Stash', 'Controller'];

  int _rewardTo;

  void _onSubmit() {
    var dic = I18n.of(context).staking;
    var rewardToOptions =
        _rewardToOptions.map((i) => dic['reward.$i']).toList();
    int currentPayee =
        _rewardToOptions.indexOf(store.staking.ownStashInfo.destination);

    if (currentPayee == _rewardTo) {
      showCupertinoDialog(
        context: context,
        builder: (BuildContext context) {
          return CupertinoAlertDialog(
            title: Container(),
            content: Text('${dic['reward.warn']}'),
            actions: <Widget>[
              CupertinoButton(
                child: Text(I18n.of(context).home['cancel']),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          );
        },
      );
      return;
    }
    var args = {
      "title": dic['action.setting'],
      "txInfo": {
        "module": 'staking',
        "call": 'setPayee',
      },
      "detail": jsonEncode({
        "reward_destination": rewardToOptions[_rewardTo],
      }),
      "params": [
        // "to"
        _rewardTo,
      ],
      'onFinish': (BuildContext txPageContext, Map res) {
        Navigator.popUntil(txPageContext, ModalRoute.withName('/'));
        globalBondingRefreshKey.currentState.show();
      }
    };
    Navigator.of(context).pushNamed(TxConfirmPage.route, arguments: args);
  }

  @override
  Widget build(BuildContext context) {
    final dic = I18n.of(context).staking;
    final defaultValue = ModalRoute.of(context).settings.arguments ?? 0;

    final rewardToOptions =
        _rewardToOptions.map((i) => dic['reward.$i']).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(dic['action.setting']),
        centerTitle: true,
      ),
      body: Builder(builder: (BuildContext context) {
        return SafeArea(
          child: Column(
            children: <Widget>[
              Expanded(
                child: ListView(
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.only(left: 16, right: 16, top: 8),
                      child: AddressFormItem(
                        store.account.currentAccount,
                        label: dic['controller'],
                      ),
                    ),
                    ListTile(
                      title: Text(dic['bond.reward']),
                      subtitle:
                          Text(rewardToOptions[_rewardTo ?? defaultValue]),
                      trailing: Icon(Icons.arrow_forward_ios, size: 18),
                      onTap: () {
                        showCupertinoModalPopup(
                          context: context,
                          builder: (_) => Container(
                            height:
                                MediaQuery.of(context).copyWith().size.height /
                                    3,
                            child: CupertinoPicker(
                              backgroundColor: Colors.white,
                              itemExtent: 56,
                              scrollController: FixedExtentScrollController(
                                  initialItem: defaultValue),
                              children: rewardToOptions
                                  .map((i) => Padding(
                                        padding: EdgeInsets.all(12),
                                        child: Text(
                                          i,
                                          style: TextStyle(fontSize: 14),
                                        ),
                                      ))
                                  .toList(),
                              onSelectedItemChanged: (v) {
                                setState(() {
                                  _rewardTo = v;
                                });
                              },
                            ),
                          ),
                        );
                      },
                    )
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.all(16),
                child: RoundedButton(
                  text: I18n.of(context).home['submit.tx'],
                  onPressed: () => _onSubmit(),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}
