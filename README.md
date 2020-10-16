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

Re-generate mobx g.dart files
  flutter packages pub run build_runner build --delete-conflicting-outputs

#### Android Studio
To run the in Android Studio a build flavor must be specified. Go to Run/Debug configurations and add the build flavor `dev` in the appropriate field. Other available values are in the in the android/app/src/build.gradle file.

>Note that this project can be compiled both in Android and IOS,
>But there is an Issue running it on an IOS simulator, that the
>substrate `sr25519` keyPair is generated within an `WASM` virtual
>machine which is **not supported** by IOS simulators.

## Acknowledgements

This app has been built based on [polkawallet.io](https://polkawallet.io)
