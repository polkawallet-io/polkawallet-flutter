import 'package:encointer_wallet/page-encointer/common/communityChooserPanel.dart';
import 'package:encointer_wallet/page-encointer/phases/assigning/assigningPage.dart';
import 'package:encointer_wallet/page-encointer/phases/attesting/attestingPage.dart';
import 'package:encointer_wallet/page-encointer/phases/registering/registeringPage.dart';
import 'package:encointer_wallet/service/substrateApi/api.dart';
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
                    dic['encointer'],
                    style: TextStyle(
                      fontSize: 20,
                      color: Theme.of(context).cardColor,
                      fontWeight: FontWeight.w500,
                    ),
                  )
                ],
              ),
            ),
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
  bool appConnected = false;

  @override
  void initState() {
    _checkConnectionState();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  _checkConnectionState() async {
    appConnected = await webApi.isConnected();

    setState(() {});
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
                    CommunityChooserPanel(store),
                    //CeremonyOverviewPanel(store),
                    SizedBox(
                      height: 16,
                    ),
                    appConnected
                        ? Observer(builder: (_) => _getPhaseView(store.encointer.currentPhase))
                        : _getPhaseViewOffline(),
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
      default:
        return RegisteringPage(store);
    }
  }

  Widget _getPhaseViewOffline() {
    if (store.encointer.meetupIndex == null || store.encointer.meetupIndex == 0) {
      return RegisteringPage(store);
    } else {
      int timeToMeetup = store.encointer.getTimeToMeetup();
      if (0 < timeToMeetup && timeToMeetup < 10 * 60) {
        return AssigningPage(store);
      } else {
        return AttestingPage(store);
      }
    }
  }
}
