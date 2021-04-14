# Encointer Wallet

Encointer wallet and client for mobile phones

[<img src="https://fdroid.gitlab.io/artwork/badge/get-it-on.png"
     alt="Get it on F-Droid"
     height="80">](https://f-droid.org/packages/org.encointer.wallet/)
[<img src="https://play.google.com/intl/en_us/badges/images/generic/en-play-badge.png"
     alt="Get it on Google Play"
     height="80">](https://play.google.com/store/apps/details?id=org.encointer.wallet)

## Overview

<img src="./encointer-gesell-assets.png" width=300>
<img src="./encointer-attesting.png" width=300>
<img src="./encointer-meetup-onegreen.png" width=300>
<img src="./encointer-meetup-scan.png" width=300>

## Build Instructions

### Install Flutter

Built with [Flutter](https://flutter.dev/), you need to have `Flutter` dev tools
installed on your computer to compile the project. check [Flutter Documentation](https://flutter.dev/docs)
 to learn how to install `Flutter` and initialize a Flutter App.

### Build js dependencies

Encointer wallet connects to the chains with [polkadot-js/api](https://polkadot.js.org/api/), running in a hidden webview.
You'll need `Nodejs` and `yarn` installed to build the bundled `main.js` file:

```shell script
cd lib/js_service_encointer/
# install nodejs dependencies
yarn install
# build main.js
yarn run build
```

### Run App

If you have an AVD or real device attached, you can do

```
flutter run --flavor dev
```

### Build APK

You may build the App with Flutter's [Deployment Documentation](https://flutter.dev/docs).

In order to build a fat APK, you can do 
```
flutter build apk --flavor fdroid
```
and find the output in `build/app/outputs/apk/fdroid/release/app-fdroid-release.apk`

For the play store, an appbundle is preferred:
```
flutter build appbundle
```
and find the output in `build/app/outputs/bundle/release/app-release.aab`

#### Dev hints

Currently supports flutter: 2.02

Re-generate mobx g.dart files
  flutter packages pub run build_runner build --delete-conflicting-outputs
  
### Run tests

* run all tests from the command line:`flutter test`
* run tests in specific directory: `flutter test test/page-encointer`

### Integration tests
* run all integration tests in `test_driver` directory: `flutter drive --target=test_driver/app.dart --flavor dev`

### Automated screenshots
The `screenshots` package is used to created automated screenshots. Setup:

* Install: `flutter pub global activate screenshots`
* Create virtual devices in android studio with `New Hardware Profile` that have the following config. The Name does matter. It must match the one defined in `screenshots.yaml`:


| Name              | Dimension     | Resolution
|---|---|---|
| IPad 12.9inch     | 12.9 inch     | 2048x2732	
| IPhone 6.5inch    | 6.5 inch      | 1242x2688
| IPhone 5.5inch    | 5.5 inch      | 1242x2208
| Google Pixel 3    | 5.6 inch      | 1080x2220

* Run: `screenshots --flavor dev`

#### Notes:
* The following directories need to be added to the path to run the emulator from the command line. The location below is the standard installation directory of the Android sdk in ubuntu:
```shell
 export PATH="$PATH":"$HOME/Android/Sdk"
 export PATH="$PATH":"$HOME/Android/Sdk/emulator"
 export PATH="$PATH":"$HOME/Android/Sdk/tools/bin" 
```
* Having 4 emulators setup will need approximately 45Gb of free space on the hard drive.
* Bug: The test run fails if the emulator is started with a cold boot.
* Bug: emulator can't be launched if flutter web support is enabled. See [screenshots issue](https://github.com/mmcc007/screenshots/issues/193). Turn it off with: `flutter config --no-enable-web`

#### Android Studio
To run the in Android Studio a build flavor must be specified. Go to Run/Debug configurations and add the build flavor `dev` in the appropriate field. Other available values are in the in the android/app/src/build.gradle file.

>Note that this project can be compiled both in Android and IOS,
>But there is an Issue running it on an IOS simulator, that the
>substrate `sr25519` keyPair is generated within an `WASM` virtual
>machine which is **not supported** by IOS simulators.

## Developer Remarks

### Release Flow

F-Droid triggers builds based on the version it reads from pubspec.yaml which it reads from branch `beta` HEAD`.
AppCenter automatically builds and deploys the HEAD of `beta`

VersionName should follow semver. Minor version bump on pre-1.0.0 release indicates breaking change

VersionCode should monotonically increase by 1 for every tagged build

  # bump version on some commit on master

```shell 
  git checkout master
  git tag v0.9.0
  git push
  git checkout beta
  git merge v0.9.0
  git push
```

## Acknowledgements

This app has been built based on [polkawallet.io](https://polkawallet.io)
