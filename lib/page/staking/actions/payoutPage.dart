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

  List _eraOptions = [];
  int _eraSelected = 0;
  int _eraSelectNew = 0;
  bool _loading = true;

  Future<void> _queryLatestRewards() async {
    final options = await webApi.staking.fetchAccountRewardsEraOptions();
    setState(() {
      _eraOptions = options;
    });
    await webApi.staking.fetchAccountRewards(
        store.account.currentAccount.pubKey, options[0]['value']);
    setState(() {
      _loading = false;
    });
  }

  Future<void> _queryRewards(int selectedEra) async {
    setState(() {
      _loading = true;
    });
    await webApi.staking.fetchAccountRewards(
        store.account.currentAccount.pubKey, _eraOptions[selectedEra]['value']);
    setState(() {
      _loading = false;
    });
  }

  Future<void> _showEraSelect() async {
    await showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) {
        return Container(
          height: MediaQuery.of(context).copyWith().size.height / 3,
          child: CupertinoPicker(
            backgroundColor: Colors.white,
            itemExtent: 58,
            scrollController: FixedExtentScrollController(
              initialItem: _eraSelected,
            ),
            children: _eraOptions.map((i) {
              return Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  _getEraText(i),
                  style: TextStyle(fontSize: 16),
                ),
              );
            }).toList(),
            onSelectedItemChanged: (v) {
              setState(() {
                _eraSelectNew = v;
              });
            },
          ),
        );
      },
    );

    if (_eraSelected != _eraSelectNew) {
      _queryRewards(_eraSelectNew);
      setState(() {
        _eraSelected = _eraSelectNew;
      });
    }
  }

  String _getEraText(Map selected) {
    if (selected['unit'] == 'eras') {
      final dic = I18n.of(context).staking;
      return '${dic['reward.max']} ${selected['text']} ${selected['unit']}';
    } else {
      return '${selected['text']} ${selected['unit']}';
    }
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _queryLatestRewards();
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
        return SafeArea(
          child: Column(
            children: <Widget>[
              Expanded(
                child: ListView(
                  padding: EdgeInsets.only(top: 16),
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.only(left: 16, right: 16),
                      child: AddressFormItem(
                        store.account.currentAccount,
                        label: dic['reward.sender'],
                      ),
                    ),
                    _eraOptions.length > 0
                        ? ListTile(
                            title: Text(dic['reward.time']),
                            subtitle:
                                Text(_getEraText(_eraOptions[_eraSelected])),
                            trailing: Icon(Icons.arrow_forward_ios, size: 18),
                            onTap: _loading ? null : () => _showEraSelect(),
                          )
                        : Container(),
                    _loading
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
                        : Padding(
                            padding: EdgeInsets.only(left: 16, right: 16),
                            child: TextFormField(
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
                          ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.all(16),
                child: RoundedButton(
                  text: I18n.of(context).home['submit.tx'],
                  onPressed: _loading ||
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
