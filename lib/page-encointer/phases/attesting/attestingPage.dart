import 'package:encointer_wallet/common/components/roundedButton.dart';
import 'package:encointer_wallet/common/components/roundedCard.dart';
import 'package:encointer_wallet/page-encointer/common/assignmentPanel.dart';
import 'package:encointer_wallet/page-encointer/meetup/MeetupPage.dart';
import 'package:encointer_wallet/page-encointer/meetup/confirmAttendeesDialog.dart';
import 'package:encointer_wallet/page/account/txConfirmPage.dart';
import 'package:encointer_wallet/service/substrateApi/api.dart';
import 'package:encointer_wallet/store/app.dart';
import 'package:encointer_wallet/store/encointer/types/attestation.dart';
import 'package:encointer_wallet/store/encointer/types/attestationState.dart';
import 'package:encointer_wallet/utils/i18n/index.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';

class AttestingPage extends StatefulWidget {
  AttestingPage(this.store);

  static const String route = '/encointer/attesting';
  final AppStore store;

  @override
  _AttestingPageState createState() => _AttestingPageState(store);
}

class _AttestingPageState extends State<AttestingPage> {
  _AttestingPageState(this.store);

  final AppStore store;

  Future<void> _startMeetup(BuildContext context) async {
    var amount = await Navigator.of(context).push(MaterialPageRoute(builder: (context) => ConfirmAttendeesDialog()));
    var args = {'confirmedParticipants': amount};
    Navigator.pushNamed(context, MeetupPage.route, arguments: args);
  }

  @override
  Widget build(BuildContext context) {
    Map dic = I18n.of(context).encointer;
    return SafeArea(
      child: Column(children: <Widget>[
        AssignmentPanel(store),
        SizedBox(height: 16),
        Container(
          width: double.infinity,
          child: RoundedCard(
            padding: EdgeInsets.all(8),
            child: Column(children: <Widget>[
              Observer(builder: (_) => _reportAttestationsCount(context, store.encointer.attestations)),
              Observer(
                builder: (_) => ((store.encointer.meetupIndex == null) | (store.encointer.meetupIndex == 0))
                    ? Text(dic['meetup.not.assigned'])
                    : RoundedButton(
                        text: dic['meetup.start'],
                        onPressed: () => _startMeetup(context),
                      ),
              )
            ]),
          ),
        )
      ]),
    );
  }

  Widget _reportAttestationsCount(BuildContext context, Map<int, AttestationState> attestations) {
    Map<String, String> dic = I18n.of(context).encointer;
    var count = attestations
        .map((key, value) => MapEntry(key, value.yourAttestation))
        .values
        .where((x) => x != null)
        .toList()
        .length;
    return Column(children: <Widget>[
      Text(dic['attestation.total'].replaceAll('AMOUNT_PLACEHOLDER', count.toString())),
      count > 0
          ? RoundedButton(
              text: dic['attestation.submit'], onPressed: () => _submit(context) // for testing always allow sending
              )
          : Container()
    ]);
  }

  Future<void> _submit(BuildContext context) async {
    var attestationsHex = store.encointer.attestations
        .map((key, value) => MapEntry(key, value.yourAttestation))
        .values
        .where((x) => x != null)
        .toList();

    List<Attestation> attestations = [];
    for (int i = 0; i < attestationsHex.length; i++) {
      attestations.add(await webApi.encointer.parseAttestation(attestationsHex[i]));
    }

    print("Attestations to be submitted: ");
    attestations.forEach((x) => print(x.toJson()));

    //return;
    var args = {
      "title": 'register_attestations',
      "txInfo": {
        "module": 'encointerCeremonies',
        "call": 'registerAttestations',
        "cid": store.encointer.chosenCid,
      },
      "detail": "submitting ${attestations.length} attestations for the recent ceremony ",
      "params": [attestations],
//      "rawParam": '[[${attestationsHex.join(',')}]]',
//      "rawParam": '[$attestations]',
      'onFinish': (BuildContext txPageContext, Map res) {
        Navigator.popUntil(txPageContext, ModalRoute.withName('/'));
      }
    };
    Navigator.of(context).pushNamed(TxConfirmPage.route, arguments: args);
  }
}
