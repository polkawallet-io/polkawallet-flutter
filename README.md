# polkawallet-flutter

Polkawallet Flutter Implementation, https://polkawallet.io

![](https://github.com/jiangfuyao/polkawallet-flutter-images/raw/master/cover-eb14f464e002642772ffad6d4c9debd5.png)

### How to compile

#### Install Flutter 
`polkawallet_flutter` is built with [Flutter](https://flutter.dev/), you need to have `Flutter` dev tools
installed on your computer to compile the project. check [Flutter Documentation](https://flutter.dev/docs)
 to learn how to install `Flutter` and initialize a Flutter App.

#### Build `main.js` of polkadot-js API
`polkawallet_flutter` connects substrate-based networks with [polkadot-js/api](https://polkadot.js.org/api/), running in a hidden webview.
You'll need `Nodejs` and `yarn` installed to build the bundled `main.js` file:
```shell script
cd lib/polkadot_js_service/
# install nodejs dependencies
yarn install
# build main.js
yarn run build
```

#### Build Flutter App
While `main.js` was built in `lib/polkadot_js_service/` directory, you may build the App with Flutter's [Deployment Documentation](https://flutter.dev/docs).
>Note that this project can be compiled both in Android and IOS,
>But there is an Issue running it on an IOS simulator, that the
>substrate `sr25519` keyPair is generated within an `WASM` virtual
>machine which is **not supported** by IOS simulators.

#### Troubleshooting (Android)

If you encounter the following issue https://github.com/polkawallet-io/polkawallet-flutter/issues/15, where it hangs with the following shown in the logs `Waiting for observatory port to be available...`, then the following additional changes are required before you run `flutter run`:

* Create a MainActivity.kt file, as follows:
```
mkdir -p ./android/app/src/main/kotlin/io/polkawallet/www/polkawalletflutter && \
touch ./android/app/src/main/kotlin/io/polkawallet/www/polkawalletflutter/MainActivity.kt
```

* Paste the following in MainActivity.kt

```bash
package io.polkawallet.www.polkawalletflutter

import androidx.annotation.NonNull;
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugins.GeneratedPluginRegistrant

class MainActivity: FlutterActivity() {
    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        GeneratedPluginRegistrant.registerWith(flutterEngine);
    }
}
```

Note: the folder structure is required since the package of polkawallet-flutter is "io.polkawallet.www.polkawalletflutter"

### Project introduce

 [Polkawallet](http://polkawallet.io) provide Cross-chain asset one-stop management, convenient staking and governance, the private key is self-owned. 

![](https://github.com/jiangfuyao/polkawallet-flutter-images/raw/master/Simulator%20Screen%20Shot%20-%20iPhone%2011%20Pro%20Max%20-%202020-03-09%20at%2018.05.11-iPhone%20X.png)

In order to give users a more humane and more convenient experience, as the entrance of the polkadot network, the user is provided with more intuitive visual data and status change display to guarantee the user's right to know and network participation.


- Users can add assets, support Relaychain and Parachain to transfer, receive, and view the transfer history and state. Have the visual asset change analysis chart, make it easier for users to analyze assets. Users are notified when they receive the asset and can view the transfer details data.

  The private key is self-owned, and have the Gesture,Fingerprint, Facial recognition, Hot and cold wallet mechanism, users can set their own scheme. Our team is developing a new encryption scheme -- high - dimensional fractal encryption, will be used to safeguard the security of a user using the polkawallet.

![](https://github.com/jiangfuyao/polkawallet-flutter-images/raw/master/Simulator%20Screen%20Shot%20-%20iPhone%208%20Plus%20-%202020-03-17%20at%2010.57.14-iPhone%207.png)

- Polkawallet makes it easier for validators and nominal ators to make their contributions, by making the charts more intuitive and having a detailed history of each validators, for better analysis and research.

![](https://github.com/jiangfuyao/polkawallet-flutter-images/raw/master/Simulator%20Screen%20Shot%20-%20iPhone%2011%20Pro%20-%202020-03-19%20at%2015.11.09-iPhone%20X.png)
![](https://github.com/jiangfuyao/polkawallet-flutter-images/raw/master/Simulator%20Screen%20Shot%20-%20iPhone%208%20Plus%20-%202020-03-17%20at%2010.57.48-iPhone%207.png)

- Polkawallet provides a more intuitive and convenient entry point for participating in governance. If there is a new referendum/proposals, the user is reminded and you can view the details. Users can governance directly from polkawallet and view the history governance records. So polkawallet also improves public Referenda engagement.

  ![](https://github.com/jiangfuyao/polkawallet-flutter-images/raw/master/Simulator%20Screen%20Shot%20-%20iPhone%2011%20Pro%20Max%20-%202020-03-09%20at%2018.06.47-iPhone%20X.png)

![](https://github.com/jiangfuyao/polkawallet-flutter-images/raw/master/Simulator%20Screen%20Shot%20-%20iPhone%208%20Plus%20-%202020-03-17%20at%2010.58.27-Pixel.png)


- Available for all major mobile platforms. Currently Flutter is used as a cross-platform solution.

### Let's see what this version can do
- [x] We redeveloped Polkawallet with Flutter, which greatly improved the fluency.
- [x] You can create Kusama Network account and use Sr25519 by default.
- [x] Import account support Mnemonics, Raw Seed, Keystore.
- [x] Import account support Sr/Ed25519, also supports HD Derivation.
- [x] Basic balance display and transfer functions, transaction history query, Qr code interaction.
- [x] Staking module basic account status information, including: Bonded, Unlocking, Reward, and more.
- [x] Staking Operation Records.
- [x] Staking account operation functions, including: Bond，Unbond，Reward Type change，Reward，payout reward, and more.
- [x] Governance module displays information about the Council and can perform voting.
- [x] Governance module, Democracy can view the referendum information, and can cast your vote in addition to the lock-up period.
- [x] Some basic account settings, such as changing name, password. And can choose network nodes, address prefix, Language.

### Next Plan

- Support for the Acala Network account module.
- Integrated Acala Network Honzon operating platform.
- Support for other Parachain accounts and functional modules.

### Questions

> Why use Flutter to develop?

The previous version tried to develop Polkawallet with React Native, we want to try different frameworks and explore different solutions. Through exploration, we saw that the fluency of the Flutter version has greatly improved, which is a good attempt.

> Can other teams make secondary development based on Polkawallet?

Of course, we use a very loose Apache License 2.0, you can make free changes based on Polkawallet. We have contacted some projects to help them carry out secondary development. Such as datahighway.com
There have the link of Github repository: https://github.com/polkawallet-io/polkawallet-flutter/tree/develop

> How can Polkawallet maintain development?

We got grants from Web3 Foundation, at the same time, we are helping Acala Network to develop convenient mobile interactions. In the future we want to actively join the ParaDAO that Acala Network is launching, this can be a way for many ecological projects to come together. Through ParaDAO, infrastructures such as Polkawallet and Parachain projects all have clear maintenance development plans.


### View more info of Polkawallet
`Website:` https://polkawallet.io  
`Twitter:` https://twitter.com/polkawallet  
`E-mail:`  hello@polkawallet.io  
