import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:polka_wallet/common/components/BorderedTitle.dart';
import 'package:polka_wallet/common/components/roundedButton.dart';
import 'package:polka_wallet/common/components/roundedCard.dart';
import 'package:polka_wallet/page/staking/actions.dart';
import 'package:polka_wallet/store/app.dart';
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

  bool _isLoading = true;

  Future<void> _fetchCouncilInfo() async {
    setState(() {
      _isLoading = true;
    });
    await store.api.fetchCouncilInfo();
    if (context != null) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void initState() {
    _fetchCouncilInfo();
    super.initState();
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
            onPressed: () => print('vote'),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final Map dic = I18n.of(context).gov;
    return Observer(builder: (_) {
      var accIndexMap = store.account.accountIndexMap;
      return RefreshIndicator(
        onRefresh: _fetchCouncilInfo,
        child: _isLoading
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
                        Map accInfo = accIndexMap[i[0]];
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
                        Map accInfo = accIndexMap[i[0]];
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
                        Map accInfo = accIndexMap[i[0]];
                        return CandidateItem(
                          accInfo: accInfo,
                          balance: i,
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
  CandidateItem({this.accInfo, this.balance, this.tokenSymbol});
  final Map accInfo;
  final List<String> balance;
  final String tokenSymbol;
  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Image.asset('assets/images/assets/Assets_nav_0.png'),
      title: Text(accInfo != null
          ? accInfo['identity']['display'] != null
              ? accInfo['identity']['display'].toString().toUpperCase()
              : accInfo['accountIndex']
          : Fmt.address(balance[0], pad: 6)),
      subtitle: Text(
          '${I18n.of(context).gov['backing']}: ${Fmt.token(int.parse(balance[1]))} $tokenSymbol'),
      onTap: () =>
          Navigator.of(context).pushNamed('/gov/candidate', arguments: balance),
    );
  }
}
