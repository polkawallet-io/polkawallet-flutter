import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:polka_wallet/common/components/addressIcon.dart';
import 'package:polka_wallet/common/components/roundedCard.dart';
import 'package:polka_wallet/page/governance/treasury/tipDetailPage.dart';
import 'package:polka_wallet/service/substrateApi/api.dart';
import 'package:polka_wallet/store/app.dart';
import 'package:polka_wallet/store/gov/types/treasuryTipData.dart';
import 'package:polka_wallet/utils/format.dart';
import 'package:polka_wallet/utils/i18n/index.dart';

class MoneyTips extends StatefulWidget {
  MoneyTips(this.store);

  final AppStore store;

  @override
  _ProposalsState createState() => _ProposalsState();
}

class _ProposalsState extends State<MoneyTips> {
  final GlobalKey<RefreshIndicatorState> _refreshKey =
      new GlobalKey<RefreshIndicatorState>();

  Future<void> _fetchData() async {
    webApi.gov.updateBestNumber();
    await webApi.gov.fetchTreasuryTips();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refreshKey.currentState?.show();
    });
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Observer(
      builder: (BuildContext context) {
        return RefreshIndicator(
          key: _refreshKey,
          onRefresh: _fetchData,
          child: widget.store.gov.treasuryTips == null
              ? CupertinoActivityIndicator()
              : ListView.builder(
                  padding: EdgeInsets.only(bottom: 32),
                  itemCount: widget.store.gov.treasuryTips.length,
                  itemBuilder: (_, int i) {
                    final TreasuryTipData tip =
                        widget.store.gov.treasuryTips[i];
                    final Map accInfo =
                        widget.store.account.accountIndexMap[tip.who];
                    return RoundedCard(
                      margin: EdgeInsets.fromLTRB(16, 16, 16, 0),
                      padding: EdgeInsets.only(top: 16, bottom: 16),
                      child: ListTile(
                        leading: AddressIcon(tip.who),
                        title: Fmt.accountDisplayName(tip.who, accInfo),
                        subtitle: Text(tip.reason),
                        trailing: Column(
                          children: <Widget>[
                            Text(
                              tip.tips.length.toString(),
                              style: Theme.of(context).textTheme.headline4,
                            ),
                            Text(I18n.of(context).gov['treasury.tipper'])
                          ],
                        ),
                        onTap: () {
                          Navigator.of(context).pushNamed(
                            TipDetailPage.route,
                            arguments: tip,
                          );
                        },
                      ),
                    );
                  },
                ),
        );
      },
    );
  }
}
