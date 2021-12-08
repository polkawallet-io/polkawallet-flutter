#!/usr/bin/env bash

set -exuo pipefail

# place this script in project/android/app/
cd ../../

source ./scripts/app_center_post_clone_setup.sh

flutter build apk --release --flavor play
flutter build appbundle --release --flavor play

# copy the APK where AppCenter will find it
mkdir -p android/app/build/outputs/apk/; cp build/app/outputs/flutter-apk/app-play-release.apk $_
# copy the AAB where AppCenter will find it
mkdir -p android/app/build/outputs/bundle/; cp build/app/outputs/bundle/playRelease/app-play-release.aab $_