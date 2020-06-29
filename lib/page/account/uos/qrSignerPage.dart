import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

class QrSignerPage extends StatelessWidget {
  static const String route = 'tx/uos/signer';

  @override
  Widget build(BuildContext context) {
    final String text = ModalRoute.of(context).settings.arguments;
    final screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(title: Text('signed extrinsic'), centerTitle: true),
      body: SafeArea(
        child: ListView(
          children: [
            Text('scan to publish'),
            QrImage(data: text, size: screenWidth - 32),
          ],
        ),
      ),
    );
  }
}
