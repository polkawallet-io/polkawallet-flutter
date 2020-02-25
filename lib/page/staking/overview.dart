import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:polka_wallet/common/components/BorderedTitle.dart';
import 'package:polka_wallet/common/components/outlinedCircle.dart';
import 'package:polka_wallet/common/components/roundedCard.dart';
import 'package:polka_wallet/common/components/validatorListFilter.dart';
import 'package:polka_wallet/page/staking/validator.dart';
import 'package:polka_wallet/store/app.dart';
import 'package:polka_wallet/store/staking.dart';
import 'package:polka_wallet/utils/format.dart';
import 'package:polka_wallet/utils/i18n/index.dart';

const validator_list_page_size = 100;

class StakingOverview extends StatefulWidget {
  StakingOverview(this.store, this.reloadStakingOverview);

  final AppStore store;
  final Function reloadStakingOverview;

  @override
  _StakingOverviewState createState() =>
      _StakingOverviewState(store, reloadStakingOverview);
}

class _StakingOverviewState extends State<StakingOverview> {
  _StakingOverviewState(this.store, this.reloadStakingOverview);

  final AppStore store;
  final Function reloadStakingOverview;

  bool _expanded = false;

  int _sort = 0;
  String _filter = '';

  Widget _buildTopCard(BuildContext context) {
    var dic = I18n.of(context).staking;
    int bonded = 0;
    List nominators = [];
    double nominatorListHeight = 48;
    if (store.staking.ledger['stakingLedger'] != null) {
      bonded = store.staking.ledger['stakingLedger']['active'];
      nominators = store.staking.ledger['nominators'];
      if (nominators.length > 0) {
        nominatorListHeight = double.parse((nominators.length * 48).toString());
      }
    }

    Color actionButtonColor = Theme.of(context).primaryColor;
    Color disabledColor = Theme.of(context).disabledColor;

    return RoundedCard(
      margin: EdgeInsets.fromLTRB(16, 8, 16, 24),
//      padding: EdgeInsets.all(24),
      child: Column(
        children: <Widget>[
          ListTile(
            leading: Container(
              width: 32,
              child: IconButton(
                icon: Icon(
                  _expanded
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down,
                  size: 32,
                ),
                onPressed: () {
                  setState(() {
                    _expanded = !_expanded;
                  });
                },
              ),
            ),
            title: Text(
              store.staking.ledger['nominators'] != null
                  ? store.staking.ledger['nominators'].length.toString()
                  : '0',
              style: Theme.of(context).textTheme.display4,
            ),
            subtitle: Text(dic['nominating']),
            trailing: Container(
              width: 100,
              child: bonded > 0
                  ? GestureDetector(
                      child: nominators.length > 0
                          ? Column(
                              children: <Widget>[
                                OutlinedCircle(
                                  icon: Icons.add,
                                  color: actionButtonColor,
                                ),
                                Text(
                                  dic['action.nominee'],
                                  style: TextStyle(color: actionButtonColor),
                                )
                              ],
                            )
                          : Column(
                              children: <Widget>[
                                OutlinedCircle(
                                  icon: Icons.add,
                                  color: actionButtonColor,
                                ),
                                Text(
                                  dic['action.nominate'],
                                  style: TextStyle(color: actionButtonColor),
                                )
                              ],
                            ),
                      onTap: () => Navigator.pushNamed(
                          context,
                          nominators.length > 0
                              ? '/staking/nominee'
                              : '/staking/nominate'),
                    )
                  : Column(
                      children: <Widget>[
                        OutlinedCircle(
                          icon: Icons.add,
                          color: disabledColor,
                        ),
                        Text(
                          dic['action.nominate'],
                          style: TextStyle(color: disabledColor),
                        )
                      ],
                    ),
            ),
          ),
          Divider(
            height: 1,
          ),
          // TODO: nominating list unfinished
          AnimatedContainer(
            height: _expanded ? nominatorListHeight : 0,
            duration: Duration(seconds: 1),
            curve: Curves.fastOutSlowIn,
            child: nominators.length > 0
                ? _buildNominatingList()
                : Padding(
                    padding: EdgeInsets.all(8),
                    child: Text('No Data'),
                  ),
          )
        ],
      ),
    );
  }

  List<Widget> _buildNominatingList() {
    bool hasData = store.staking.ledger['stakingLedger'] != null;
//    if (_ledgerLoading) {
//      return <Widget>[
//        Padding(
//          padding: EdgeInsets.all(16),
//          child: CupertinoActivityIndicator(),
//        )
//      ];
//    }
    if (!hasData) {
      return <Widget>[Container()];
    }
    String symbol = store.settings.networkState.tokenSymbol;
    String address = store.account.currentAccount.address;
//    String address = 'E4ukkmqUZv1noW1sq7uqEB2UVfzFjMEM73cVSp8roRtx14n';
    return List<Widget>.from(store.staking.ledger['nominators'].map((id) {
      var validator =
          store.staking.validatorsInfo.firstWhere((i) => i.accountId == id);
      var me = validator.nominators.firstWhere((i) => i['who'] == address);
      return Container(
        color: Theme.of(context).cardColor,
        child: ListTile(
          leading: Image.asset('assets/images/assets/Assets_nav_0.png'),
          title: Text('${Fmt.token(me['value'])} $symbol'),
          subtitle: Text(Fmt.address(validator.accountId)),
          trailing: Container(
            width: 120,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text('commission'),
                Text(validator.commission)
              ],
            ),
          ),
          onTap: () {
            store.api.queryValidatorRewards(validator.accountId);
            Navigator.of(context)
                .pushNamed('/staking/validator', arguments: validator);
          },
        ),
      );
    }).toList());
  }

  @override
  Widget build(BuildContext context) {
    return Observer(
      builder: (_) {
        bool hashData = store.staking.overview['validators'] != null;
        List list = [
          // index_0: the overview card
          hashData ? _buildTopCard(context) : Container(),
          // index_1: the 'Validators' label
          Container(
            color: Theme.of(context).cardColor,
            padding: EdgeInsets.fromLTRB(16, 16, 16, 4),
            child: BorderedTitle(
              title: I18n.of(context).staking['validators'],
            ),
          ),
        ];
//        list.addAll(_buildNominatingList());
        if (store.staking.validatorsInfo.length > 0) {
          // index_2: the filter Widget
          list.add(Container(
            color: Colors.white,
            padding: EdgeInsets.only(top: 8),
            child: ValidatorListFilter(
              onSortChange: (value) {
                if (value != _sort) {
                  setState(() {
                    _sort = value;
                  });
                }
              },
              onFilterChange: (value) {
                if (value != _filter) {
                  setState(() {
                    _filter = value;
                  });
                }
              },
            ),
          ));
          List<ValidatorData> ls =
              List<ValidatorData>.of(store.staking.validatorsInfo);
          // filter list
          ls = Fmt.filterValidatorList(
              ls, _filter, store.account.accountIndexMap);
          // sort list
          ls.sort((a, b) => Fmt.sortValidatorList(a, b, _sort));
          list.addAll(ls);
        } else {
          list.add(CupertinoActivityIndicator());
        }
        return hashData
            ? RefreshIndicator(
                onRefresh: reloadStakingOverview,
                child: ListView.builder(
                  itemCount: list.length,
                  itemBuilder: (BuildContext context, int i) {
                    // we already have the index_0 - index_2 Widget
                    if (i < 3) {
                      return list[i];
                    }
                    return Validator(store, list[i] as ValidatorData);
                  },
                ),
              )
            : CupertinoActivityIndicator();
      },
    );
  }
}
