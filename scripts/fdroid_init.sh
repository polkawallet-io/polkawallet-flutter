#!/usr/bin/env bash

# Setup file for the f-droid build. The idea is that we do not need to update the
#
# https://gitlab.com/fdroid/fdroiddata/-/blob/master/metadata/org.encointer.wallet.yml
#
# if something in the build-process changes. However, we still need to manually update the flutter version in the
# `srclibs` key.

set -exuo pipefail

# init env vars needed for scripts
source ./scripts/init_env.sh

######################### Setup phase

DISTRO="linux-x64"
NODE_VERSION="16.13.1" # should match the value from the CI.
SHA_SUM="a3721f87cecc0b52b0be8587c20776ac7305db413751db02c55aa2bffac15198"
NODE="node-v${NODE_VERSION}-${DISTRO}"

curl -Lo node.tar.xz "https://nodejs.org/dist/v${NODE_VERSION}/${NODE}.tar.xz"
echo "${SHA_SUM} node.tar.xz" | sha256sum -c -

tar -vxf node.tar.xz && rm node.tar.xz

export PATH=$PATH:$PWD/${NODE}/bin

echo "Path: $PATH"

node -v

# enable binary proxies, which automatically install yarn, if needed.
corepack enable

# Build JS
./scripts/build_js.sh

######################### Cleanup phase

echo "Remove all binary files as f-droid does not allow them the repository"
rm -r ${NODE}
rm -r "${ENCOINTER_JS_DIR}/node_modules"
rm -r "${ENCOINTER_JS_DIR}/.yarn"