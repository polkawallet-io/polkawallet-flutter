#!/bin/bash
set -euo pipefail

CURRENT_DIR=$(pwd)

cd "$ENCOINTER_JS_DIR"

yarn install
yarn build

cd "$CURRENT_DIR"
