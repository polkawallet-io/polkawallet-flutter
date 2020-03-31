import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:flutter_qr_reader/qrcode_reader_view.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:polka_wallet/page/assets/transfer/transferPage.dart';
import 'package:polka_wallet/utils/format.dart';
import 'package:polka_wallet/utils/i18n/index.dart';

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
    Future onScan(String data) async {
      String address = '';
      for (String item in data.split(':')) {
        if (Fmt.isAddress(item)) {
          address = item;
          break;
        }
      }
      if (address.length > 0) {
        final String args = ModalRoute.of(context).settings.arguments;
        if (args == 'tx') {
          Navigator.of(context).pop();
          Navigator.of(context).pushNamed(TransferPage.route,
              arguments: {'address': address, 'redirect': '/'});
        } else {
          Navigator.of(context).pop(address);
        }
      } else {
        _qrViewKey.currentState.startScan();
      }
    }

    return Scaffold(
      body: FutureBuilder<bool>(
        future: canOpenCamera(),
        builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
          var dic = I18n.of(context).home;

          if (snapshot.hasData && snapshot.data == true) {
            return QrcodeReaderView(
                helpWidget: Text(dic['scan.helper']),
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
