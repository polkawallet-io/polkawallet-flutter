import 'package:encointer_wallet/page/assets/transfer/transferPage.dart';
import 'package:encointer_wallet/page/profile/contacts/contactPage.dart';
import 'package:encointer_wallet/service/qrScanService.dart';
import 'package:encointer_wallet/store/app.dart';
import 'package:encointer_wallet/utils/translations/index.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_qr_scan/qrcode_reader_view.dart';
import 'package:permission_handler/permission_handler.dart';

// TODO: scan image failed
class ScanPage extends StatelessWidget {
  ScanPage(this.store);

  static final String route = '/account/scan';
  final GlobalKey<QrcodeReaderViewState> _qrViewKey = GlobalKey();
  final QrScanService qrScanService = QrScanService();

  final AppStore store;

  Future<bool> canOpenCamera() async {
    // will do nothing if already granted
    return Permission.camera.request().isGranted;
  }

  @override
  Widget build(BuildContext context) {
    Future onScan(String data, String rawData) {
      QrScanData qrScanData = qrScanService.parse(data);
      switch (qrScanData.context) {
        case QrScanContext.contact:
          // show add contact and auto-fill data
          Navigator.of(context).popAndPushNamed(
            ContactPage.route,
            arguments: qrScanData,
          );
          break;
        case QrScanContext.invoice:
          // go to transfer page and auto-fill data
          Navigator.of(context).popAndPushNamed(
            TransferPage.route,
            arguments: TransferPageParams(
                cid: qrScanData.cid, recipient: qrScanData.account, amount: qrScanData.amount, redirect: '/'),
          );
          break;
        default:
          throw UnimplementedError(
              'Scan functionality for the case [${qrScanData.context}] has not yet been implemented!');
      }
      return null;
    }

    return Scaffold(
      body: SafeArea(
        child: FutureBuilder<bool>(
          future: canOpenCamera(),
          builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
            if (snapshot.hasData && snapshot.data == true) {
              return QrcodeReaderView(
                headerWidget: store.settings.developerMode
                    ? Row(children: [
                        ElevatedButton(
                          child: Text('addContact'),
                          onPressed: () => onScan(
                              "encointer-contact\nV1.0\nHgTtJusFEn2gmMmB5wmJDnMRXKD6dzqCpNR7a99kkQ7BNvX\nsqm1v79dF6b\n\nSara",
                              null),
                        ),
                        ElevatedButton(
                          child: Text('invoice'),
                          onPressed: () => onScan(
                              "encointer-invoice\nV1.0\nHgTtJusFEn2gmMmB5wmJDnMRXKD6dzqCpNR7a99kkQ7BNvX"
                              "\nsqm1v79dF6b\n0.2343\nAubrey",
                              null),
                        ),
                        Text(' <<< Devs only', style: TextStyle(color: Colors.orange)),
                      ])
                    : Container(),
                key: _qrViewKey,
                helpWidget: Text(I18n.of(context).translationsForLocale().account.qrScan),
                onScan: onScan,
              );
            } else {
              return Container();
            }
          },
        ),
      ),
    );
  }
}
