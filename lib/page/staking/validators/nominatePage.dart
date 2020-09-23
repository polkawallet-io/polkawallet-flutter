import 'dart:async';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:polka_wallet/common/components/addressIcon.dart';
import 'package:polka_wallet/common/components/roundedButton.dart';
import 'package:polka_wallet/common/components/textTag.dart';
import 'package:polka_wallet/common/components/validatorListFilter.dart';
import 'package:polka_wallet/page/account/txConfirmPage.dart';
import 'package:polka_wallet/page/staking/validators/validatorDetailPage.dart';
import 'package:polka_wallet/store/app.dart';
import 'package:polka_wallet/store/staking/types/validatorData.dart';
import 'package:polka_wallet/utils/UI.dart';
import 'package:polka_wallet/utils/format.dart';
import 'package:polka_wallet/utils/i18n/index.dart';

class NominatePage extends StatefulWidget {
  NominatePage(this.store);
  static final String route = '/staking/nominate';
  final AppStore store;
  @override
  _NominatePageState createState() => _NominatePageState(store);
}

class _NominatePageState extends State<NominatePage> {
  _NominatePageState(this.store);
  final AppStore store;

  final List<ValidatorData> _selected = List<ValidatorData>();
  final List<ValidatorData> _notSelected = List<ValidatorData>();
  Map<String, bool> _selectedMap = Map<String, bool>();

  String _filter = '';
  int _sort = 0;

  void _chill() {
    var dic = I18n.of(context).staking;
    var args = {
      "title": dic['action.chill'],
      "txInfo": {
        "module": 'staking',
        "call": 'chill',
      },
      "detail": 'chill',
      "params": [],
      'onFinish': (BuildContext txPageContext, Map res) {
        Navigator.popUntil(txPageContext, ModalRoute.withName('/'));
        globalNominatingRefreshKey.currentState.show();
      }
    };
    Navigator.of(context).pushNamed(TxConfirmPage.route, arguments: args);
  }

  void _setNominee() {
    var dic = I18n.of(context).staking;
    List<String> targets = _selected.map((i) => i.accountId).toList();

    var args = {
      "title": dic['action.nominate'],
      "txInfo": {
        "module": 'staking',
        "call": 'nominate',
      },
      "detail": jsonEncode({
        "targets": targets.join(', '),
      }),
      "params": [
        // "targets"
        targets,
      ],
      'onFinish': (BuildContext txPageContext, Map res) {
        Navigator.popUntil(txPageContext, ModalRoute.withName('/'));
        globalNominatingRefreshKey.currentState.show();
      }
    };
    Navigator.of(context).pushNamed(TxConfirmPage.route, arguments: args);
  }

  Widget _buildListItem(BuildContext context, ValidatorData validator) {
    final dic = I18n.of(context).staking;
    final int decimals = store.settings.networkState.tokenDecimals;
    final Map accInfo = store.account.addressIndexMap[validator.accountId];
    final bool hasPhalaAirdrop =
        store.staking.phalaAirdropWhiteList[validator.accountId] ?? false;
    final bool isWaiting = validator.total == BigInt.zero;
    final nominations = store.staking.nominationsAll[validator.accountId] ?? [];
    return GestureDetector(
      child: Container(
        padding: EdgeInsets.fromLTRB(16, 16, 16, 0),
        color: Theme.of(context).cardColor,
        child: Row(
          children: <Widget>[
            Container(
              margin: EdgeInsets.only(right: 16),
              child: AddressIcon(validator.accountId),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Fmt.accountDisplayName(
                    validator.accountId,
                    accInfo,
                  ),
                  !isWaiting
                      ? Text(
                          '${dic['total']}: ${Fmt.token(validator.total, decimals)}',
                          style: TextStyle(
                            color: Theme.of(context).unselectedWidgetColor,
                            fontSize: 12,
                          ),
                        )
                      : Container(),
                  Text(
                    isWaiting
                        ? dic['waiting']
                        : '${dic['commission']}: ${validator.commission}',
                    style: TextStyle(
                      color: Theme.of(context).unselectedWidgetColor,
                      fontSize: 12,
                    ),
                  ),
                  Row(
                    children: [
                      Text(
                        isWaiting
                            ? '${dic['nominators']}: ${nominations.length}'
                            : '${dic['points']}: ${validator.points}',
                        style: TextStyle(
                          color: Theme.of(context).unselectedWidgetColor,
                          fontSize: 12,
                        ),
                      ),
                      hasPhalaAirdrop ? TextTag(dic['phala']) : Container(),
                    ],
                  ),
                ],
              ),
            ),
            CupertinoSwitch(
              value: _selectedMap[validator.accountId],
              onChanged: (bool value) {
                setState(() {
                  _selectedMap[validator.accountId] = value;
                });
                Timer(Duration(milliseconds: 300), () {
                  setState(() {
                    if (value) {
                      _selected.add(validator);
                      _notSelected.removeWhere(
                          (item) => item.accountId == validator.accountId);
                    } else {
                      _selected.removeWhere(
                          (item) => item.accountId == validator.accountId);
                      _notSelected.add(validator);
                    }
                  });
                });
              },
            ),
          ],
        ),
      ),
      onTap: () => Navigator.of(context)
          .pushNamed(ValidatorDetailPage.route, arguments: validator),
    );
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        store.staking.validatorsAll.forEach((i) {
          _notSelected.add(i);
          _selectedMap[i.accountId] = false;
        });
        print(store.staking.nominatingList.length);
        store.staking.nominatingList.forEach((i) {
          _selected.add(i);
          _notSelected.removeWhere((item) => item.accountId == i.accountId);
          _selectedMap[i.accountId] = true;
        });

        // set recommended selected
        List<ValidatorData> recommended = _notSelected.toList();
        recommended.retainWhere((i) =>
            store.staking.recommendedValidatorList.indexOf(i.accountId) > -1);
        recommended.forEach((i) {
          _selected.add(i);
          _notSelected.removeWhere((item) => item.accountId == i.accountId);
          _selectedMap[i.accountId] = true;
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    var dic = I18n.of(context).staking;

    List<ValidatorData> list = [];
    list.addAll(_selected);
    // add recommended
    List<ValidatorData> recommended = _notSelected.toList();
    recommended.retainWhere((i) =>
        store.staking.recommendedValidatorList.indexOf(i.accountId) > -1);
    list.addAll(recommended);

    // add validators
    // filter the _notSelected list
    List<ValidatorData> retained = List.of(_notSelected);
    retained = Fmt.filterValidatorList(
        retained, _filter, store.account.addressIndexMap);
    // and sort it
    retained.sort((a, b) =>
        Fmt.sortValidatorList(store.account.addressIndexMap, a, b, _sort));
    list.addAll(retained);

    return Scaffold(
      appBar: AppBar(
        title: Text(dic['action.nominate']),
        centerTitle: true,
      ),
      body: Builder(builder: (BuildContext context) {
        return SafeArea(
          child: Column(
            children: <Widget>[
              Container(
                color: Theme.of(context).cardColor,
                padding: EdgeInsets.only(top: 8, bottom: 8),
                child: ValidatorListFilter(
                  onFilterChange: (v) {
                    if (_filter != v) {
                      setState(() {
                        _filter = v;
                      });
                    }
                  },
                  onSortChange: (v) {
                    if (_sort != v) {
                      setState(() {
                        _sort = v;
                      });
                    }
                  },
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: list.length,
                  itemBuilder: (BuildContext context, int i) {
                    return _buildListItem(context, list[i]);
                  },
                ),
              ),
              Padding(
                padding: EdgeInsets.all(16),
                child: RoundedButton(
                  text: I18n.of(context).home['submit.tx'],
                  onPressed: store.staking.validatorsInfo.length == 0
                      ? null
                      : _selected.length == 0 ? _chill : _setNominee,
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}
