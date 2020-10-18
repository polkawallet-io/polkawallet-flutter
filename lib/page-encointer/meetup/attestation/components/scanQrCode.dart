import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_qr_scan/qrcode_reader_view.dart';
import 'package:permission_handler/permission_handler.dart';

// TODO: scan image failed
class ScanQrCode extends StatelessWidget {
  ScanQrCode({this.instruction});
  final String instruction;
  final GlobalKey<QrcodeReaderViewState> _qrViewKey = GlobalKey();

  Future<bool> canOpenCamera() async {
    var status = await PermissionHandler().checkPermissionStatus(PermissionGroup.camera);
    if (status != PermissionStatus.granted) {
      var future = await PermissionHandler().requestPermissions([PermissionGroup.camera]);
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
    Future _onScan(String data, String _rawData) async {
      if (data != null) {
        Navigator.of(context).pop(data);
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
              helpWidget: Text(instruction),
              headerWidget: SafeArea(
                child: IconButton(
                  icon: Icon(
                    Icons.arrow_back_ios,
                    color: Theme.of(context).cardColor,
                  ),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
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
