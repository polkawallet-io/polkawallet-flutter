import 'dart:convert';

import 'package:encointer_wallet/mocks/restartWidget.dart';
import 'package:encointer_wallet/mocks/scanPage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_driver/driver_extension.dart';
import 'package:rxdart/rxdart.dart';

/// Here we start the MockScanPage first with some random background. Afterwards we send the encoded background image
/// from the driver to the app.
///
/// Reasoning behind that procedure is that we don't want to include the high resolution image that we set as
/// background in the app bundle. Flutter does not yet support build configuration /-flavor dependant asset inclusion.
///
void main() async {
  // ignore: close_sinks
  final PublishSubject<ImageProvider> stream = PublishSubject();

  // ignore: missing_return
  Future<String> dataHandler(String msg) async {
    final img = MemoryImage(base64Decode(msg));
    stream.add(img);
  }

  enableFlutterDriverExtension(handler: dataHandler);
  WidgetsApp.debugAllowBannerOverride = false; // remove debug banner for screenshots

  runApp(
    MaterialApp(
      title: 'EncointerWallet',
      initialRoute: MockScanPage.route,
      routes: {
        MockScanPage.route: (_) => RestartWidget(
              initialData: MemoryImage(base64Decode("hell")),
              stream: stream,
              builder: (_, img) => MockScanPage(img),
            )
      },
    ),
  );
}
