import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_qr_scan/qrcode_reader_view.dart';

class MockScanPage extends StatelessWidget {
  MockScanPage(this.background);

  // image that emulates camera
  final ImageProvider background;

  static final String route = '/account/mockScan';

  @override
  Widget build(BuildContext context) {
    Future onScan(String txt, String rawData) async {}

    return Scaffold(
      body: QrcodeReaderView(
        key: Key('mockQr'),
        helpWidget: Text("scan Qr Code"),
        headerWidget: Stack(children: <Widget>[
          Container(
              constraints: BoxConstraints.expand(),
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: background,
                  fit: BoxFit.cover,
                ),
              ),
              child: Container()),
          SafeArea(
            child: IconButton(
              icon: Icon(
                Icons.arrow_back_ios,
                color: Theme.of(context).cardColor,
              ),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
        ]),
        onScan: onScan,
      ),
    );
  }
}
