import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:flutter_qr_reader/qrcode_reader_view.dart';
import 'package:permission_handler/permission_handler.dart';

class Scan extends StatefulWidget {
  @override
  _ScanState createState() => _ScanState();
}

class _ScanState extends State<Scan> {
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
    } else {
      return true;
    }
    return true;
  }

  @override
  void initState() {
    super.initState();
    canOpenCamera();
  }

  @override
  Widget build(BuildContext context) {
    Future onScan(String data) async {
      print(data);
      final String args = ModalRoute.of(context).settings.arguments;
      if (args == 'tx') {
        Navigator.pushNamed(context, '/assets/transfer', arguments: data);
        return;
      } else {
        Navigator.of(context).pop(data);
      }
      _qrViewKey.currentState.startScan();
    }

    return Scaffold(
      body: FutureBuilder<bool>(
        future: canOpenCamera(),
        builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
          if (snapshot.hasData && snapshot.data == true) {
            return QrcodeReaderView(key: _qrViewKey, onScan: onScan);
          } else {
            return Container();
          }
        },
      ),
    );
  }
}
