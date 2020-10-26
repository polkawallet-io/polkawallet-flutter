import 'package:encointer_wallet/page-encointer/phases/registering/registerParticipantPanel.dart';
import 'package:encointer_wallet/store/app.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class RegisteringPage extends StatefulWidget {
  RegisteringPage(this.store);

  static const String route = '/encointer/registering';
  final AppStore store;

  @override
  _RegisteringPageState createState() => _RegisteringPageState(store);
}

class _RegisteringPageState extends State<RegisteringPage> {
  _RegisteringPageState(this.store);

  final AppStore store;

  String _tab = 'DOT';

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(children: <Widget>[
        Container(
          padding: EdgeInsets.fromLTRB(16, 32, 16, 32),
          child: RegisterParticipantPanel(store),
        ),
      ]),
    );
  }
}
