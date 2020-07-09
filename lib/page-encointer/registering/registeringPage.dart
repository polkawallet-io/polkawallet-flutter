import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:polka_wallet/common/components/infoItem.dart';
import 'package:polka_wallet/common/components/roundedButton.dart';
import 'package:polka_wallet/common/components/roundedCard.dart';
import 'package:polka_wallet/common/consts/settings.dart';
import 'package:polka_wallet/page/account/txConfirmPage.dart';
import 'package:polka_wallet/service/substrateApi/api.dart';
import 'package:polka_wallet/store/app.dart';
import 'package:polka_wallet/utils/UI.dart';
import 'package:polka_wallet/utils/format.dart';
import 'package:polka_wallet/utils/i18n/index.dart';
import 'package:polka_wallet/page-encointer/registering/registerParticipantPanel.dart';


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
  void initState() {
    _refresh();
    super.initState();
  }

  Future<void> _refresh() async {
     webApi.encointer.getCurrencyIdentifiers();
     webApi.encointer.getCurrentCeremonyIndex();
     webApi.encointer.getNextMeetupTime();
     webApi.encointer.getParticipantIndex();
  }

  @override
  Widget build(BuildContext context) {
    final Map dic = I18n.of(context).encointer;
    final int decimals = encointer_token_decimals;
    return  SafeArea(
          child: Column(
              children: <Widget>[
                Container(
                  padding: EdgeInsets.fromLTRB(16, 32, 16, 32),
                  child: RegisterParticipantPanel(store),
                ),
              ]
          ),
      );
  }

}


