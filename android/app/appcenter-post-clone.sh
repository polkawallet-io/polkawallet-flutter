#!/usr/bin/env bash
# place this script in project/android/app/
cd ..
# fail if any command fails
set -e
# debug log
set -x

cd ..
# choose a different release channel if you want - https://github.com/flutter/flutter/wiki/Flutter-build-release-channels
# stable - recommended for production
git clone -b stable https://github.com/flutter/flutter.git
export PATH=`pwd`/flutter/bin:$PATH
flutter channel stable
flutter doctor

# update node.js version and build main.js before flutter build
brew uninstall --force node
NODE_VERSION="12.16.0"
curl "https://nodejs.org/dist/v${NODE_VERSION}/node-v${NODE_VERSION}.pkg" > "$HOME/Downloads/node-installer.pkg"
sudo installer -store -pkg "$HOME/Downloads/node-installer.pkg" -target "/"
cd ./lib/js_service_encointer && yarn install && yarn run build && cd ../..

flutter build apk --release --flavor play
flutter build appbundle --release --flavor play

# copy the APK where AppCenter will find it
mkdir -p android/app/build/outputs/apk/; cp build/app/outputs/flutter-apk/app-play-release.apk $_
# copy the AAB where AppCenter will find it
mkdir -p android/app/build/outputs/bundle/; cp build/app/outputs/bundle/playRelease/app-play-release.aab $_