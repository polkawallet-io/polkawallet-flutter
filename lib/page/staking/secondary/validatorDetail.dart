import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:polka_wallet/page/staking/overview.dart';
import 'package:polka_wallet/store/app.dart';
import 'package:polka_wallet/store/staking.dart';
import 'package:polka_wallet/utils/UI.dart';
import 'package:polka_wallet/utils/format.dart';
import 'package:polka_wallet/utils/i18n/index.dart';

class ValidatorDetail extends StatelessWidget {
  ValidatorDetail(this.store);
  final AppStore store;
  @override
  Widget build(BuildContext context) {
    var dic = I18n.of(context).staking;
    final ValidatorData detail = ModalRoute.of(context).settings.arguments;
    Widget buildLabel(String name) {
      return Container(
          padding: EdgeInsets.only(left: 8),
          width: 80,
          child: Text(name, style: Theme.of(context).textTheme.display4));
    }

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
                  child: Image.asset('assets/images/assets/Assets_nav_0.png'),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(Fmt.address(detail.accountId)),
                    IconButton(
                      icon: Image.asset('assets/images/public/copy.png'),
                      onPressed: () => UI.copyAndNotify(context, '0xksjfo...'),
                    )
                  ],
                ),
                Divider(),
                Padding(
                  padding: EdgeInsets.only(top: 16, left: 24),
                  child: Row(
                    children: <Widget>[
                      InfoItem(
                        title: dic['total'],
                        content: Fmt.token(detail.total),
                      ),
                      InfoItem(
                        title: dic['commission'],
                        content: detail.commission,
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 16, left: 24, bottom: 24),
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
                )
              ],
            ),
          ),
          Container(
            child: Text('chart1'),
          ),
          Container(
            child: Text('chart2'),
          ),
        ],
      ),
    );
  }
}
