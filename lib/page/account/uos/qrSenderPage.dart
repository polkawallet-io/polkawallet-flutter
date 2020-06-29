import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:polka_wallet/common/components/roundedButton.dart';
import 'package:polka_wallet/page/account/scanPage.dart';
import 'package:polka_wallet/service/substrateApi/api.dart';
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
    print(txInfo);
    print(args['params']);

    final Map res = await webApi.account
        .makeQrCode(txInfo, args['params'], rawParam: args['rawParam']);
    print('make qr code');
    print(res);
    setState(() {
      _qrPayload =
          Uint8List.fromList(List<int>.from(Map.of(res['qrPayload']).values));
    });
    return _qrPayload;
  }

  Future<void> _handleScan(BuildContext context) async {
    final signed = await Navigator.of(context).pushNamed(ScanPage.route);
    print('signed data:');
    print(signed);
    if (signed != null) {
      Navigator.of(context).pop(signed);
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(title: Text('signed extrinsic'), centerTitle: true),
      body: SafeArea(
        child: FutureBuilder(
          future: _getQrCodeData(context),
          builder: (_, AsyncSnapshot<Uint8List> snapshot) {
            return ListView(
              children: [
                Text('scan to sign'),
                snapshot.hasData
                    ? QrImage(
                        data: '',
                        rawBytes: snapshot.data,
                        size: screenWidth - 32,
                      )
                    : CupertinoActivityIndicator(),
                snapshot.hasData
                    ? RoundedButton(
                        icon: Image.asset('assets/images/assets/scanner.png'),
                        text: 'scan signed Qr',
                        onPressed: () {
                          _handleScan(context);
                        },
                      )
                    : Container()
              ],
            );
          },
        ),
      ),
    );
  }
}
