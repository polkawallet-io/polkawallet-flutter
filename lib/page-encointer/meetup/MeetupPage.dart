import 'package:encointer_wallet/common/components/passwordInputDialog.dart';
import 'package:encointer_wallet/common/components/roundedButton.dart';
import 'package:encointer_wallet/service/substrateApi/api.dart';
import 'package:encointer_wallet/store/app.dart';
import 'package:encointer_wallet/store/encointer/types/attestationState.dart';
import 'package:encointer_wallet/utils/format.dart';
import 'package:encointer_wallet/utils/i18n/index.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'attestation/attestationCard.dart';

class MeetupPage extends StatefulWidget {
  MeetupPage(this.store);

  static const String route = '/encointer/meetup/';
  final AppStore store;

  @override
  _MeetupPageState createState() => _MeetupPageState(store);
}

class _MeetupPageState extends State<MeetupPage> {
  _MeetupPageState(this.store);

  final AppStore store;
  var _amountAttendees;
  String pwd;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) async {
        await _showPasswordDialog(context);

        if (pwd == null) {
          await _showPasswordDeniedDialog(context);
          Navigator.of(context).pop();
        }
      },
    );
  }

  Future<void> _showPasswordDialog(BuildContext context) async {
    await showCupertinoDialog(
      context: context,
      builder: (_) {
        return PasswordInputDialog(
          title: Text(I18n.of(context).home['unlock']),
          account: store.account.currentAccount,
          onOk: (password) {
            setState(() {
              pwd = password;
            });
          },
        );
      },
    );
  }

  Future<void> _showPasswordDeniedDialog(BuildContext context) async {
    await showCupertinoDialog(
      context: context,
      builder: (_) {
        return CupertinoAlertDialog(
          title: Text(I18n.of(context).encointer['meetup.pwd.needed']),
          actions: <Widget>[
            CupertinoButton(
              child: Text(
                I18n.of(context).home['ok'],
                style: TextStyle(
                    // color: Theme.of(context).unselectedWidgetColor,
                    ),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  List<Widget> _buildAttestationCardList(String claim) {
    return store.encointer.attestations
        .map((i, _) => MapEntry(
            i,
            AttestationCard(
              store,
              myMeetupRegistryIndex: store.encointer.myMeetupRegistryIndex,
              otherMeetupRegistryIndex: i,
            )))
        .values
        .toList();
  }

  void _initMeetup() async {
    print("creating my claim with vote $_amountAttendees");
    webApi.encointer.createClaimOfAttendance(_amountAttendees);
    var claimHex = await webApi.encointer.encodeClaimOfAttendance();
    if ((store.encointer.attestations == null) || (store.encointer.attestations.isEmpty)) {
      store.encointer.attestations = _buildAttestationStateMap(store.encointer.meetupRegistry);
    }
    setState(() {
      _isLoading = false;
    });
  }

  Map<int, AttestationState> _buildAttestationStateMap(List<dynamic> pubKeys) {
    final map = Map<int, AttestationState>();
    pubKeys.asMap().forEach((i, key) => !(key == store.account.currentAddress)
            ? map.putIfAbsent(i, () => AttestationState(key))
            : store.encointer.myMeetupRegistryIndex =
                i // track our index as it defines if we must show our qr-code first
        );

    print("My index in meetup registry is " + store.encointer.myMeetupRegistryIndex.toString());
    return map;
  }

  @override
  Widget build(BuildContext context) {
    final Map args = ModalRoute.of(context).settings.arguments;
    _amountAttendees = args['confirmedParticipants'];
    if (_isLoading) {
      _initMeetup();
    }
    final Map dic = I18n.of(context).encointer;

    return Scaffold(
      appBar: AppBar(
        title: Text(dic['ceremony']),
        centerTitle: true,
      ),
      backgroundColor: Theme.of(context).canvasColor,
      body: SafeArea(
        child: _isLoading
            ? Center(child: CupertinoActivityIndicator())
            : Column(
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.all(16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text("${dic['myself']}: "),
                        //AddressIcon(store.account.currentAddress, size: 64),
                        Container(
                            margin: const EdgeInsets.all(10.0),
                            padding: const EdgeInsets.all(8.0),
                            //color: Colors.lime,
                            decoration: BoxDecoration(
                                color: Colors.yellow,
                                border: Border.all(
                                  color: Colors.blue,
                                ),
                                borderRadius: BorderRadius.all(Radius.circular(20))),
                            child: Text(store.encointer.myMeetupRegistryIndex
                                .toString()) //AddressIcon(attestation.pubKey, size: 64),
                            ),
                        Text(
                          Fmt.address(store.account.currentAddress),
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        )
                      ],
                    ),
                  ),
                  Expanded(
                    child: ListView(
                      padding: EdgeInsets.only(left: 16, right: 16),
                      children: _buildAttestationCardList(store.encointer.claimHex),
                    ), // Only numbers can be entered
                  ),
                  RoundedButton(
                      text: dic['meetup.complete'],
                      onPressed: () => Navigator.popUntil(context, ModalRoute.withName('/')))
                ],
              ),
      ),
    );
  }
}
