import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:polka_wallet/service/substrateApi/api.dart';
import 'package:polka_wallet/common/components/BorderedTitle.dart';
import 'package:polka_wallet/common/components/addressIcon.dart';
import 'package:polka_wallet/common/components/roundedButton.dart';
import 'package:polka_wallet/common/components/roundedCard.dart';
import 'package:polka_wallet/page/staking/actions.dart';
import 'package:polka_wallet/store/app.dart';
import 'package:polka_wallet/utils/UI.dart';
import 'package:polka_wallet/utils/format.dart';
import 'package:polka_wallet/utils/i18n/index.dart';

class Council extends StatefulWidget {
  Council(this.store);
  final AppStore store;

  @override
  State<StatefulWidget> createState() => _CouncilState(store);
}

class _CouncilState extends State<Council> {
  _CouncilState(this.store);

  final AppStore store;

  Future<void> _fetchCouncilInfo() async {
    if (store.settings.loading) {
      return;
    }
    await webApi.gov.fetchCouncilInfo();
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (store.gov.council == null) {
        globalCouncilRefreshKey.currentState.show();
      }
    });
  }

  Widget _buildTopCard() {
    final Map dic = I18n.of(context).gov;
    return RoundedCard(
      margin: EdgeInsets.fromLTRB(16, 12, 16, 24),
      padding: EdgeInsets.all(24),
      child: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              InfoItem(
                crossAxisAlignment: CrossAxisAlignment.center,
                title: dic['seats'],
                content:
                    '${store.gov.council.members.length}/${store.gov.council.desiredSeats}',
              ),
              InfoItem(
                crossAxisAlignment: CrossAxisAlignment.center,
                title: dic['up'],
                content: store.gov.council.runnersUp.length.toString(),
              ),
              InfoItem(
                crossAxisAlignment: CrossAxisAlignment.center,
                title: dic['candidate'],
                content: store.gov.council.candidates.length.toString(),
              )
            ],
          ),
          Divider(height: 40),
          RoundedButton(
            text: dic['vote'],
            onPressed: () => Navigator.of(context).pushNamed('/gov/vote'),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final Map dic = I18n.of(context).gov;
    return Observer(builder: (_) {
      return RefreshIndicator(
        key: globalCouncilRefreshKey,
        onRefresh: _fetchCouncilInfo,
        child: store.gov.council == null
            ? Container()
            : ListView(
                children: <Widget>[
                  _buildTopCard(),
                  Container(
                    padding: EdgeInsets.only(top: 16, left: 16, bottom: 8),
                    color: Theme.of(context).cardColor,
                    child: BorderedTitle(
                      title: dic['member'],
                    ),
                  ),
                  Container(
                    color: Theme.of(context).cardColor,
                    child: Column(
                      children: store.gov.council.members.map((i) {
                        Map accInfo = store.account.accountIndexMap[i[0]];
                        return CandidateItem(
                          accInfo: accInfo,
                          balance: i,
                          tokenSymbol: store.settings.networkState.tokenSymbol,
                        );
                      }).toList(),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.only(top: 16, left: 16, bottom: 8),
                    color: Theme.of(context).cardColor,
                    child: BorderedTitle(
                      title: dic['up'],
                    ),
                  ),
                  Container(
                    color: Theme.of(context).cardColor,
                    child: Column(
                      children: store.gov.council.runnersUp.map((i) {
                        Map accInfo = store.account.accountIndexMap[i[0]];
                        return CandidateItem(
                          accInfo: accInfo,
                          balance: i,
                          tokenSymbol: store.settings.networkState.tokenSymbol,
                        );
                      }).toList(),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.only(top: 16, left: 16, bottom: 8),
                    color: Theme.of(context).cardColor,
                    child: BorderedTitle(
                      title: dic['candidate'],
                    ),
                  ),
                  Container(
                    color: Theme.of(context).cardColor,
                    child: Column(
                      children: store.gov.council.candidates.map((i) {
                        Map accInfo = store.account.accountIndexMap[i];
                        return CandidateItem(
                          accInfo: accInfo,
                          balance: [i],
                          tokenSymbol: store.settings.networkState.tokenSymbol,
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
      );
    });
  }
}

class CandidateItem extends StatelessWidget {
  CandidateItem(
      {this.accInfo,
      this.balance,
      this.tokenSymbol,
      this.switchValue,
      this.onSwitch});
  final Map accInfo;
  // balance == [<candidate_address>, <0x_candidate_backing_amount>]
  final List<String> balance;
  final String tokenSymbol;
  final bool switchValue;
  final Function(bool) onSwitch;
  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: AddressIcon(address: balance[0]),
      title: Text(accInfo != null
          ? accInfo['identity']['display'] != null
              ? accInfo['identity']['display'].toString().toUpperCase()
              : accInfo['accountIndex']
          : Fmt.address(balance[0], pad: 6)),
      subtitle: balance.length == 1
          ? null
          : Text(
              '${I18n.of(context).gov['backing']}: ${Fmt.token(int.parse(balance[1]))} $tokenSymbol'),
      onTap: () => Navigator.of(context).pushNamed('/gov/candidate',
          arguments: balance.length == 1 ? [balance[0], '0x0'] : balance),
      trailing: onSwitch == null
          ? Container(width: 8)
          : CupertinoSwitch(
              value: switchValue,
              onChanged: onSwitch,
            ),
    );
  }
}
