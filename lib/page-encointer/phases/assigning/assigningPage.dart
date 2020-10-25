import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:polka_wallet/page-encointer/common/assignmentPanel.dart';
import 'package:polka_wallet/store/app.dart';

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
    // TODO: remove once we're doing this in init of attesting
    this.store.encointer.purgeAttestations();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(children: <Widget>[
        AssignmentPanel(store),
      ]),
    );
  }
}
