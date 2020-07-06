import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:polka_wallet/common/components/BorderedTitle.dart';
import 'package:polka_wallet/common/components/accountInfo.dart';
import 'package:polka_wallet/common/components/roundedCard.dart';
import 'package:polka_wallet/page/governance/council/council.dart';
import 'package:polka_wallet/service/substrateApi/api.dart';
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
    TextStyle style = Theme.of(context).textTheme.headline4;

    Map voters;
    List voterList = [];
    if (store.gov.councilVotes != null) {
      voters = store.gov.councilVotes[info[0]];
      voterList = voters.keys.toList();
    }
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
            Container(
              padding: EdgeInsets.only(top: 16, left: 16, bottom: 8),
              color: Theme.of(context).cardColor,
              child: BorderedTitle(
                title: dic['vote.voter'],
              ),
            ),
            Container(
              color: Theme.of(context).cardColor,
              child: Column(
                children: voterList.map((i) {
                  Map accInfo = store.account.accountIndexMap[i];
                  return CandidateItem(
                    accInfo: accInfo,
                    balance: [i, voters[i]],
                    tokenSymbol: store.settings.networkState.tokenSymbol,
                    noTap: true,
                  );
                }).toList(),
              ),
            ),
            FutureBuilder(
              future: webApi.account.getAddressIcons(voterList),
              builder: (_, __) => Container(),
            )
          ],
        ),
      ),
    );
  }
}
