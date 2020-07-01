import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:polka_wallet/common/components/roundedButton.dart';
import 'package:polka_wallet/page/account/scanPage.dart';
import 'package:polka_wallet/service/substrateApi/api.dart';
import 'package:polka_wallet/utils/i18n/index.dart';
import 'package:qr_flutter/qr_flutter.dart';

class QrSenderPage extends StatefulWidget {
  static const String route = 'tx/uos/sender';

  @override
  _QrSenderPageState createState() => _QrSenderPageState();
}

class _QrSenderPageState extends State<QrSenderPage> {
  Uint8List _qrPayload;

  Future<Uint8List> _getQrCodeData(BuildContext context) async {
    if (_qrPayload != null) {
      return _qrPayload;
    }

    final Map args = ModalRoute.of(context).settings.arguments;

    Map txInfo = args['txInfo'];
    final Map res = await webApi.account
        .makeQrCode(txInfo, args['params'], rawParam: args['rawParam']);
    print('make qr code');
    setState(() {
      _qrPayload =
          Uint8List.fromList(List<int>.from(Map.of(res['qrPayload']).values));
    });
    return _qrPayload;
  }

  Future<void> _handleScan(BuildContext context) async {
    final signed = await Navigator.of(context)
        .pushNamed(ScanPage.route, arguments: QrSenderPage.route);
    if (signed != null) {
      Navigator.of(context).pop(signed);
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        title: Text(I18n.of(context).home['submit.qr']),
        centerTitle: true,
      ),
      body: SafeArea(
        child: FutureBuilder(
          future: _getQrCodeData(context),
          builder: (_, AsyncSnapshot<Uint8List> snapshot) {
            return ListView(
              padding: EdgeInsets.only(top: 16),
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    snapshot.hasData
                        ? QrImage(
                            data: '',
                            rawBytes: snapshot.data,
                            size: screenWidth - 24,
                          )
                        : CupertinoActivityIndicator(),
                    snapshot.hasData
                        ? Padding(
                            padding: EdgeInsets.all(16),
                            child: RoundedButton(
                              icon: Image.asset(
                                  'assets/images/assets/scanner.png'),
                              text: I18n.of(context).account['uos.scan'],
                              onPressed: () {
                                _handleScan(context);
                              },
                            ),
                          )
                        : Container()
                  ],
                )
              ],
            );
          },
        ),
      ),
    );
  }
}
