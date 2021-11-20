// copied from the screenshots package
// https://github.com/mmcc007/screenshots/

import 'dart:io';

import 'package:flutter_driver/flutter_driver.dart';

/// Called by integration test to capture images on the currently running device
Future screenshot(final FlutterDriver driver, Config config, String name,
    {Duration timeout = const Duration(seconds: 30),
    bool silent = false,
    bool waitUntilNoTransientCallbacks = true}) async {
  if (waitUntilNoTransientCallbacks) {
    await driver.waitUntilNoTransientCallbacks(timeout: timeout);
  }

  final pixels = await driver.screenshot();
  final testDir = '${config.stagingDir}/$kTestScreenshotsDir';
  final file = await File('$testDir/$name.$kImageExtension').create(recursive: true);
  await file.writeAsBytes(pixels);
  print('Screenshot $name created');
}

/// Config info used to manage screenshots for android and ios.
// Note: should not have context dependencies as is also used in driver.
class Config {
  Config({this.stagingDir = '/tmp/screenshots'});

  String stagingDir;
}

/// Image extension
const kImageExtension = 'png';

/// Directory for capturing screenshots during a test
const kTestScreenshotsDir = 'test';
