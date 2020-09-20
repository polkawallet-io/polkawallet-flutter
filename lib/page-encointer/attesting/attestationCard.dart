import 'dart:convert';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter/services.dart';
import 'package:polka_wallet/common/components/BorderedTitle.dart';
import 'package:polka_wallet/common/components/addressIcon.dart';
import 'package:polka_wallet/common/components/roundedButton.dart';
import 'package:polka_wallet/common/components/roundedCard.dart';
import 'package:polka_wallet/page-encointer/attesting/qrCode.dart';
import 'package:polka_wallet/page-encointer/attesting/scanQrCode.dart';
import 'package:polka_wallet/page/account/scanPage.dart';
import 'package:polka_wallet/service/substrateApi/api.dart';
import 'package:polka_wallet/service/substrateApi/encointer/apiEncointer.dart';
import 'package:polka_wallet/store/app.dart';
import 'package:polka_wallet/store/encointer/types/attestation.dart';
import 'package:polka_wallet/utils/format.dart';
import 'package:polka_wallet/utils/i18n/index.dart';

class AttestationCard extends StatefulWidget {
  AttestationCard(
    this.store, {
    this.myMeetupRegistryIndex,
    this.otherMeetupRegistryIndex,
    this.claim,
  });

  static const String route = '/encointer/meetup/';
  final AppStore store;

  final int myMeetupRegistryIndex;
  final int otherMeetupRegistryIndex;
  final String claim;

  @override
  _AttestationCardState createState() => _AttestationCardState(store);
}

class _AttestationCardState extends State<AttestationCard> {
  _AttestationCardState(this.store);

  final AppStore store;

  void _scanQrCode(int index) {
    print("scanQrCode clicked at index: " + index.toString());
  }

  @override
  void initState() {
    super.initState();
  }

  _performAttestation() async {
    print("performing attestation");
    if (widget.myMeetupRegistryIndex < widget.otherMeetupRegistryIndex) {
      //show claimA
      print("I'm party A. showing my claim now");
      var args = {"title": 'ClaimA', 'qrCodeData': widget.claim};
      await Navigator.of(context).pushNamed(QrCode.route, arguments: args);

      // scan AttestationA | claimB
      var attestationAClaimB = await Navigator.of(context)
          .pushNamed(ScanQrCode.route, arguments: {'onScan': onScan});
      var attCla = attestationAClaimB.toString().split(':');
      var attestationAhex = attCla[0];
      var claimBhex = attCla[1];
      print("Attestation received by QR code: " + attestationAhex);
      print("Claim received by qrCode:" + claimBhex);
      var claimBjson = await webApi.encointer.parseClaimOfAttendance(claimBhex);
      print("ClaimB parsed: " + claimBjson.toString());
      // TODO: compare claimB to own. only sign valid claims. complain in UI and show differences otherwise

      var attestationAjson = await webApi.encointer.parseAttestation(attestationAhex);
      print("attestationA parsed: " + attestationAjson.toString());
      // TODO: verify signature and complain in UI if bad

      // store AttestationA (my claim, attested by other)
      store.encointer.addAttestation(widget.otherMeetupRegistryIndex, attestationAhex);
      // attest claimB
      Map attestationB =
          await webApi.encointer.attestClaimOfAttendance(claimBhex, "123qwe");
      print("att: " + attestationB['attestation'].toString());
      // currently, parsing attestation fails, as it is returned as an `Attestation` from the js_service which implies the the location is in I32F32
      // store.encointer.attestations[widget.otherMeetupRegistryIndex].otherAttestation = Attestation.fromJson(attestationB['attestation']);
      print("Attestation: " + attestationB.toString());

      // show attestationB
      var args2 = {
        "title": 'AttestationB',
        'qrCodeData': attestationB['attestationHex'].toString(),
      };
      await Navigator.of(context).pushNamed(QrCode.route, arguments: args2);
    } else {
      // scanning claim A
      print("I'm party B. scanning others' claimA now");
      var claimAhex = await Navigator.of(context)
          .pushNamed(ScanQrCode.route, arguments: {'onScan': onScan});
      print("Received ClaimA: " + claimAhex.toString());

      var claimA = await webApi.encointer.parseClaimOfAttendance(claimAhex);
      print("ClaimA parsed: " + claimA.toString());
      // TODO: compare claimA to own. only sign valid claims. complain in UI and show differences otherwise

      // attest claimA
      Map res =
          await webApi.encointer.attestClaimOfAttendance(claimAhex, "123qwe");
      print("att: " + res['attestation'].toString());
      // currently, parsing attestation fails, as it is returned as an `Attestation` from the js_service which implies the the location is in I32F32
//      store.encointer.attestations[widget.otherMeetupRegistryIndex].otherAttestation = Attestation.fromJson(res['attestation']);
      print("Attestation: " + res.toString());

      // show AttestationA | claimB
      var args = {
        "title": 'AttestationA | claimB',
        'qrCodeData': res['attestationHex'].toString() + ":" + widget.claim,
      };
      await Navigator.of(context).pushNamed(QrCode.route, arguments: args);

      // scan AttestationB
      var attB = await Navigator.of(context)
          .pushNamed(ScanQrCode.route, arguments: {'onScan': onScan});
      print("Received AttestastionB: " + attB.toString());

      var attestationB = await webApi.encointer.parseAttestation(attB);
      print("attestationB parsed: " + attestationB.toString());
      // TODO: verify signature and complain in UI if bad

      // store AttestationB (my claim, attested by other)
      store.encointer.addAttestation(widget.otherMeetupRegistryIndex, attB.toString());
    }
  }

  Future<String> onScan(String data) async {
    return data;
  }

  _revertAttestation() {
    print("reverting attestation");
  }

  @override
  Widget build(BuildContext context) {
    final Map dic = I18n.of(context).encointer;

    int otherIndex = widget.otherMeetupRegistryIndex;

    var attestation = store.encointer.attestations[otherIndex];
    print("Attestationcard for " + attestation.pubKey);
    return RoundedCard(
        border: Border.all(color: Theme.of(context).cardColor),
        margin: EdgeInsets.only(bottom: 16),
        child: Observer(
            builder: (_) => Container(
                decoration: store.encointer.attestations[widget.otherMeetupRegistryIndex].done
                    ? BoxDecoration(
                        color: Colors.green,
                        borderRadius: BorderRadius.all(Radius.circular(10)))
                    : BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.all(Radius.circular(10))),
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Container(
                          margin: const EdgeInsets.all(10.0),
                          padding: const EdgeInsets.all(8.0),
                          //color: Colors.lime,
                          decoration: BoxDecoration(
                              color: Colors.yellowAccent,
                              border: Border.all(
                                color: Colors.yellow,
                                width: 4,
                              ),
                              borderRadius:
                                  BorderRadius.all(Radius.circular(20))),
                          child: Text(
                            otherIndex.toString(),
                            style: TextStyle(fontSize: 24),
                          ) //AddressIcon(attestation.pubKey, size: 64),
                          ),
                      Container(
                        child: Text(
                          Fmt.address(attestation.pubKey),
                          style: TextStyle(fontSize: 16),
                        ),
                        //onTap: () => _scanQrCode(otherIndex),
                      ),
                      Container(
                        margin: const EdgeInsets.all(5.0),
                        padding: const EdgeInsets.all(5.0),
                        child: RoundedButton(
                            text: dic['attestation.perform'],
                            onPressed: store.encointer.attestations[widget.otherMeetupRegistryIndex].done
                                ? null
                                : () => _performAttestation()),
                      )
                    ]))));
  }
}
