import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:polka_wallet/common/components/roundedCard.dart';
import 'package:polka_wallet/page-encointer/registering/registeringPage.dart';
import 'package:polka_wallet/page-encointer/assigning/assigningPage.dart';
import 'package:polka_wallet/page-encointer/attesting/attestingPage.dart';
import 'package:polka_wallet/page-encointer/common/CeremonyOverviewPanel.dart';
import 'package:polka_wallet/page-encointer/common/CurrencyChooserPanel.dart';
import 'package:polka_wallet/store/app.dart';
import 'package:polka_wallet/utils/i18n/index.dart';
import 'package:polka_wallet/service/substrateApi/api.dart';
import 'package:polka_wallet/utils/UI.dart';
import 'package:polka_wallet/common/components/roundedButton.dart';
import 'package:polka_wallet/page/account/txConfirmPage.dart';

import 'package:polka_wallet/store/encointer/types/encointerTypes.dart';

class EncointerEntry extends StatelessWidget {
  EncointerEntry(this.store);

  final AppStore store;

  @override
  Widget build(BuildContext context) {
    final Map dic = I18n.of(context).encointer;
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
                    dic['encointer'] ?? 'Encointer Ceremony',
                    style: TextStyle(
                      fontSize: 20,
                      color: Theme.of(context).cardColor,
                      fontWeight: FontWeight.w500,
                    ),
                  )
                ],
              ),
            ),
            //Expanded(
            //    child: Observer(
            //        builder: (_) =>
            //            Text(store.encointer.currentPhase.toString()))),
            PhaseAwareBox(store)
          ],
        ),
      ),
    );
  }
}

class PhaseAwareBox extends StatefulWidget {
  PhaseAwareBox(this.store);

  static final String route = '/encointer/phaseawarebox';

  final AppStore store;

  @override
  _PhaseAwareBoxState createState() => _PhaseAwareBoxState(store);
}

class _PhaseAwareBoxState extends State<PhaseAwareBox>
    with SingleTickerProviderStateMixin {
  _PhaseAwareBoxState(this.store);

  final AppStore store;

  final String _currentPhaseSubscribeChannel = 'currentPhase';
  final String _timeStampSubscribeChannel = 'timestamp';

  TabController _tabController;
  int _txsPage = 0;
  bool _isLastPage = false;
  ScrollController _scrollController;

  Future<void> _updateData() async {
    String pubKey = store.account.currentAccount.pubKey;
    await webApi.assets.fetchBalance(pubKey);
  }

  Future<void> _refreshData() async {
    setState(() {
      _txsPage = 0;
      _isLastPage = false;
    });
    await _updateData();
  }

  @override
  void initState() {
    super.initState();
    // get current phase before we subscribe

    // simply for debug to test that subscriptions are working
    webApi.encointer.subscribeTimestamp(_timeStampSubscribeChannel);

    webApi.encointer.getCurrencyIdentifiers();
    webApi.encointer.getCurrentCeremonyIndex();

    if (!store.settings.loading) {
      print('Subscribing to current phase');
      webApi.encointer.subscribeCurrentPhase(_currentPhaseSubscribeChannel,
          (data) {
        var phase = getEnumFromString(CeremonyPhase.values, data.toUpperCase());
        store.encointer.setCurrentPhase(phase);
      });
    }
  }

  @override
  void dispose() {
    webApi.unsubscribeMessage(_currentPhaseSubscribeChannel);
    webApi.unsubscribeMessage(_timeStampSubscribeChannel);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<CeremonyPhase>(
        future: webApi.encointer.getCurrentPhase(),
        builder: (BuildContext context, AsyncSnapshot<CeremonyPhase> snapshot) {
          if (snapshot.hasData) {
            return Column(mainAxisSize: MainAxisSize.max, children: <Widget>[
              CurrencyChooserPanel(store),
              //CeremonyOverviewPanel(store),
              Observer(
                  builder: (_) => _getPhaseView(store.encointer.currentPhase))
            ]);
          } else {
            return CupertinoActivityIndicator();
          }
        });
  }

  Widget _getPhaseView(CeremonyPhase phase) {
    //return RegisteringPage(store);
    //return AssigningPage(store);
    //return AttestingPage(store);
    switch (phase) {
      case CeremonyPhase.REGISTERING:
        return RegisteringPage(store);
      case CeremonyPhase.ASSIGNING:
        return AssigningPage(store);
      case CeremonyPhase.ATTESTING:
        return AttestingPage(store);
    }
  }
}
