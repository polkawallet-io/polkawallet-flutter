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
brew uninstall node@6
NODE_VERSION="12.16.0"
curl "https://nodejs.org/dist/v${NODE_VERSION}/node-v${NODE_VERSION}.pkg" > "$HOME/Downloads/node-installer.pkg"
sudo installer -store -pkg "$HOME/Downloads/node-installer.pkg" -target "/"
cd ./lib/js_service_kusama && yarn install && yarn run build && cd ../..
cd ./lib/js_service_acala && yarn install && yarn run build && cd ../..
cd ./lib/js_service_laminar && yarn install && yarn run build && cd ../..
cd ./lib/js_as_extension && yarn install && yarn run build && cd ../..

flutter build apk --release --flavor prod
flutter build appbundle --release --flavor prod

# copy the APK where AppCenter will find it
mkdir -p android/app/build/outputs/apk/; mv build/app/outputs/apk/prod/release/app-prod-release.apk $_
# copy the AAB where AppCenter will find it
mkdir -p android/app/build/outputs/bundle/; mv build/app/outputs/bundle/prodRelease/app-prod-release.aab $_