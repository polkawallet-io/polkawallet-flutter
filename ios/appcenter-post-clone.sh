#!/usr/bin/env bash

set -exuo pipefail

# place this script in project/ios/
cd ..

source ./scripts/app_center_post_clone_setup.sh

flutter build ios --release --no-codesign