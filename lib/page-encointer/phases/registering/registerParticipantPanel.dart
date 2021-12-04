import 'dart:convert';

import 'package:encointer_wallet/common/components/roundedButton.dart';
import 'package:encointer_wallet/page/account/txConfirmPage.dart';
import 'package:encointer_wallet/service/substrateApi/api.dart';
import 'package:encointer_wallet/store/app.dart';
import 'package:encointer_wallet/store/encointer/types/proofOfAttendance.dart';
import 'package:encointer_wallet/utils/i18n/index.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:intl/intl.dart';

class RegisterParticipantPanel extends StatefulWidget {
  RegisterParticipantPanel(this.store);

  static const String route = '/encointer/registerParticipantPanel';
  final AppStore store;

  @override
  _RegisterParticipantPanel createState() => _RegisterParticipantPanel(store);
}

class _RegisterParticipantPanel extends State<RegisterParticipantPanel> {
  _RegisterParticipantPanel(this.store);

  final AppStore store;

  bool attendedLastMeetup = false;
  Future<ProofOfAttendance> proof;

  @override
  void initState() {
    webApi.encointer.getParticipantIndex();
    super.initState();
  }

  Future<void> _submit() async {
    ProofOfAttendance p;
    if (attendedLastMeetup) {
      p = await proof;
    }

    var args = {
      "title": 'register_participant',
      "txInfo": {
        "module": 'encointerCeremonies',
        "call": 'registerParticipant',
        "cid": store.encointer.chosenCid,
      },
      "detail": jsonEncode({
        "cid": store.encointer.chosenCid,
        "proof": p ?? {},
      }),
      "params": [
        store.encointer.chosenCid,
        p,
      ],
      'onFinish': (BuildContext txPageContext, Map res) {
        webApi.encointer.getParticipantIndex();
        Navigator.popUntil(txPageContext, ModalRoute.withName('/'));
      }
    };
    Navigator.of(context).pushNamed(TxConfirmPage.route, arguments: args);
  }

  @override
  Widget build(BuildContext context) {
    // only build dropdown after we have fetched the community identifiers
    Map dic = I18n.of(context).encointer;

    return Observer(
      builder: (_) => Column(
        children: <Widget>[
          store.encointer.meetupTime == null
              ? Container()
              : Column(
                  children: <Widget>[
                    Text(dic["ceremony.next"]),
                    Text(DateFormat('yyyy-MM-dd')
                        .format(new DateTime.fromMillisecondsSinceEpoch(store.encointer.meetupTime)))
                  ],
                ),
          CheckboxListTile(
            title: Text(dic["meetup.attended"]),
            onChanged: (bool value) {
              if (value && proof == null) {
                proof = webApi.encointer.getProofOfAttendance();
              }
              setState(() {
                attendedLastMeetup = value;
              });
            },
            value: attendedLastMeetup,
          ),
          store.encointer.participantIndex == null
              ? CupertinoActivityIndicator()
              : store.encointer.participantIndex == 0
                  ? RoundedButton(text: dic["register.participant"], onPressed: () => _submit())
                  : RoundedButton(text: dic["registered"], onPressed: null, color: Theme.of(context).disabledColor),
        ],
      ),
    );
  }
}
