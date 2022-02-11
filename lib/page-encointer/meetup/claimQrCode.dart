import 'dart:convert';
import 'dart:typed_data';

import 'package:encointer_wallet/common/components/addressIcon.dart';
import 'package:encointer_wallet/store/app.dart';
import 'package:encointer_wallet/utils/translations/index.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:encointer_wallet/utils/translations/translations.dart';

import 'scanClaimQrCode.dart';

class ClaimQrCode extends StatelessWidget {
  ClaimQrCode(
    this.store, {
    @required this.title,
    @required this.claim,
    @required this.confirmedParticipantsCount,
  });

  final AppStore store;

  final String title;

  /// future of a scale-encoded `ClaimOfAttendance`
  final Future<Uint8List> claim;
  final int confirmedParticipantsCount;

  @override
  Widget build(BuildContext context) {
    final Translations dic = I18n.of(context).translationsForLocale();
    final Color themeColor = Theme.of(context).primaryColor;

    return Scaffold(
      backgroundColor: Colors.grey,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text(""),
        centerTitle: true,
      ),
      body: SafeArea(
        child: ListView(
          children: <Widget>[
            Stack(
              alignment: AlignmentDirectional.topCenter,
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(top: 32),
                  child: Image.asset('assets/images/assets/receive_line_indigo.png'),
                ),
                Container(
                  margin: EdgeInsets.only(top: 40, left: 0, right: 0),
                  padding: EdgeInsets.only(left: 0, right: 0),
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.all(const Radius.circular(4)),
                    color: Colors.white,
                  ),
                  child: Column(
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.all(16),
                        child: AddressIcon(
                          '',
                          pubKey: store.account.currentAccount.pubKey,
                        ),
                      ),
                      Text(
                        title,
                        style: Theme.of(context).textTheme.headline4,
                      ),
                      Container(width: 8, height: 8),
                      Container(
                        width: 395,
                        height: 395,
                        decoration: BoxDecoration(
                          border: Border.all(width: 4, color: themeColor),
                          borderRadius: BorderRadius.all(const Radius.circular(8)),
                        ),
                        child: FutureBuilder<Uint8List>(
                          future: claim,
                          builder: (_, AsyncSnapshot<Uint8List> snapshot) {
                            if (snapshot.hasData) {
                              return QrImage(
                                data: base64.encode(snapshot.data),
                                errorCorrectionLevel: QrErrorCorrectLevel.L,
                              );
                            } else {
                              return CupertinoActivityIndicator();
                            }
                          },
                        ),
                      ),
                      ButtonBar(children: <Widget>[
                        Container(
                          padding: EdgeInsets.only(top: 16, bottom: 16),
                          child: ElevatedButton(
                            child: Text(dic.assets.done),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.only(top: 16, bottom: 16),
                          child: TextButton(
                            child: Row(
                              children: [
                                Text(dic.assets.scan),
                                SizedBox(width: 4),
                                Image.asset(
                                  'assets/images/assets/qrcode_indigo.png',
                                  width: 24,
                                ),
                              ],
                            ),
                            onPressed: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (BuildContext context) => ScanClaimQrCode(store, confirmedParticipantsCount),
                                ),
                              );
                            },
                          ),
                        ),
                      ])
                    ],
                  ),
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}
