import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:polka_wallet/common/components/addressIcon.dart';
import 'package:polka_wallet/common/components/listTail.dart';
import 'package:polka_wallet/common/components/roundedCard.dart';
import 'package:polka_wallet/page/governance/treasury/tipDetailPage.dart';
import 'package:polka_wallet/service/substrateApi/api.dart';
import 'package:polka_wallet/store/app.dart';
import 'package:polka_wallet/store/gov/types/treasuryTipData.dart';
import 'package:polka_wallet/utils/UI.dart';
import 'package:polka_wallet/utils/format.dart';
import 'package:polka_wallet/utils/i18n/index.dart';

class MoneyTips extends StatefulWidget {
  MoneyTips(this.store);

  final AppStore store;

  @override
  _ProposalsState createState() => _ProposalsState();
}

class _ProposalsState extends State<MoneyTips> {
  Future<void> _fetchData() async {
    webApi.gov.updateBestNumber();
    await webApi.gov.fetchTreasuryTips();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      globalTipsRefreshKey.currentState?.show();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Observer(
      builder: (BuildContext context) {
        List<TreasuryTipData> tips = [];
        if (widget.store.gov.treasuryTips != null) {
          tips.addAll(widget.store.gov.treasuryTips.reversed);
        }
        return RefreshIndicator(
          key: globalTipsRefreshKey,
          onRefresh: _fetchData,
          child: tips.length == 0
              ? Center(
                  child: ListTail(
                  isEmpty: true,
                  isLoading: false,
                ))
              : ListView.builder(
                  padding: EdgeInsets.only(bottom: 32),
                  itemCount: tips.length + 1,
                  itemBuilder: (_, int i) {
                    if (tips.length == i) {
                      return ListTail(
                        isEmpty: false,
                        isLoading: false,
                      );
                    }
                    final TreasuryTipData tip = tips[i];
                    final Map accInfo =
                        widget.store.account.addressIndexMap[tip.who];
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
