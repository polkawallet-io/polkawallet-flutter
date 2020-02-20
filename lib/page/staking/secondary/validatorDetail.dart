import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:polka_wallet/page/staking/overview.dart';
import 'package:polka_wallet/page/staking/secondary/rewardsChart.dart';
import 'package:polka_wallet/store/app.dart';
import 'package:polka_wallet/store/staking.dart';
import 'package:polka_wallet/utils/UI.dart';
import 'package:polka_wallet/utils/format.dart';
import 'package:polka_wallet/utils/i18n/index.dart';

class ValidatorDetail extends StatelessWidget {
  ValidatorDetail(this.store);
  final AppStore store;
  @override
  Widget build(BuildContext context) => Observer(
        builder: (_) {
          var dic = I18n.of(context).staking;
          final ValidatorData detail =
              ModalRoute.of(context).settings.arguments;
          print(store.staking.chartDataCache.keys.join(','));

          List validators = store.staking.overview['currentElected'];
          int points = store.staking.overview['eraPoints']['individual']
              [validators.indexOf(detail.accountId)];

          final myFakeDesktopData = [
            {'label': 0, 'value': 1.005},
            {'label': 1, 'value': 0.005},
            {'label': 2, 'value': 1.005},
            {'label': 3, 'value': 2.005},
          ];
          final labels = ['123', '23', 'dfg', '345'];

          return Scaffold(
            appBar: AppBar(
              title: Text(dic['validator']),
              centerTitle: true,
            ),
            body: ListView(
              children: <Widget>[
                Card(
                  margin: EdgeInsets.all(16),
                  child: Column(
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.only(top: 16, bottom: 8),
                        child: Image.asset(
                            'assets/images/assets/Assets_nav_0.png'),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Text(Fmt.address(detail.accountId)),
                          IconButton(
                            icon: Image.asset('assets/images/public/copy.png'),
                            onPressed: () =>
                                UI.copyAndNotify(context, '0xksjfo...'),
                          )
                        ],
                      ),
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
                              content: points.toString(),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
// TODO: some issues with chart data fetching
//                Container(
//                  height: 240,
//                  child: RewardsChart.withData(myFakeDesktopData, labels),
//                ),
              ],
            ),
          );
        },
      );
}
