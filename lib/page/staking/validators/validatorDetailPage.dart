import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:polka_wallet/common/components/accountInfo.dart';
import 'package:polka_wallet/common/components/chartLabel.dart';
import 'package:polka_wallet/common/components/infoItem.dart';
import 'package:polka_wallet/common/components/roundedCard.dart';
import 'package:polka_wallet/page/staking/validators/rewardsChart.dart';
import 'package:polka_wallet/store/app.dart';
import 'package:polka_wallet/store/staking/types/validatorData.dart';
import 'package:polka_wallet/utils/format.dart';
import 'package:polka_wallet/utils/i18n/index.dart';
import 'package:charts_flutter/flutter.dart' as charts;

class ValidatorDetailPage extends StatelessWidget {
  ValidatorDetailPage(this.store);
  static final String route = '/staking/validator';
  final AppStore store;

  @override
  Widget build(BuildContext context) => Observer(
        builder: (_) {
          var dic = I18n.of(context).staking;
          final int decimals = store.settings.networkState.tokenDecimals;
          final ValidatorData detail =
              ModalRoute.of(context).settings.arguments;

          Map accInfo = store.account.addressIndexMap[detail.accountId];

          Map rewardsChartData =
              store.staking.rewardsChartDataCache[detail.accountId];

          List<ChartLineInfo> pointsChartLines = [
            ChartLineInfo(
                'Era Points', charts.MaterialPalette.yellow.shadeDefault),
            ChartLineInfo('Average', charts.MaterialPalette.gray.shadeDefault),
          ];

          List<ChartLineInfo> rewardChartLines = [
            ChartLineInfo('Slashes', charts.MaterialPalette.red.shadeDefault),
            ChartLineInfo('Rewards', charts.MaterialPalette.blue.shadeDefault),
            ChartLineInfo('Average', charts.MaterialPalette.gray.shadeDefault),
          ];

          List<ChartLineInfo> stakesChartLines = [
            ChartLineInfo(
                'Elected Stake', charts.MaterialPalette.yellow.shadeDefault),
            ChartLineInfo('Average', charts.MaterialPalette.gray.shadeDefault),
          ];

          return Scaffold(
            appBar: AppBar(
              title: Text(dic['validator']),
              centerTitle: true,
            ),
            body: SafeArea(
              child: ListView(
                children: <Widget>[
                  RoundedCard(
                    margin: EdgeInsets.all(16),
                    child: Column(
                      children: <Widget>[
                        AccountInfo(
                            accInfo: accInfo, address: detail.accountId),
                        Divider(),
                        Padding(
                          padding: EdgeInsets.only(top: 16, left: 24),
                          child: Row(
                            children: <Widget>[
                              InfoItem(
                                title: dic['stake.own'],
                                content: Fmt.token(detail.bondOwn, decimals),
                              ),
                              InfoItem(
                                title: dic['stake.other'],
                                content: Fmt.token(detail.bondOther, decimals),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding:
                              EdgeInsets.only(top: 16, left: 24, bottom: 24),
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
                                name: 'Era Points',
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
                              : new RewardsChart.withData(
                                  pointsChartLines,
                                  rewardsChartData['points'][0],
                                  rewardsChartData['points'][1],
                                ),
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
                              : new RewardsChart.withData(
                                  rewardChartLines,
                                  rewardsChartData['rewards'][0],
                                  rewardsChartData['rewards'][1],
                                ),
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
                              : new RewardsChart.withData(
                                  stakesChartLines,
                                  List<List>.from([
                                    rewardsChartData['stakes'][0][1],
                                    rewardsChartData['stakes'][0][2],
                                  ]),
                                  rewardsChartData['stakes'][1],
                                ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
}
