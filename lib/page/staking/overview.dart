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
import 'package:polka_wallet/utils/UI.dart';
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

  Future<void> _refreshData() async {
    if (store.settings.loading) {
      return;
    }
    await store.api.fetchAccountStaking();
    reloadStakingOverview();
  }

  Widget _buildTopCard(BuildContext context) {
    var dic = I18n.of(context).staking;
    int bonded = 0;
    List nominators = [];
    double nominatorListHeight = 48;
    if (store.staking.ledger['stakingLedger'] != null) {
      bonded = store.staking.ledger['stakingLedger']['active'];
      nominators = store.staking.ledger['nominators'];
      if (nominators.length > 0) {
        nominatorListHeight = double.parse((nominators.length * 60).toString());
      }
    }

    Color actionButtonColor = Theme.of(context).primaryColor;
    Color disabledColor = Theme.of(context).disabledColor;

    return RoundedCard(
      margin: EdgeInsets.fromLTRB(16, 12, 16, 24),
      padding: EdgeInsets.only(bottom: 8),
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
                                  dic[nominators.length > 0
                                      ? 'action.nominee'
                                      : 'action.nominate'],
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
                      onTap: () =>
                          Navigator.pushNamed(context, '/staking/nominate'),
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
          AnimatedContainer(
            height: _expanded ? nominatorListHeight : 0,
            duration: Duration(seconds: 1),
            curve: Curves.fastOutSlowIn,
            child: AnimatedOpacity(
              opacity: _expanded ? 1.0 : 0.0,
              duration: Duration(seconds: 1),
              curve: Curves.fastLinearToSlowEaseIn,
              child: nominators.length > 0
                  ? _buildNominatingList()
                  : Padding(
                      padding: EdgeInsets.only(top: 16),
                      child: Text(
                        I18n.of(context).home['data.empty'],
                        style: TextStyle(color: Colors.black54),
                      ),
                    ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildNominatingList() {
    bool hasData = store.staking.ledger['stakingLedger'] != null;
    if (!hasData) {
      return Container();
    }
    String symbol = store.settings.networkState.tokenSymbol;
    String address = store.account.currentAccount.address;

    return Column(
      children: List<Widget>.from(store.staking.ledger['nominators'].map((id) {
        ValidatorData validator;
        int validatorIndex =
            store.staking.validatorsInfo.indexWhere((i) => i.accountId == id);
        if (validatorIndex >= 0) {
          validator = store.staking.validatorsInfo[validatorIndex];
        } else {
          return CupertinoActivityIndicator();
        }

        int meStaked = 0;
        int meIndex =
            validator.nominators.indexWhere((i) => i['who'] == address);
        if (meIndex >= 0) {
          meStaked = validator.nominators[meIndex]['value'];
        }
        Map accInfo = store.account.accountIndexMap[id];
        return Expanded(
          child: Container(
            color: Theme.of(context).cardColor,
            child: ListTile(
              leading: Image.asset('assets/images/assets/Assets_nav_0.png'),
              title: Text('${Fmt.token(meStaked)} $symbol'),
              subtitle: Text(accInfo != null
                  ? accInfo['identity']['display'] != null
                      ? accInfo['identity']['display'].toString().toUpperCase()
                      : accInfo['accountIndex']
                  : Fmt.address(validator.accountId, pad: 6)),
              trailing: Container(
                width: 120,
                height: 40,
//                color: Colors.grey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Expanded(
                      child: Text('commission'),
                    ),
                    Expanded(
                      child: Text(validator.commission),
                    )
                  ],
                ),
              ),
              onTap: () {
                store.api.queryValidatorRewards(validator.accountId);
                Navigator.of(context)
                    .pushNamed('/staking/validator', arguments: validator);
              },
            ),
          ),
        );
      }).toList()),
    );
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (store.staking.ledger['stakingLedger'] == null) {
        globalNominatingRefreshKey.currentState.show();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Observer(
      builder: (_) {
        bool hashData = store.staking.ledger['stakingLedger'] != null;
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
          list.add(Container(
            color: Theme.of(context).cardColor,
            height: 160,
            child: CupertinoActivityIndicator(),
          ));
        }
        return hashData
            ? RefreshIndicator(
                key: globalNominatingRefreshKey,
                onRefresh: _refreshData,
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
            : Container();
      },
    );
  }
}
