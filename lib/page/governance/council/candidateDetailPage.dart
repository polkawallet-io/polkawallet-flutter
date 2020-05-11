import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:polka_wallet/common/components/accountInfo.dart';
import 'package:polka_wallet/common/components/roundedCard.dart';
import 'package:polka_wallet/store/app.dart';
import 'package:polka_wallet/utils/format.dart';
import 'package:polka_wallet/utils/i18n/index.dart';

class CandidateDetailPage extends StatelessWidget {
  CandidateDetailPage(this.store);
  static final String route = '/gov/candidate';
  final AppStore store;

  @override
  Widget build(BuildContext context) {
    final Map dic = I18n.of(context).gov;
    final List info = ModalRoute.of(context).settings.arguments;
    String symbol = store.settings.networkState.tokenSymbol;

    Map accInfo = store.account.accountIndexMap[info[0]];
    TextStyle style = Theme.of(context).textTheme.display4;
    return Scaffold(
      appBar: AppBar(
          title: Text(I18n.of(context).home['detail']), centerTitle: true),
      body: SafeArea(
        child: ListView(
          children: <Widget>[
            RoundedCard(
              margin: EdgeInsets.all(16),
              padding: EdgeInsets.only(bottom: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  AccountInfo(accInfo: accInfo, address: info[0]),
                  Divider(),
                  Padding(
                    padding: EdgeInsets.only(top: 8, bottom: 8),
                    child: Text('${Fmt.token(BigInt.parse(info[1]))} $symbol',
                        style: style),
                  ),
                  Text(dic['backing'])
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
