import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:intl/intl.dart';
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

  int _tab = 0;
  ScrollController _scrollController;
  int _validatorListLength = 10;
  int _nextListLength = 10;

  int _sort = 0;
  String _filter = '';

  Future<void> _getNextUpsInfo() async {
    int len = store.staking.nextUps.length;
    if (len > 0) {
      var res = await Future.wait(store.staking.nextUps
          .sublist(_nextListLength - 10, _nextListLength)
          .map((address) => store.api
              .evalJavascript('api.derive.staking.query("$address")')));
      print(res.length);
      store.staking.setNextUpsInfo(res);
    }
  }

  Widget _buildTopCard(BuildContext context) {
    var dic = I18n.of(context).staking;
    String symbol = store.settings.networkState.tokenSymbol;
    var overview = store.staking.overview;
    String session;
    if (overview['session'] != null) {
      session =
          '${overview['session']['sessionProgress']}/${overview['session']['sessionLength']}';
    }
    String era;
    if (overview['session'] != null) {
      era =
          '${overview['session']['eraProgress']}/${overview['session']['eraLength']}';
    }
    return RoundedCard(
      margin: EdgeInsets.fromLTRB(16, 8, 16, 16),
      padding: EdgeInsets.all(24),
      child: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              InfoItem(
                title: dic['validators'],
                content:
                    '${overview['validators'].length}/${overview['validatorCount']}',
              ),
              InfoItem(
                title: dic['nominators'],
                content: store.staking.nominatorCount.toString(),
              ),
            ],
          ),
          Padding(
            padding: EdgeInsets.only(top: 16, bottom: 16),
            child: Row(
              children: <Widget>[
                InfoItem(
                  title: dic['session'],
                  content: session,
                ),
                InfoItem(
                  title: dic['era'],
                  content: era,
                ),
              ],
            ),
          ),
          Row(
            children: <Widget>[
              InfoItem(
                title: '${dic['total']} ($symbol)',
                content: '${Fmt.token(store.staking.staked, decimals: 18)} M',
              ),
              InfoItem(
                title: dic['staked'],
                content: NumberFormat('0.00%').format(
                    store.staking.staked / int.parse(overview['issuance'])),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();

    _scrollController = ScrollController();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent) {
        setState(() {
          int end;
          if (_tab == 0) {
            end = _validatorListLength + validator_list_page_size;
            _validatorListLength = end > store.staking.validatorsInfo.length
                ? store.staking.validatorsInfo.length
                : end;
          } else {
            end = _nextListLength + validator_list_page_size;
            _nextListLength = end > store.staking.nextUps.length
                ? store.staking.nextUps.length
                : end;
          }
        });
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    _scrollController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Observer(
      builder: (_) {
        bool hashData = store.staking.overview['validators'] != null;
        List<Widget> list = [
          Padding(
            padding: EdgeInsets.all(24),
            child: CupertinoActivityIndicator(),
          )
        ];
        if (store.staking.validatorsInfo.length > 0) {
          List<ValidatorData> ls =
              List<ValidatorData>.of(store.staking.validatorsInfo);
          // filter list
          ls.retainWhere(
              (i) => i.accountId.toLowerCase().contains(_filter.toLowerCase()));
          // sort list
          ls.sort((a, b) => Fmt.sortValidatorList(a, b, _sort));
          list = ls.map((i) => Validator(store.api, i)).toList();
        }
        return hashData
            ? RefreshIndicator(
                onRefresh: reloadStakingOverview,
                child: ListView(
                  controller: _scrollController,
                  children: <Widget>[
                    _buildTopCard(context),
                    Container(
                      color: Colors.white,
                      child: Row(
                        children: <Widget>[
                          Container(
                            margin: EdgeInsets.all(16),
                            height: 16,
                            decoration: BoxDecoration(
                              border: Border(
                                  left:
                                      BorderSide(width: 3, color: Colors.pink)),
                            ),
                          ),
                          Text(
                            I18n.of(context).staking['validators'],
                            style: Theme.of(context).textTheme.display4,
                          ),
                          Expanded(
                            child: Container(),
                          )
                        ],
                      ),
                    ),
                    ValidatorListFilter(
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
                    ...list.sublist(0, _validatorListLength)
                  ],
                ),
              )
            : CupertinoActivityIndicator();
      },
    );
  }
}

class InfoItem extends StatelessWidget {
  InfoItem({this.title, this.content});
  final String title;
  final String content;
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            title,
          ),
          content == null
              ? CupertinoActivityIndicator()
              : Text(
                  content,
                  style: Theme.of(context).textTheme.display4,
                )
        ],
      ),
    );
  }
}
