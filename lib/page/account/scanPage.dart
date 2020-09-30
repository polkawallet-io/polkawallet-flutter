import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_qr_scan/qrcode_reader_view.dart';

import 'package:permission_handler/permission_handler.dart';
import 'package:polka_wallet/page/account/uos/qrSenderPage.dart';
import 'package:polka_wallet/page/assets/transfer/transferPage.dart';
import 'package:polka_wallet/utils/format.dart';

// TODO: scan image failed
class ScanPage extends StatelessWidget {
  static final String route = '/account/scan';
  final GlobalKey<QrcodeReaderViewState> _qrViewKey = GlobalKey();

  Future<bool> canOpenCamera() async {
    var status =
        await PermissionHandler().checkPermissionStatus(PermissionGroup.camera);
    if (status != PermissionStatus.granted) {
      var future = await PermissionHandler()
          .requestPermissions([PermissionGroup.camera]);
      for (final item in future.entries) {
        if (item.value != PermissionStatus.granted) {
          return false;
        }
      }
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    Future onScan(String txt, String rawData) async {
      String address = '';
      final String data = txt.trim();
      if (data != null) {
        List<String> ls = data.split(':');
        for (String item in ls) {
          if (Fmt.isAddress(item)) {
            address = item;
            break;
          }
        }

        final String args = ModalRoute.of(context).settings.arguments;
        if (address.length > 0) {
          print('address detected in Qr');
          if (args == 'tx') {
            Navigator.of(context).popAndPushNamed(
              TransferPage.route,
              arguments: TransferPageParams(address: address, redirect: '/'),
            );
          } else {
            Navigator.of(context).pop(QRCodeAddressResult(ls));
          }
        } else if (args == QrSenderPage.route && Fmt.isHexString(data)) {
          print('hex detected in Qr');
          Navigator.of(context).pop(data);
        } else if (rawData != null &&
            (rawData.endsWith('ec') || rawData.endsWith('ec11'))) {
          print('rawBytes detected in Qr');
          Navigator.of(context).pop(rawData);
        } else {
          _qrViewKey.currentState.startScan();
        }
      }
    }

    return Scaffold(
      body: FutureBuilder<bool>(
        future: canOpenCamera(),
        builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
          if (snapshot.hasData && snapshot.data == true) {
            return QrcodeReaderView(
                key: _qrViewKey,
                headerWidget: SafeArea(
                  child: IconButton(
                    icon: Icon(
                      Icons.arrow_back_ios,
                      color: Theme.of(context).cardColor,
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ),
                onScan: onScan);
          } else {
            return Container();
          }
        },
      ),
    );
  }
}

class QRCodeAddressResult {
  QRCodeAddressResult(this.rawData)
      : chainType = rawData[0],
        address = rawData[1],
        pubKey = rawData[2],
        name = rawData[3];

  final List<String> rawData;

  final String chainType;
  final String address;
  final String pubKey;
  final String name;
}
