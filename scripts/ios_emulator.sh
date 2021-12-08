#!/bin/bash
set -euo pipefail

echo "looking for emulator with device id: ${DEVICE_ID}"

echo "Available devices are:"
xcrun xctrace list devices 2>&1

UUID=$(xcrun xctrace list devices 2>&1 | grep "$DEVICE_ID" | grep -oE "([A-F0-9]{8}-[A-F0-9]{4}-4[A-F0-9]{3}-[89AB][A-F0-9]{3}-[A-F0-9]{12})")

echo "Applesimutils help: "
applesimutils --help

echo "Setting notification permissions.. "
applesimutils --byId "$UUID" --bundle "org.encointer.wallet" --setPermissions "notifications=YES"

echo "Booting device with UUID: ${UUID}"
xcrun simctl boot "${UUID:?No Simulator with this name found}"
