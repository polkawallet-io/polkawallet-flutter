#!/bin/bash
set -euxo pipefail

if [ "$RECORD" == "true" ]
then
  # due to a bug in xcode we need to sleep a while, else the recording is empty
  xcrun simctl io booted recordVideo --codec=h264 --mask=black recording.mov & sleep 5

  export RECORDING_PID=${!}
  echo "Recording process up with pid: ${RECORDING_PID}"
fi

flutter drive --target=test_driver/app.dart
flutter drive --target=test_driver/scanPage.dart

mkdir -p "$TEMP_DIR"

if [ "$RECORD" == "true" ]
then
  sleep 5
  kill -SIGINT $RECORDING_PID
  sleep 10
  cp recording.mov "$TEMP_DIR" || echo "no recording found..."
fi

# copy screenshots to TEMP_DIR
cp -r "$TEMP_DIR/test"/* "$TEMP_DIR" || echo "no screenshots found..."
rm -r "$TEMP_DIR/test" || true
