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

  int _sort = 0;
  String _filter = '';

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
  Widget build(BuildContext context) {
    return Observer(
      builder: (_) {
        bool hashData = store.staking.overview['validators'] != null;
        List list = [
          // index_0: the overview card
          _buildTopCard(context),
          // index_1: the 'Validators' label
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Container(
                margin: EdgeInsets.all(16),
                height: 16,
                decoration: BoxDecoration(
                  border:
                      Border(left: BorderSide(width: 3, color: Colors.pink)),
                ),
              ),
              Text(
                I18n.of(context).staking['validators'],
                style: Theme.of(context).textTheme.display4,
              ),
            ],
          ),
          // index_2: the filter
          Container(
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
          ),
        ];
        if (store.staking.validatorsInfo.length > 0) {
          List<ValidatorData> ls =
              List<ValidatorData>.of(store.staking.validatorsInfo);
          // filter list
          ls.retainWhere(
              (i) => i.accountId.toLowerCase().contains(_filter.toLowerCase()));
          // sort list
          ls.sort((a, b) => Fmt.sortValidatorList(a, b, _sort));
//          list = ls.map((i) => Validator(store.api, i)).toList();
          list.addAll(ls);
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
                    return Validator(store.api, list[i] as ValidatorData);
                  },
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
