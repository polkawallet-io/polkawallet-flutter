import 'package:encointer_wallet/utils/translations/index.dart';
import 'package:encointer_wallet/utils/translations/translations.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ota_update/ota_update.dart';

class DownloadDialog extends StatefulWidget {
  DownloadDialog(this.url);
  final String url;

  @override
  _DownloadDialog createState() => _DownloadDialog(url);
}

class _DownloadDialog extends State<DownloadDialog> {
  _DownloadDialog(this.url);
  final String url;

  String _downloadStatus = '';
  double _downloadProgress = 0;

  Future<void> _startDownloadApp() async {
    OtaUpdate()
        .execute(
      url,
      destinationFilename: url.split('/').reversed.toList()[0],
    )
        .listen(
      (OtaEvent event) {
        print('EVENT: ${event.status} : ${event.value}');
        final Translations dic = I18n.of(context).translationsForLocale();
        String status = dic.home.updateStart;
        switch (event.status.index) {
          case 0:
            status = dic.home.updateDownload;
            break;
          case 1:
            status = dic.home.updateInstall;
            break;
          default:
            status = dic.home.updateError;
        }
        setState(() {
          _downloadStatus = status;
          _downloadProgress = event.value.isNotEmpty ? double.parse(event.value) : 0;
        });
      },
    );
  }

  @override
  void initState() {
    super.initState();
    _startDownloadApp();
  }

  @override
  Widget build(BuildContext context) {
    final Translations dic = I18n.of(context).translationsForLocale();
    double progressWidth = 200;
    double progress = progressWidth * _downloadProgress / 100;
    return CupertinoAlertDialog(
      title: Text(_downloadStatus.isEmpty ? dic.home.updateStart : _downloadStatus),
      content: Padding(
        padding: EdgeInsets.only(top: 12),
        child: Stack(
          children: <Widget>[
            Container(
              width: progressWidth,
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(width: 4, color: Colors.black12),
                ),
              ),
            ),
            Container(
              width: progress,
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(width: 4, color: Colors.blueAccent),
                ),
              ),
            )
          ],
        ),
      ),
      actions: _downloadStatus == dic.home.updateError
          ? <Widget>[
              CupertinoButton(
                child: Text(dic.home.cancel),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ]
          : const <Widget>[],
    );
  }
}
