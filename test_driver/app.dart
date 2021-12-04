import 'package:encointer_wallet/app.dart';
import 'package:encointer_wallet/config.dart';
import 'package:encointer_wallet/mocks/storage/prepareStorage.dart';
import 'package:encointer_wallet/mocks/storage/storageSetup.dart';
import 'package:encointer_wallet/store/app.dart';
import 'package:flutter/material.dart';
import 'package:flutter_driver/driver_extension.dart';

void main() {
  // the tests are run in a separate isolate from the app. The test isolate can only interact with
  // the app via the driver in order to, for instance, configure the app state.
  // More info in: https://medium.com/stuart-engineering/mocking-integration-tests-with-flutter-af3b6ba846c7
  //
  // ignore: missing_return
  Future<String> dataHandler(String msg) async {
    switch (msg) {
      case StorageSetup.INIT:
        {
          PrepareStorage.init(globalAppStore);
        }
        break;
      case StorageSetup.GET_METADATA:
        {
          PrepareStorage.getMetadata(globalAppStore);
        }
        break;
      case StorageSetup.UNREGISTERED_PARTICIPANT:
        {
          PrepareStorage.unregisteredParticipant(globalAppStore);
        }
        break;
      case StorageSetup.READY_FOR_MEETUP:
        {
          PrepareStorage.readyForMeetup(globalAppStore);
        }
        break;
      default:
        break;
    }
  }

  enableFlutterDriverExtension(handler: dataHandler);
  WidgetsApp.debugAllowBannerOverride = false; // remove debug banner for screenshots

  // Call the `main()` function of the app, or call `runApp` with
  // any widget you are interested in testing.
  runApp(
    WalletApp(Config(mockLocalStorage: true, mockSubstrateApi: true)),
  );
}
