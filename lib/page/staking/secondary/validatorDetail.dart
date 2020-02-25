import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:polka_wallet/common/components/chartLabel.dart';
import 'package:polka_wallet/common/components/roundedCard.dart';
import 'package:polka_wallet/page/staking/overview.dart';
import 'package:polka_wallet/page/staking/secondary/blocksChart.dart';
import 'package:polka_wallet/page/staking/secondary/rewardsChart.dart';
import 'package:polka_wallet/page/staking/secondary/splitChart.dart';
import 'package:polka_wallet/page/staking/secondary/stakesChart.dart';
import 'package:polka_wallet/store/app.dart';
import 'package:polka_wallet/store/staking.dart';
import 'package:polka_wallet/utils/UI.dart';
import 'package:polka_wallet/utils/format.dart';
import 'package:polka_wallet/utils/i18n/index.dart';

class ValidatorDetail extends StatelessWidget {
  ValidatorDetail(this.store);
  final AppStore store;

  Widget _buildAccInfo(Map accInfo) {
    List<Widget> ls = List<Widget>.from(accInfo['identity'].keys.map((k) {
      if (k == 'judgements') {
        return Container();
      }
      return Row(
        children: <Widget>[
          Container(
            width: 80,
            child: Text(k),
          ),
          Text(accInfo['identity'][k]),
        ],
      );
    }));
    return accInfo == null
        ? Container()
        : Container(
            padding: EdgeInsets.only(left: 24, right: 24),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start, children: ls),
          );
  }

  @override
  Widget build(BuildContext context) => Observer(
        builder: (_) {
          var dic = I18n.of(context).staking;
          final ValidatorData detail =
              ModalRoute.of(context).settings.arguments;

          Map accInfo = store.account.accountIndexMap[detail.accountId];

          Map rewardsChartData =
              store.staking.rewardsChartDataCache[detail.accountId];
          List<List<num>> rewardsList = [[], [], []];
          List<String> rewardsLabels = [];
          List<List<num>> blocksList = [[], []];
          List<String> blocksLabels = [];
          if (rewardsChartData != null) {
            rewardsList = List<List<num>>.from(rewardsChartData['rewards']);
            rewardsLabels =
                List<String>.from(rewardsChartData['rewardsLabels']);

            blocksList = List<List<num>>.from(rewardsChartData['blocksList']);
            blocksLabels = List<String>.from(rewardsChartData['blocksLabels']);
          }

          Map stakesChartData =
              store.staking.stakesChartDataCache[detail.accountId];
          List<List<num>> stakesList = [];
          List<String> stakesLabels = [];
          if (stakesChartData != null) {
            stakesList.add(List<num>.from(stakesChartData['stakeChart'][0]));
            List<String>.from(stakesChartData['stakeLabels'])
                .asMap()
                .forEach((k, v) {
              if ((k + 2) % 5 == 0) {
                stakesLabels.add(v);
              } else {
                stakesLabels.add('');
              }
            });
          }

          return Scaffold(
            appBar: AppBar(
              title: Text(dic['validator']),
              centerTitle: true,
            ),
            body: ListView(
              children: <Widget>[
                RoundedCard(
                  margin: EdgeInsets.all(16),
                  child: Column(
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.only(top: 16, bottom: 8),
                        child: Image.asset(
                            'assets/images/assets/Assets_nav_0.png'),
                      ),
                      accInfo != null
                          ? Text(accInfo['accountIndex'])
                          : Container(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Text(Fmt.address(detail.accountId)),
                          IconButton(
                            icon: Image.asset('assets/images/public/copy.png'),
                            onPressed: () =>
                                UI.copyAndNotify(context, detail.accountId),
                          )
                        ],
                      ),
                      _buildAccInfo(accInfo),
                      Divider(),
                      Padding(
                        padding: EdgeInsets.only(top: 16, left: 24),
                        child: Row(
                          children: <Widget>[
                            InfoItem(
                              title: dic['stake.own'],
                              content: Fmt.token(detail.bondOwn),
                            ),
                            InfoItem(
                              title: dic['stake.other'],
                              content: Fmt.token(detail.bondOther),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(top: 16, left: 24, bottom: 24),
                        child: Row(
                          children: <Widget>[
                            InfoItem(
                              title: dic['commission'],
                              content: detail.commission,
                            ),
                            InfoItem(
                              title: 'points',
                              content: detail.points.toString(),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  color: Theme.of(context).cardColor,
                  child: Column(
                    children: <Widget>[
                      // blocks labels & chart
                      Padding(
                        padding: EdgeInsets.only(left: 16, top: 16),
                        child: Column(
                          children: <Widget>[
                            ChartLabel(
                              name: 'Blocks produced',
                              color: Colors.yellow,
                            ),
                            ChartLabel(
                              name: 'Average',
                              color: Colors.grey,
                            ),
                          ],
                        ),
                      ),
                      Container(
                        height: 240,
                        padding: EdgeInsets.all(8),
                        margin: EdgeInsets.only(bottom: 16),
                        child: rewardsChartData == null
                            ? CupertinoActivityIndicator()
                            : BlocksChart.withData(blocksList, blocksLabels),
                      ),
                      // Rewards labels & chart
                      Divider(),
                      Padding(
                        padding: EdgeInsets.only(left: 16, top: 8),
                        child: Column(
                          children: <Widget>[
                            ChartLabel(
                              name: 'Rewards',
                              color: Colors.blue,
                            ),
                            ChartLabel(
                              name: 'Slashes',
                              color: Colors.red,
                            ),
                            ChartLabel(
                              name: 'Average',
                              color: Colors.grey,
                            ),
                          ],
                        ),
                      ),
                      Container(
                        height: 240,
                        padding: EdgeInsets.all(8),
                        margin: EdgeInsets.only(bottom: 16),
                        child: rewardsChartData == null
                            ? CupertinoActivityIndicator()
                            : RewardsChart.withData(rewardsList, rewardsLabels),
                      ),
                      // Stakes labels & chart
                      Divider(),
                      Padding(
                        padding: EdgeInsets.only(left: 16, top: 8),
                        child: Column(
                          children: <Widget>[
                            ChartLabel(
                              name: 'Elected Stake',
                              color: Colors.yellow,
                            ),
                          ],
                        ),
                      ),
                      Container(
                        height: 240,
                        padding: EdgeInsets.all(8),
                        margin: EdgeInsets.only(bottom: 16),
                        child: stakesChartData == null
                            ? CupertinoActivityIndicator()
                            : StakesChart.withData(stakesList, stakesLabels),
                      ),
                      // Stakes labels & chart
                      Divider(),
                      Padding(
                        padding: EdgeInsets.only(left: 16, top: 8),
                        child: Column(
                          children: <Widget>[
                            ChartLabel(
                              name: 'Staker Percentages (%)',
                              color: Colors.yellow,
                            ),
                          ],
                        ),
                      ),
                      Container(
                        height: 520,
                        padding: EdgeInsets.all(8),
                        margin: EdgeInsets.only(bottom: 16),
                        child: stakesChartData == null
                            ? CupertinoActivityIndicator()
                            : SplitChart.withData(
                                List<Map<String, dynamic>>.from(
                                    stakesChartData['splitChart'])),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      );
}
