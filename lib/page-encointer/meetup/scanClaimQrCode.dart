import 'dart:convert';

import 'package:encointer_wallet/service/substrateApi/api.dart';
import 'package:encointer_wallet/service/substrateApi/codecApi.dart';
import 'package:encointer_wallet/store/app.dart';
import 'package:encointer_wallet/store/encointer/types/claimOfAttendance.dart';
import 'package:encointer_wallet/utils/translations/index.dart';
import 'package:encointer_wallet/utils/translations/translations.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_qr_scan/qrcode_reader_view.dart';
import 'package:permission_handler/permission_handler.dart';

class ScanClaimQrCode extends StatelessWidget {
  ScanClaimQrCode(this.store, this.confirmedParticipantsCount);

  final AppStore store;
  final int confirmedParticipantsCount;

  final GlobalKey<QrcodeReaderViewState> _qrViewKey = GlobalKey();

  Future<bool> canOpenCamera() async {
    // will do nothing if already granted
    return Permission.camera.request().isGranted;
  }

  void _showSnackBar(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).removeCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      backgroundColor: Colors.white,
      content: Text(msg, style: TextStyle(color: Colors.black54)),
      duration: Duration(milliseconds: 1500),
    ));
  }

  void validateAndStoreClaim(BuildContext context, ClaimOfAttendance claim, Translations dic) {
    if (!store.encointer.meetupRegistry.contains(claim.claimantPublic)) {
      // this is important because the runtime checks if there are too many claims trying to be registered.
      // Fixme: #374, #390
      // _showSnackBar(context, dic.encointer.meetupClaimantInvalid);
      print(
          "[scanClaimQrCode] Claimant: ${claim.claimantPublic} is not part of registry: ${store.encointer.meetupRegistry}");
    }

    String msg =
        store.encointer.containsClaim(claim) ? dic.encointer.claimsScannedAlready : dic.encointer.claimsScannedNew;

    store.encointer.addParticipantClaim(claim);
    _showSnackBar(context, msg);
  }

  @override
  Widget build(BuildContext context) {
    final Translations dic = I18n.of(context).translationsForLocale();

    Future _onScan(String base64Data, String _rawData) async {
      if (base64Data != null) {
        var data = base64.decode(base64Data);

        // Todo: Not good to use the global webApi here, but I wanted to prevent big changes into the code for now.
        // Fix this when #132 is tackled.
        var claim = await webApi.codec
            .decodeBytes(ClaimOfAttendanceJSRegistryName, data)
            .then((c) => ClaimOfAttendance.fromJson(c))
            .timeout(
          const Duration(seconds: 3),
          onTimeout: () {
            _showSnackBar(context, dic.encointer.claimsScannedDecodeFailed);
            return null;
          },
        );

        if (claim != null) {
          validateAndStoreClaim(context, claim, dic);
        }

        // If we don't wait, scans  of the same qr code are spammed.
        // My fairly recent cellphone gets too much load for duration < 500 ms. We might need to increase
        // this for older phones.
        Future.delayed(const Duration(milliseconds: 1500), () {
          _qrViewKey.currentState.startScan();
        });
      } else {
        _qrViewKey.currentState.startScan();
      }
    }

    return Scaffold(
      body: FutureBuilder<bool>(
        future: canOpenCamera(),
        builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
          if (snapshot.hasData && snapshot.data == true) {
            return QrcodeReaderView(
              key: _qrViewKey,
              helpWidget: Observer(
                  builder: (_) => Text(dic.encointer.claimsScannedNOfM
                      .replaceAll('SCANNED_COUNT', store.encointer.scannedClaimsCount.toString())
                      .replaceAll('TOTAL_COUNT', (confirmedParticipantsCount - 1).toString()))),
              headerWidget: SafeArea(
                  child: Align(
                alignment: Alignment.topRight,
                child: IconButton(
                  icon: Icon(
                    Icons.close,
                    color: Theme.of(context).cardColor,
                  ),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              )),
              onScan: _onScan,
            );
          } else {
            return Container();
          }
        },
      ),
    );
  }
}
