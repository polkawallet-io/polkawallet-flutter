#!/usr/bin/env bash

# To make the flutter cmd available to the calling shell, this script needs to be called with `source`

set -exuo pipefail

git clone -b stable https://github.com/flutter/flutter.git
export PATH=$(pwd)/flutter/bin:$PATH

cd flutter

# `precache` ensures that the correct Dart SDK and binaries for IOS and android exist.
#
# Version should match the version from the CI.
git checkout 2.0.5 && flutter precache

flutter doctor

cd ..