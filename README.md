# Encointer Wallet

Encointer wallet and client for mobile phones

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

For now (will not be necessary later), do the same for `lib/js_service_kusama`

### Build Flutter App

You may build the App with Flutter's [Deployment Documentation](https://flutter.dev/docs).

#### Android Studio
To run the in Android Studio a build flavor must be specified. Go to Run/Debug configurations and add the build flavor in the appropriate field. The available values are in the in the android/app/src/build.gradle file.

>Note that this project can be compiled both in Android and IOS,
>But there is an Issue running it on an IOS simulator, that the
>substrate `sr25519` keyPair is generated within an `WASM` virtual
>machine which is **not supported** by IOS simulators.

## Acknowledgements

This app has been built based on [polkawallet.io](https://polkawallet.io)
