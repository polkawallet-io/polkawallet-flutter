#!/usr/bin/env bash

set -exuo pipefail

NODE_VERSION="14.17.1" # should match the value from the CI.

curl "https://nodejs.org/dist/v${NODE_VERSION}/node-v${NODE_VERSION}.pkg" > "$HOME/Downloads/node-installer.pkg"
sudo installer -store -pkg "$HOME/Downloads/node-installer.pkg" -target "/"