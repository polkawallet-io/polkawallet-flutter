import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:polka_wallet/common/consts/settings.dart';
import 'package:polka_wallet/page-encointer/common/assignmentPanel.dart';
import 'package:polka_wallet/store/app.dart';
import 'package:polka_wallet/utils/i18n/index.dart';

class AssigningPage extends StatefulWidget {
  AssigningPage(this.store);

  static const String route = '/encointer/assigning';
  final AppStore store;

  @override
  _AssigningPageState createState() => _AssigningPageState(store);
}

class _AssigningPageState extends State<AssigningPage> {
  _AssigningPageState(this.store);

  final AppStore store;

  String _tab = 'DOT';

  @override
  void initState() {
    _refreshData();
    // TODO: remove once we're doing this in init of attesting
    this.store.encointer.purgeAttestations();
    super.initState();
  }

  Future<void> _refreshData() async {
    // refreshed by parent!
    // await webApi.encointer.fetchParticipantIndex();
    // await webApi.encointer.fetchParticipantCount();
    // await webApi.encointer.fetchMeetupIndex();
    //await webApi.encointer.fetchNextMeetupTime();
    //await webApi.encointer.fetchNextMeetupLocation();
  }

  @override
  Widget build(BuildContext context) {
    final Map dic = I18n.of(context).encointer;
    final int decimals = encointerTokenDecimals;
    return SafeArea(
      child: Column(children: <Widget>[
        AssignmentPanel(store),
      ]),
    );
  }
}
