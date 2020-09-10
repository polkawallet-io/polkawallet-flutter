import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:polka_wallet/common/components/entryPageCard.dart';
import 'package:polka_wallet/common/consts/settings.dart';
import 'package:polka_wallet/page/asExtension/dAppWrapperPage.dart';
import 'package:polka_wallet/page/governance/council/councilPage.dart';
import 'package:polka_wallet/page/governance/democracy/democracyPage.dart';
import 'package:polka_wallet/page/governance/treasury/treasuryPage.dart';
import 'package:polka_wallet/store/app.dart';
import 'package:polka_wallet/utils/i18n/index.dart';

class GovEntry extends StatelessWidget {
  GovEntry(this.store);

  final AppStore store;

  @override
  Widget build(BuildContext context) {
    final Map dic = I18n.of(context).gov;
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    I18n.of(context).home['governance'],
                    style: TextStyle(
                      fontSize: 20,
                      color: Theme.of(context).cardColor,
                      fontWeight: FontWeight.w500,
                    ),
                  )
                ],
              ),
            ),
            Expanded(
              child: Observer(
                builder: (_) {
                  final String network =
                      store.settings.endpoint.info == network_name_polkadot
                          ? 'polkadot'
                          : 'kusama';
                  if (store.settings.loading) {
                    return Container(
                      padding: EdgeInsets.only(
                          top: MediaQuery.of(context).size.width / 2),
                      child: Column(
                        children: [
                          CupertinoActivityIndicator(),
                          Text(I18n.of(context).assets['node.connecting']),
                        ],
                      ),
                    );
                  }
                  return ListView(
                    padding: EdgeInsets.all(16),
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.only(bottom: 16),
                        child: GestureDetector(
                          child: EntryPageCard(
                            dic['democracy'],
                            dic['democracy.brief'],
                            Icon(
                              Icons.event_note,
                              color: Colors.white,
                              size: 56,
                            ),
                            color: Theme.of(context).primaryColor,
                          ),
                          onTap: () => Navigator.of(context)
                              .pushNamed(DemocracyPage.route),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(bottom: 16),
                        child: GestureDetector(
                          child: EntryPageCard(
                            dic['council'],
                            dic['council.brief'],
                            Icon(
                              Icons.people_outline,
                              color: Colors.white,
                              size: 56,
                            ),
                            color: Theme.of(context).primaryColor,
                          ),
                          onTap: () => Navigator.of(context)
                              .pushNamed(CouncilPage.route),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(bottom: 16),
                        child: GestureDetector(
                          child: EntryPageCard(
                            dic['treasury'],
                            dic['treasury.brief'],
                            Icon(
                              Icons.account_balance,
                              color: Colors.white,
                              size: 56,
                            ),
                            color: Theme.of(context).primaryColor,
                          ),
                          onTap: () => Navigator.of(context)
                              .pushNamed(TreasuryPage.route),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(bottom: 16),
                        child: GestureDetector(
                          child: EntryPageCard(
                            'Polkassembly',
                            dic['polkassembly'],
                            Image.asset(
                              'assets/images/gov/polkassembly.png',
                              width: 56,
                            ),
                            color: Colors.black87,
                          ),
                          onTap: () => Navigator.of(context).pushNamed(
                              DAppWrapperPage.route,
                              arguments: 'https://$network.polkassembly.io/'),
                        ),
                      ),
                    ],
                  );
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}
