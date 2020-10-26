import 'package:encointer_wallet/page-encointer/common/currencyChooserPanel.dart';
import 'package:encointer_wallet/page-encointer/phases/assigning/assigningPage.dart';
import 'package:encointer_wallet/page-encointer/phases/attesting/attestingPage.dart';
import 'package:encointer_wallet/page-encointer/phases/registering/registeringPage.dart';
import 'package:encointer_wallet/store/app.dart';
import 'package:encointer_wallet/store/encointer/types/encointerTypes.dart';
import 'package:encointer_wallet/utils/i18n/index.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';

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

class _PhaseAwareBoxState extends State<PhaseAwareBox> with SingleTickerProviderStateMixin {
  _PhaseAwareBoxState(this.store);

  final AppStore store;

  TabController _tabController;
  int _txsPage = 0;
  bool _isLastPage = false;
  ScrollController _scrollController;

  Future<void> _refreshData() async {
    setState(() {
      _txsPage = 0;
      _isLastPage = false;
    });
  }

  @override
  void dispose() {
    //print("stopping subscriptions");
    //webApi.encointer.stopSubscriptions();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Observer(
      builder: (_) => Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            (store.encointer.currentPhase != null)
                ? Column(mainAxisSize: MainAxisSize.max, children: <Widget>[
                    CurrencyChooserPanel(store),
                    //CeremonyOverviewPanel(store),
                    SizedBox(
                      height: 16,
                    ),
                    Observer(builder: (_) => _getPhaseView(store.encointer.currentPhase))
                  ])
                : CupertinoActivityIndicator()
          ],
        ),
      ),
    );
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
