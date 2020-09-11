import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:polka_wallet/common/components/addressFormItem.dart';
import 'package:polka_wallet/common/components/roundedButton.dart';
import 'package:polka_wallet/page/account/txConfirmPage.dart';
import 'package:polka_wallet/service/substrateApi/api.dart';
import 'package:polka_wallet/store/app.dart';
import 'package:polka_wallet/utils/UI.dart';
import 'package:polka_wallet/utils/format.dart';
import 'package:polka_wallet/utils/i18n/index.dart';

class PayoutPage extends StatefulWidget {
  PayoutPage(this.store);
  static final String route = '/staking/payout';
  final AppStore store;
  @override
  _PayoutPageState createState() => _PayoutPageState(store);
}

class _PayoutPageState extends State<PayoutPage> {
  _PayoutPageState(this.store);
  final AppStore store;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (store.staking.accountRewardTotal == null) {
        webApi.staking.fetchAccountRewards(store.account.currentAccount.pubKey);
      }
    });
  }

  void _onSubmit() {
    var dic = I18n.of(context).staking;
    final int decimals = store.settings.networkState.tokenDecimals;

    List rewards = store.staking.rewards['validators'];
    if (rewards.length == 1 && List.of(rewards[0]['eras']).length == 1) {
      var args = {
        "title": dic['action.payout'],
        "txInfo": {
          "module": 'staking',
          "call": 'payoutStakers',
        },
        "detail": jsonEncode({
          'era': rewards[0]['eras'][0]['era'],
          'validator': rewards[0]['validatorId'],
          'amount': Fmt.token(
            BigInt.parse(rewards[0]['available'].toString()),
            decimals,
            length: decimals,
          ),
        }),
        "params": [
          // validatorId
          rewards[0]['validatorId'],
          // era
          rewards[0]['eras'][0]['era'],
        ],
        'onFinish': (BuildContext txPageContext, Map res) {
          Navigator.popUntil(txPageContext, ModalRoute.withName('/'));
          globalBondingRefreshKey.currentState.show();
        }
      };
      Navigator.of(context).pushNamed(TxConfirmPage.route, arguments: args);
      return;
    }

    List params = [];
    rewards.forEach((i) {
      String validatorId = i['validatorId'];
      List.of(i['eras']).forEach((era) {
        params
            .add('api.tx.staking.payoutStakers("$validatorId", ${era['era']})');
      });
    });
    var args = {
      "title": dic['action.payout'],
      "txInfo": {
        "module": 'utility',
        "call": 'batch',
      },
      "detail": jsonEncode({
        'amount': Fmt.token(
          store.staking.accountRewardTotal,
          decimals,
          length: decimals,
        ),
        'txs': params,
      }),
      "params": [],
      "rawParam": '[[${params.join(',')}]]',
      'onFinish': (BuildContext txPageContext, Map res) {
        Navigator.popUntil(txPageContext, ModalRoute.withName('/'));
        globalBondingRefreshKey.currentState.show();
      }
    };
    print(args['rawParam']);
    Navigator.of(context).pushNamed(TxConfirmPage.route, arguments: args);
  }

  @override
  Widget build(BuildContext context) {
    var dic = I18n.of(context).staking;
    final int decimals = store.settings.networkState.tokenDecimals;
    return Scaffold(
      appBar: AppBar(
        title: Text(dic['action.payout']),
        centerTitle: true,
      ),
      body: Observer(builder: (BuildContext context) {
        bool rewardLoading = store.staking.accountRewardTotal == null;
        return SafeArea(
          child: Column(
            children: <Widget>[
              Expanded(
                child: ListView(
                  padding: EdgeInsets.all(16),
                  children: <Widget>[
                    AddressFormItem(
                      store.account.currentAccount,
                      label: dic['controller'],
                    ),
                    rewardLoading
                        ? Column(
                            children: <Widget>[
                              Padding(
                                padding: EdgeInsets.all(16),
                                child: CupertinoActivityIndicator(),
                              ),
                              Container(
                                width: MediaQuery.of(context).size.width / 2,
                                child: Text(
                                    I18n.of(context).staking['reward.tip']),
                              ),
                            ],
                          )
                        : TextFormField(
                            decoration: InputDecoration(
                              labelText: I18n.of(context).assets['amount'],
                            ),
                            initialValue: Fmt.token(
                              store.staking.accountRewardTotal,
                              decimals,
                              length: 8,
                            ),
                            readOnly: true,
                          ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.all(16),
                child: RoundedButton(
                  text: I18n.of(context).home['submit.tx'],
                  onPressed: rewardLoading ||
                          store.staking.accountRewardTotal == BigInt.zero
                      ? null
                      : _onSubmit,
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}
