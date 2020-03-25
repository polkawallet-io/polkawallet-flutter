import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:polka_wallet/page/staking/validators/nominatePage.dart';
import 'package:polka_wallet/page/staking/validators/validatorDetailPage.dart';
import 'package:polka_wallet/service/substrateApi/api.dart';
import 'package:polka_wallet/common/components/BorderedTitle.dart';
import 'package:polka_wallet/common/components/addressIcon.dart';
import 'package:polka_wallet/common/components/outlinedCircle.dart';
import 'package:polka_wallet/common/components/roundedCard.dart';
import 'package:polka_wallet/common/components/validatorListFilter.dart';
import 'package:polka_wallet/page/staking/validators/validator.dart';
import 'package:polka_wallet/store/app.dart';
import 'package:polka_wallet/store/staking.dart';
import 'package:polka_wallet/utils/UI.dart';
import 'package:polka_wallet/utils/format.dart';
import 'package:polka_wallet/utils/i18n/index.dart';
import 'package:polka_wallet/utils/localStorage.dart';

const validator_list_page_size = 100;

class StakingOverviewPage extends StatefulWidget {
  StakingOverviewPage(this.store);

  final AppStore store;

  @override
  _StakingOverviewPageState createState() => _StakingOverviewPageState(store);
}

class _StakingOverviewPageState extends State<StakingOverviewPage> {
  _StakingOverviewPageState(this.store);

  final AppStore store;

  bool _expanded = false;

  int _sort = 0;
  String _filter = '';

  Future<void> _refreshData() async {
    if (store.settings.loading) {
      return;
    }
    await webApi.staking
        .fetchAccountStaking(store.account.currentAccount.pubKey);
    webApi.staking.fetchStakingOverview();
  }

  Widget _buildTopCard(BuildContext context) {
    var dic = I18n.of(context).staking;
    bool hashData = store.staking.ledger['stakingLedger'] != null;
    String stashId = store.staking.ledger['stashId'];
    int bonded = 0;
    List nominators = [];
    double nominatorListHeight = 48;
    if (hashData) {
      stashId = store.staking.ledger['stakingLedger']['stash'];
      bonded = store.staking.ledger['stakingLedger']['active'];
      nominators = store.staking.ledger['nominators'];
      if (nominators.length > 0) {
        nominatorListHeight = double.parse((nominators.length * 60).toString());
      }
    }
    bool isStash = store.staking.ledger['accountId'] == stashId;

    Color actionButtonColor = Theme.of(context).primaryColor;
    Color disabledColor = Theme.of(context).disabledColor;

    return RoundedCard(
      margin: EdgeInsets.fromLTRB(16, 12, 16, 24),
      padding: EdgeInsets.only(top: 8, bottom: 8),
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
              child: !isStash && bonded > 0
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
                          Navigator.pushNamed(context, NominatePage.route),
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
    String stashAddress = store.staking.ledger['stakingLedger']['stash'];
    List nominators = store.staking.ledger['nominators'];

    return Container(
      padding: EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: Theme.of(context).dividerColor, width: 0.5),
        ),
      ),
      child: Column(
        children: List<Widget>.from(nominators.map((id) {
          ValidatorData validator;
          int validatorIndex =
              store.staking.validatorsInfo.indexWhere((i) => i.accountId == id);
          if (validatorIndex < 0) {
            return Expanded(
              child: ListTile(
                  leading: AddressIcon(id),
                  title: Text(I18n.of(context).staking['notElected']),
                  subtitle: Text(Fmt.address(id, pad: 6))),
            );
          }
          validator = store.staking.validatorsInfo[validatorIndex];

          int meStaked;
          int meIndex =
              validator.nominators.indexWhere((i) => i['who'] == stashAddress);
          if (meIndex >= 0) {
            meStaked = validator.nominators[meIndex]['value'];
          }

          Map accInfo = store.account.accountIndexMap[id];
          return Expanded(
            child: ListTile(
              leading: AddressIcon(id),
              title: Text(
                  '${meStaked != null ? Fmt.token(meStaked) : '~'} $symbol'),
              subtitle: Text(
                  accInfo != null && accInfo['identity']['display'] != null
                      ? accInfo['identity']['display'].toString().toUpperCase()
                      : Fmt.address(validator.accountId, pad: 6)),
              trailing: Container(
                width: 120,
                height: 40,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Expanded(
                      child: Text('commission'),
                    ),
                    Expanded(
                      child: Text(validator.commission.isNotEmpty
                          ? validator.commission
                          : '~'),
                    )
                  ],
                ),
              ),
              onTap: () {
                webApi.staking.queryValidatorRewards(validator.accountId);
                Navigator.of(context)
                    .pushNamed(ValidatorDetailPage.route, arguments: validator);
              },
            ),
          );
        }).toList()),
      ),
    );
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (LocalStorage.checkCacheTimeout(store.staking.cacheTxsTimestamp)) {
        globalNominatingRefreshKey.currentState.show();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Observer(
      builder: (_) {
        List list = [
          // index_0: the overview card
          _buildTopCard(context),
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
            height: 160,
            child: CupertinoActivityIndicator(),
          ));
        }
        return RefreshIndicator(
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
        );
      },
    );
  }
}
