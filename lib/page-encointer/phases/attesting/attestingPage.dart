import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:mobx/mobx.dart';
import 'package:polka_wallet/common/components/passwordInputDialog.dart';
import 'package:polka_wallet/common/components/roundedButton.dart';
import 'package:polka_wallet/common/components/roundedCard.dart';
import 'package:polka_wallet/page-encointer/common/assignmentPanel.dart';
import 'package:polka_wallet/page-encointer/meetup/MeetupPage.dart';
import 'package:polka_wallet/page-encointer/meetup/confirmAttendeesDialog.dart';
import 'package:polka_wallet/page/account/txConfirmPage.dart';
import 'package:polka_wallet/service/substrateApi/api.dart';
import 'package:polka_wallet/store/app.dart';
import 'package:polka_wallet/store/encointer/types/attestation.dart';
import 'package:polka_wallet/store/encointer/types/attestationState.dart';
import 'package:polka_wallet/utils/i18n/index.dart';

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

  @observable
  var _amountAttendees;

  @action
  setAmountAttendees(amount) {
    _amountAttendees = amount;
  }

  String _tab = 'DOT';

  @override
  void initState() {
    // check whether the cached attestations are recent
    /*
    //TODO parse attestations and compare cindex. if outdated, purge!
    var cindex = webApi.encointer.fetchCurrentCeremonyIndex();

    if (this.store.encointer.attestations.length > 0 ) {
      Attestation firstatt = this.store.encointer.attestations.map((key, value) => MapEntry(key, value.yourAttestation))
          .values.toList()[0];
      if (
    }
    */
    super.initState();
  }

  Future<void> _startMeetup(BuildContext context) async {
    var amount = await Navigator.of(context).push(MaterialPageRoute(builder: (context) => ConfirmAttendeesDialog()));
    var args = {'confirmedParticipants': amount};
    Navigator.pushNamed(context, MeetupPage.route, arguments: args);
  }

  Future<void> _submitClaim(BuildContext context, String claimHex, String password) async {
    AttestationResult att = await webApi.encointer.attestClaimOfAttendance(claimHex, password);
    print("att: " + att.toString());

//    var args = {
//      "title": 'register_attestations',
//      "txInfo": {
//        "module": 'encointerCeremonies',
//        "call": 'registerAttestations',
//      },
//      "detail": jsonEncode({
//        "attestations": [att],
//      }),
//      "params": [
//        [att], // we usually supply a list of attestations
//      ],
//      'onFinish': (BuildContext txPageContext, Map res) {
//        Navigator.popUntil(txPageContext, ModalRoute.withName('/'));
//      }
//    };
//    Navigator.of(context).pushNamed(TxConfirmPage.route, arguments: args);
  }

  Future<void> _showPasswordDialog(BuildContext context, String claimHex) async {
    showCupertinoDialog(
      context: context,
      builder: (_) {
        return PasswordInputDialog(
          title: Text(I18n.of(context).home['unlock']),
          onOk: (password) => _submitClaim(context, claimHex, password),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Column(children: <Widget>[
      AssignmentPanel(store),
      Container(
          width: double.infinity,
          child: RoundedCard(
            margin: EdgeInsets.fromLTRB(16, 4, 16, 16),
            padding: EdgeInsets.all(8),
            child: Column(children: <Widget>[
              Observer(builder: (_) => _reportAttestationsCount(context, store.encointer.attestations)),
              FutureBuilder<int>(
                  future: webApi.encointer.getMeetupIndex(),
                  builder: (BuildContext context, AsyncSnapshot<int> snapshot) {
                    if (snapshot.hasData) {
                      if (store.encointer.meetupIndex == 0) {
                        return Text("you are not assigned to a meetup");
                      }
                      return RoundedButton(
                          text: "start meetup",
                          onPressed: () => _startMeetup(context) // for testing always allow sending
                          );
                    } else {
                      return CupertinoActivityIndicator();
                    }
                  }),
            ]),
          ))
    ]));
  }

  Widget _reportAttestationsCount(BuildContext context, Map<int, AttestationState> attestations) {
    var count = attestations
        .map((key, value) => MapEntry(key, value.yourAttestation))
        .values
        .where((x) => x != null)
        .toList()
        .length;
    return Column(children: <Widget>[
      Text("you have been attested by " + count.toString() + " others"),
      count > 0
          ? RoundedButton(
              text: "submit attestations", onPressed: () => _submit(context) // for testing always allow sending
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

    List<Attestation> attestations = new List();
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
