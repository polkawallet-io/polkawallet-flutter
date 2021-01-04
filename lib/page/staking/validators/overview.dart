import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:polka_wallet/common/components/textTag.dart';
import 'package:polka_wallet/page/account/txConfirmPage.dart';
import 'package:polka_wallet/page/staking/actions/bondExtraPage.dart';
import 'package:polka_wallet/page/staking/actions/bondPage.dart';
import 'package:polka_wallet/page/staking/validators/nominatePage.dart';
import 'package:polka_wallet/page/staking/validators/validatorDetailPage.dart';
import 'package:polka_wallet/service/substrateApi/api.dart';
import 'package:polka_wallet/common/components/addressIcon.dart';
import 'package:polka_wallet/common/components/outlinedCircle.dart';
import 'package:polka_wallet/common/components/roundedCard.dart';
import 'package:polka_wallet/common/components/validatorListFilter.dart';
import 'package:polka_wallet/page/staking/validators/validator.dart';
import 'package:polka_wallet/service/walletApi.dart';
import 'package:polka_wallet/store/app.dart';
import 'package:polka_wallet/store/staking/types/ownStashInfo.dart';
import 'package:polka_wallet/store/staking/types/validatorData.dart';
import 'package:polka_wallet/utils/UI.dart';
import 'package:polka_wallet/utils/format.dart';
import 'package:polka_wallet/utils/i18n/index.dart';

const validator_list_page_size = 100;

class StakingOverviewPage extends StatefulWidget {
  StakingOverviewPage(this.store);

  final AppStore store;

  @override
  _StakingOverviewPageState createState() => _StakingOverviewPageState(store);
}

class _StakingOverviewPageState extends State<StakingOverviewPage>
    with SingleTickerProviderStateMixin {
  _StakingOverviewPageState(this.store);

  final AppStore store;

  bool _expanded = false;

  int _sort = 0;
  String _filter = '';

  TabController _tabController;
  int _tab = 0;

  Future<void> _refreshData() async {
    if (store.settings.loading) {
      return;
    }
    await Future.wait([
      webApi.staking.fetchAccountStaking(),
      webApi.staking.fetchStakingOverview(),
    ]);
    _fetchRecommendedValidators();
  }

  Future<void> _fetchRecommendedValidators() async {
    Map res = await WalletApi.getRecommended();
    if (res != null && res['validators'] != null) {
      store.staking.setRecommendedValidatorList(res['validators']);
    }
  }

  void _goToBond({bondExtra = false}) {
    if (store.staking.ownStashInfo == null) return;

    var dic = I18n.of(context).staking;
    showCupertinoDialog(
      context: context,
      builder: (_) {
        return CupertinoAlertDialog(
          title: Text(dic['action.nominate']),
          content: Text(dic['action.nominate.bond']),
          actions: <Widget>[
            CupertinoButton(
              child: Text(I18n.of(context).home['cancel']),
              onPressed: () => Navigator.of(context).pop(),
            ),
            CupertinoButton(
              child: Text(I18n.of(context).home['ok']),
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.pushNamed(
                    context, bondExtra ? BondExtraPage.route : BondPage.route);
              },
            ),
          ],
        );
      },
    );
  }

  void _onSetPayee() {
    if (store.staking.ownStashInfo == null) return;

    var dic = I18n.of(context).staking;
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) => CupertinoActionSheet(
        actions: <Widget>[
          CupertinoActionSheetAction(
            child: Text(
              dic['action.nominee'],
            ),
            onPressed: () {
              Navigator.of(context).popAndPushNamed(NominatePage.route);
            },
          ),
          CupertinoActionSheetAction(
            child: Text(
              dic['action.chill'],
            ),
            onPressed: () {
              Navigator.of(context).pop();
              _chill();
            },
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          child: Text(I18n.of(context).home['cancel']),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
    );
  }

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

  Widget _buildTopCard(BuildContext context) {
    var dic = I18n.of(context).staking;
    bool hashData = store.staking.ownStashInfo != null &&
        store.staking.ownStashInfo.stakingLedger != null;

    BigInt bonded = BigInt.zero;
    List nominators = [];
    double nominatorListHeight = 48;
    bool isController = false;
    bool isStash = true;
    if (hashData) {
      bonded = BigInt.parse(store.staking.ownStashInfo.stakingLedger['active']);
      nominators = store.staking.ownStashInfo.nominating.toList();
      if (nominators.length > 0) {
        nominatorListHeight = double.parse((nominators.length * 56).toString());
      }
      isController = store.staking.ownStashInfo.isOwnController;
      isStash = store.staking.ownStashInfo.isOwnStash ||
          (!store.staking.ownStashInfo.isOwnStash &&
              !store.staking.ownStashInfo.isOwnController);
    }

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
              hashData
                  ? store.staking.ownStashInfo.nominating.length.toString()
                  : '0',
              style: Theme.of(context).textTheme.headline4,
            ),
            subtitle: Text(dic['nominating']),
            trailing: Container(
              width: 100,
              child: store.staking.ownStashInfo?.controllerId == null && isStash
                  ? GestureDetector(
                      child: Column(
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
                      onTap: _goToBond,
                    )
                  : isStash && !isController
                      ? Column(
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
                        )
                      : GestureDetector(
                          child: Column(
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
                          ),
                          onTap: bonded > BigInt.zero
                              ? _onSetPayee
                              : () => _goToBond(bondExtra: true),
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
    if (store.staking.ownStashInfo == null ||
        store.staking.validatorsInfo.length == 0) {
      return Container();
    }

    final stashId = store.staking.ownStashInfo.stashId;
    final NomineesInfoData nomineesInfo = store.staking.ownStashInfo.inactives;
    final List<Widget> list = nomineesInfo.nomsActive.map((id) {
      return Expanded(
        child: _NomineeItem(
          id,
          store.staking.validatorsInfo,
          stashId,
          NomStatus.active,
          store.settings.networkState.tokenDecimals,
          store.account.addressIndexMap,
        ),
      );
    }).toList();

    list.addAll(nomineesInfo.nomsOver.map((id) {
      return Expanded(
        child: _NomineeItem(
          id,
          store.staking.validatorsInfo,
          stashId,
          NomStatus.over,
          store.settings.networkState.tokenDecimals,
          store.account.addressIndexMap,
        ),
      );
    }).toList());

    list.addAll(nomineesInfo.nomsInactive.map((id) {
      return Expanded(
        child: _NomineeItem(
          id,
          store.staking.validatorsInfo,
          stashId,
          NomStatus.inactive,
          store.settings.networkState.tokenDecimals,
          store.account.addressIndexMap,
        ),
      );
    }).toList());

    list.addAll(nomineesInfo.nomsWaiting.map((id) {
      return Expanded(
        child: _NomineeItem(
          id,
          store.staking.validatorsInfo,
          stashId,
          NomStatus.waiting,
          store.settings.networkState.tokenDecimals,
          store.account.addressIndexMap,
        ),
      );
    }).toList());
    return Container(
      padding: EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: Theme.of(context).dividerColor, width: 0.5),
        ),
      ),
      child: Column(
        children: list,
      ),
    );
  }

  @override
  void initState() {
    super.initState();

    _tabController = TabController(vsync: this, length: 2);

//    WidgetsBinding.instance.addPostFrameCallback((_) {
//      globalNominatingRefreshKey.currentState.show();
//    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Map dic = I18n.of(context).staking;
    return Observer(
      builder: (_) {
        final int decimals = store.settings.networkState.tokenDecimals;
        final List<Tab> _listTabs = <Tab>[
          Tab(
            text: '${dic['elected']} (${store.staking.validatorsInfo.length})',
          ),
          Tab(
            text: '${dic['waiting']} (${store.staking.nextUpsInfo.length})',
          ),
        ];
        List list = [
          // index_0: the overview card
          _buildTopCard(context),
          // index_1: the 'Validators' label
          Container(
            color: Theme.of(context).cardColor,
            child: TabBar(
              labelColor: Colors.black87,
              labelStyle: TextStyle(fontSize: 18),
              controller: _tabController,
              tabs: _listTabs,
              onTap: (i) {
                setState(() {
                  _tab = i;
                });
              },
            ),
          ),
        ];
        if (store.staking.validatorsAll.length > 0) {
          // index_2: the filter Widget
          list.add(Container(
            color: Colors.white,
            padding: EdgeInsets.only(top: 8),
            child: ValidatorListFilter(
              needSort: _tab == 0,
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
          // index_3: the recommended validators
          // add recommended
          List<ValidatorData> recommended = _tab == 0
              ? store.staking.validatorsInfo.toList()
              : store.staking.nextUpsInfo.toList();
          recommended.retainWhere((i) =>
              store.staking.recommendedValidatorList.indexOf(i.accountId) > -1);
          list.add(Container(
            color: Theme.of(context).cardColor,
            child: recommended.length > 0
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextTag(
                        dic['recommend'],
                        color: Colors.green,
                        fontSize: 12,
                        margin: EdgeInsets.only(left: 16, top: 8),
                      ),
                      Column(
                        children: recommended.map((acc) {
                          Map accInfo =
                              store.account.addressIndexMap[acc.accountId];
                          return Validator(
                            acc,
                            accInfo,
                            decimals,
                            store.staking.nominationsAll[acc.accountId] ?? [],
                          );
                        }).toList(),
                      ),
                      Divider()
                    ],
                  )
                : Container(),
          ));
          // add validators
          List<ValidatorData> ls = _tab == 0
              ? store.staking.validatorsInfo.toList()
              : store.staking.nextUpsInfo.toList();
          // filter list
          ls = Fmt.filterValidatorList(
              ls, _filter, store.account.addressIndexMap);
          // sort list
          ls.sort((a, b) => Fmt.sortValidatorList(
              store.account.addressIndexMap, a, b, _sort));
          if (_tab == 1) {
            ls.sort((a, b) {
              final aLength =
                  store.staking.nominationsAll[a.accountId]?.length ?? 0;
              final bLength =
                  store.staking.nominationsAll[b.accountId]?.length ?? 0;
              return 0 - aLength.compareTo(bLength);
            });
          }
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
              // we already have the index_0 - index_3 Widget
              if (i < 4) {
                return list[i];
              }
              ValidatorData acc = list[i];
              Map accInfo = store.account.addressIndexMap[acc.accountId];

              return Validator(
                acc,
                accInfo,
                decimals,
                store.staking.nominationsAll[acc.accountId] ?? [],
              );
            },
          ),
        );
      },
    );
  }
}

enum NomStatus { active, over, inactive, waiting }

class _NomineeItem extends StatelessWidget {
  _NomineeItem(
    this.id,
    this.validators,
    this.stashId,
    this.nomStatus,
    this.decimals,
    this.accInfoMap,
  );

  final String id;
  final List<ValidatorData> validators;
  final String stashId;
  final NomStatus nomStatus;
  final int decimals;
  final Map<String, Map> accInfoMap;

  @override
  Widget build(BuildContext context) {
    final dic = I18n.of(context).staking;

    final validatorIndex = validators.indexWhere((i) => i.accountId == id);
    final validator = validatorIndex < 0
        ? ValidatorData.fromJson({'accountId': id})
        : validators[validatorIndex];

    final accInfo = accInfoMap[validator.accountId];
    final status = nomStatus.toString().split('.')[1];

    BigInt meStaked;
    int meIndex = validator.nominators.indexWhere((i) => i['who'] == stashId);
    if (meIndex >= 0) {
      meStaked =
          BigInt.parse(validator.nominators[meIndex]['value'].toString());
    }
    String subtitle = dic['nominate.$status'];
    if (nomStatus == NomStatus.active) {
      subtitle += ' ${Fmt.token(meStaked ?? BigInt.zero, decimals)}';
    }

    return ListTile(
      dense: true,
      leading: AddressIcon(validator.accountId, size: 32),
      title: Fmt.accountDisplayName(validator.accountId, accInfo),
      subtitle: Text(subtitle),
      trailing: Container(
        width: 100,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Expanded(
              child: Container(height: 4),
            ),
            Expanded(
              child: Text(
                  validator.commission.isNotEmpty ? validator.commission : '~'),
            ),
            Expanded(
              child: Text(dic['commission'], style: TextStyle(fontSize: 12)),
            ),
          ],
        ),
      ),
      onTap: () {
        webApi.staking.queryValidatorRewards(validator.accountId);
        Navigator.of(context)
            .pushNamed(ValidatorDetailPage.route, arguments: validator);
      },
    );
  }
}
