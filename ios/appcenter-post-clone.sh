#!/usr/bin/env bash
# place this script in project/ios/
cd ..
# fail if any command fails
set -e
# debug log
set -x

# choose a different release channel if you want - https://github.com/flutter/flutter/wiki/Flutter-build-release-channels
# stable - recommended for production
git clone -b stable https://github.com/flutter/flutter.git
export PATH=`pwd`/flutter/bin:$PATH
flutter channel stable
flutter doctor

# update node.js version and build main.js before flutter build
NODE_VERSION="12.16.0"
curl "https://nodejs.org/dist/v${NODE_VERSION}/node-v${NODE_VERSION}.pkg" > "$HOME/Downloads/node-installer.pkg"
sudo installer -store -pkg "$HOME/Downloads/node-installer.pkg" -target "/"
cd ./lib/js_service_kusama && yarn install && yarn run build && cd ../..
cd ./lib/js_service_acala && yarn install && yarn run build && cd ../..
cd ./lib/js_service_laminar && yarn install && yarn run build && cd ../..
cd ./lib/js_as_extension && yarn install && yarn run build && cd ../..

flutter build ios --release --no-codesign